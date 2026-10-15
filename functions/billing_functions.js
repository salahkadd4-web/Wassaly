/**
 * Wassaly - Cloud Functions de facturation des livreurs.
 *
 * Toute operation qui touche a l'argent passe par ici : le code de
 * l'application est public, on ne lui fait pas confiance. La logique pure
 * (montants, plafonds, remboursements) est dans billing.js et testee.
 *
 * Le prix d'une course se negocie dans Firestore (propositions et
 * contre-propositions, controlees par firestore.rules). La conclusion de
 * l'accord, elle, passe toujours par le serveur :
 *   - agreeDelivery : accord sur une demande directe ;
 *   - agreeOffer    : accord sur l'offre d'un livreur pour une demande ouverte
 *                     (le premier accord ferme la demande) ;
 *   - choosePlan    : le livreur choisit sa formule.
 * A l'accord : course comptee, 50 DA en formule a la livraison, telephones
 * et adresse exacte devoiles aux deux parties.
 * Declencheurs : remboursement a l'annulation, compteurs anti-fraude, notes.
 * Planifiee : bascule de fin d'essai / de mois paye, chaque nuit.
 *
 * admin.initializeApp() doit avoir ete appele (index.js) avant le require.
 */
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const billing = require('./billing');

const db = admin.firestore();
const { FieldValue, Timestamp } = admin.firestore;

/** Erreur metier renvoyee a l'application (code lu par BillingFunctions en Dart). */
const fail = (reason) => new HttpsError('failed-precondition', reason, { reason });

function requireUid(request) {
  const uid = request.auth && request.auth.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'not-signed-in');
  return uid;
}

const billingRef = (uid) => db.collection('driverBilling').doc(uid);

/**
 * Debit (formule a la livraison) et mise a jour du livreur, dans une
 * transaction deja ouverte : toutes les lectures sont faites avant.
 * Retourne le montant debite (0 pendant l'essai ou un mois paye).
 */
function chargeInTransaction(tx, { uid, driver, billingData, requestId, now }) {
  if (!billing.isEligible(driver, now)) throw fail('not-eligible');

  const driverUpdate = {};
  const billingUpdate = {
    stats: { accepted: FieldValue.increment(1) },
    updatedAt: FieldValue.serverTimestamp(),
  };
  let charged = 0;

  if (billing.isPerDeliveryMode(driver, now)) {
    const result = billing.applyCharge(billingData.debt);
    if (!result) throw fail('debt-limit');
    charged = billing.PER_DELIVERY_PRICE_DA;
    billingUpdate.debt = result.debt;
    if (result.blocked) {
      billingUpdate.blockedSince = FieldValue.serverTimestamp();
      driverUpdate.billingBlocked = true;
      driverUpdate.active = false;
    }
    // Essai / mois termine avec "per_delivery" choisi : bascule immediate.
    if (driver.subscriptionStatus !== 'per_delivery') {
      driverUpdate.subscriptionStatus = 'per_delivery';
    }
    tx.set(billingRef(uid).collection('ledger').doc(`charge_${requestId}`), {
      type: 'charge',
      amount: charged,
      requestId,
      createdAt: FieldValue.serverTimestamp(),
    });
  }

  tx.set(billingRef(uid), billingUpdate, { merge: true });
  if (Object.keys(driverUpdate).length > 0) {
    tx.update(db.collection('drivers').doc(uid), driverUpdate);
  }
  return charged;
}

/** Telephones des deux parties, lisibles une fois la demande acceptee. */
function writeContact(tx, requestId, clientUser, driverUser) {
  tx.set(
    db.collection('deliveryRequests').doc(requestId).collection('private').doc('contact'),
    {
      clientPhone: (clientUser && clientUser.phone) || '',
      driverPhone: (driverUser && driverUser.phone) || '',
    },
  );
}

/** Lectures communes : livreur, sa facturation, les deux profils prives. */
async function readParties(tx, driverId, clientId) {
  const [driverSnap, billingSnap, clientUser, driverUser] = await Promise.all([
    tx.get(db.collection('drivers').doc(driverId)),
    tx.get(billingRef(driverId)),
    tx.get(db.collection('users').doc(clientId)),
    tx.get(db.collection('users').doc(driverId)),
  ]);
  if (!driverSnap.exists) throw fail('not-eligible');
  return {
    driver: driverSnap.data(),
    billingData: billingSnap.data() || {},
    clientUser: clientUser.data(),
    driverUser: driverUser.data(),
  };
}

/**
 * Debit du livreur au moment de l'accord. Si c'est le client qui conclut et
 * que le livreur ne peut plus travailler (dette, abonnement), on le dit au
 * client sans detail sur la situation du livreur.
 */
function chargeAtAgreement(tx, args, callerIsDriver) {
  try {
    return chargeInTransaction(tx, args);
  } catch (e) {
    if (!callerIsDriver && e instanceof HttpsError) throw fail('driver-unavailable');
    throw e;
  }
}

exports.agreeDelivery = onCall(async (request) => {
  const uid = requireUid(request);
  const requestId = String((request.data && request.data.requestId) || '');
  if (!requestId) throw new HttpsError('invalid-argument', 'requestId');

  await db.runTransaction(async (tx) => {
    const reqRef = db.collection('deliveryRequests').doc(requestId);
    const req = (await tx.get(reqRef)).data();
    if (!req || req.status !== 'negotiating') throw fail('not-pending');
    const callerIsDriver = uid === req.driverId;
    if (!callerIsDriver && uid !== req.clientId) throw fail('not-pending');
    if (!billing.canAgree(req.lastBy, callerIsDriver)) throw fail('not-your-turn');
    if (!billing.isValidPrice(req.price)) throw fail('not-pending');

    const p = await readParties(tx, req.driverId, req.clientId);
    const charged = chargeAtAgreement(
      tx,
      { uid: req.driverId, driver: p.driver, billingData: p.billingData, requestId, now: Date.now() },
      callerIsDriver,
    );
    tx.update(reqRef, {
      status: 'accepted',
      acceptedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      charged,
    });
    writeContact(tx, requestId, p.clientUser, p.driverUser);
  });
  return { ok: true };
});

exports.agreeOffer = onCall(async (request) => {
  const uid = requireUid(request);
  const openId = String((request.data && request.data.openRequestId) || '');
  const driverId = String((request.data && request.data.driverId) || '');
  if (!openId || !driverId) throw new HttpsError('invalid-argument', 'openRequestId');

  const openRef = db.collection('openRequests').doc(openId);
  const offersRef = openRef.collection('offers');
  const deliveryRef = db.collection('deliveryRequests').doc();
  await db.runTransaction(async (tx) => {
    const [openSnap, offerSnap, routeSnap, othersSnap] = await Promise.all([
      tx.get(openRef),
      tx.get(offersRef.doc(driverId)),
      tx.get(openRef.collection('private').doc('route')),
      tx.get(offersRef.where('status', '==', 'open')),
    ]);
    const open = openSnap.data();
    const offer = offerSnap.data();
    if (!open || open.status !== 'open') throw fail('already-taken');
    if (!offer || offer.status !== 'open') throw fail('not-pending');
    const callerIsDriver = uid === driverId;
    if (!callerIsDriver && uid !== open.clientId) throw fail('not-pending');
    if (!billing.canAgree(offer.lastBy, callerIsDriver)) throw fail('not-your-turn');
    if (!billing.isValidPrice(offer.price)) throw fail('not-pending');

    const p = await readParties(tx, driverId, open.clientId);
    const charged = chargeAtAgreement(
      tx,
      { uid: driverId, driver: p.driver, billingData: p.billingData, requestId: deliveryRef.id, now: Date.now() },
      callerIsDriver,
    );
    tx.set(deliveryRef, {
      clientId: open.clientId,
      driverId,
      clientName: open.clientName || '',
      driverName: p.driver.name || '',
      pickupArea: open.pickupArea || '',
      deliveryArea: open.deliveryArea || '',
      distanceKm: open.distanceKm == null ? null : open.distanceKm,
      note: open.note || '',
      status: 'accepted',
      source: 'open',
      openRequestId: openId,
      price: offer.price,
      lastBy: offer.lastBy,
      charged,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      acceptedAt: FieldValue.serverTimestamp(),
    });
    const route = routeSnap.data() || {};
    tx.set(deliveryRef.collection('private').doc('route'), {
      pickup: route.pickup || {},
      delivery: route.delivery || {},
    });
    writeContact(tx, deliveryRef.id, p.clientUser, p.driverUser);
    tx.update(openRef, {
      status: 'taken',
      takenBy: driverId,
      takenByName: p.driver.name || '',
      deliveryRequestId: deliveryRef.id,
      updatedAt: FieldValue.serverTimestamp(),
    });
    // Les autres offres en cours sont closes : la course est attribuee.
    for (const other of othersSnap.docs) {
      tx.update(other.ref, {
        status: other.id === driverId ? 'agreed' : 'closed',
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  });
  return { deliveryRequestId: deliveryRef.id };
});

exports.choosePlan = onCall(async (request) => {
  const uid = requireUid(request);
  const plan = String((request.data && request.data.plan) || '');

  await db.runTransaction(async (tx) => {
    const driverRef = db.collection('drivers').doc(uid);
    const [driverSnap, billingSnap] = await Promise.all([
      tx.get(driverRef),
      tx.get(billingRef(uid)),
    ]);
    if (!driverSnap.exists) throw fail('not-eligible');
    const debt = (billingSnap.data() || {}).debt || 0;
    const result = billing.planChange(driverSnap.data(), debt, plan, Date.now());
    if (result.error === 'invalid-plan') throw new HttpsError('invalid-argument', 'plan');
    if (result.error) throw fail(result.error);
    tx.update(driverRef, result.update);
  });
  return { ok: true };
});

/** Annulation apres acceptation (remboursement encadre) et livraisons terminees. */
exports.onDeliveryRequestUpdated = onDocumentUpdated('deliveryRequests/{rid}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!before || !after || before.status !== 'accepted' || after.status === 'accepted') return;
  const driverId = after.driverId;
  if (!driverId) return;

  if (after.status === 'completed') {
    await billingRef(driverId).set({ stats: { completed: FieldValue.increment(1) } }, { merge: true });
    return;
  }
  if (after.status !== 'cancelled') return;

  const rid = event.params.rid;
  await db.runTransaction(async (tx) => {
    const ref = billingRef(driverId);
    const refundRef = ref.collection('ledger').doc(`refund_${rid}`);
    // Montant et heure du debit lus dans l'ecriture du serveur, jamais dans
    // la demande (defense en profondeur, meme si les regles protegent ces champs).
    const chargeRef = ref.collection('ledger').doc(`charge_${rid}`);
    const [billingSnap, refundSnap, chargeSnap] = await Promise.all([
      tx.get(ref),
      tx.get(refundRef),
      tx.get(chargeRef),
    ]);
    if (refundSnap.exists) return; // declencheur rejoue
    const data = billingSnap.data() || {};
    const charge = chargeSnap.exists ? chargeSnap.data() : null;
    const charged = charge ? charge.amount || 0 : 0;

    const decision = billing.refundDecision({
      charged,
      acceptedAtMs: charge ? billing.toMillis(charge.createdAt) : null,
      cancelledAtMs: Date.now(),
      refundMonth: data.refundMonth,
      refundsThisMonth: data.refundsThisMonth,
    });
    const update = {
      stats: { cancelledAfterAccept: FieldValue.increment(1) },
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (decision.refund) {
      const { debt, blocked } = billing.reduceDebt(data.debt, charged);
      Object.assign(update, {
        debt,
        refundMonth: decision.refundMonth,
        refundsThisMonth: decision.refundsThisMonth,
      });
      if (!blocked) {
        update.blockedSince = null;
        tx.update(db.collection('drivers').doc(driverId), { billingBlocked: false });
      }
      tx.set(refundRef, {
        type: 'refund',
        amount: charged,
        requestId: rid,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
    tx.set(ref, update, { merge: true });
  });
});

/** Compteur anti-fraude : conversations ouvertes avec un livreur. */
exports.onConversationCreated = onDocumentCreated('conversations/{cid}', async (event) => {
  const conv = event.data && event.data.data();
  const driverId = (conv && conv.driverId) || event.params.cid.split('_')[1];
  if (!driverId) return;
  await billingRef(driverId).set({ stats: { conversations: FieldValue.increment(1) } }, { merge: true });
});

/** Compteur anti-fraude : signalements de clients. */
exports.onReportCreated = onDocumentCreated('reports/{rid}', async (event) => {
  const report = event.data && event.data.data();
  if (!report || !report.driverId) return;
  await billingRef(report.driverId).set({ stats: { reports: FieldValue.increment(1) } }, { merge: true });
});

/** Chaque nuit : fin d'essai ou de mois paye -> "a la livraison" ou "expire". */
exports.rolloverSubscriptions = onSchedule(
  { schedule: 'every day 03:00', timeZone: 'Africa/Algiers' },
  async () => {
    const now = Date.now();
    const snap = await db
      .collection('drivers')
      .where('subscriptionEnd', '<=', Timestamp.fromMillis(now))
      .get();
    let changed = 0;
    for (const doc of snap.docs) {
      const driver = doc.data();
      if (!['trial', 'paid'].includes(driver.subscriptionStatus)) continue;
      const debt = ((await billingRef(doc.id).get()).data() || {}).debt || 0;
      const update = billing.rolloverStatus(driver, debt, now);
      if (!update) continue;
      if (update.subscriptionStatus === 'expired' || update.billingBlocked) update.active = false;
      await doc.ref.update(update);
      changed++;
    }
    logger.info(`Bascule des abonnements : ${changed} livreur(s)`);
  },
);

/**
 * Note laissee par un client (ratings/{idDeLaLivraison}, 1 a 5 etoiles) :
 * moyenne publique sur le profil du livreur, compteurs pour l'onglet Suspects,
 * et marque "notee" sur la livraison. Seul le serveur ecrit ces champs.
 */
exports.onRatingCreated = onDocumentCreated('ratings/{rid}', async (event) => {
  const rating = event.data && event.data.data();
  const stars = Number(rating && rating.stars);
  if (!Number.isInteger(stars) || stars < 1 || stars > 5) return;

  // Livreur lu dans la livraison (source de verite), pas dans la note ; la
  // marque "rated" rend le declencheur idempotent s'il est rejoue.
  const reqRef = db.collection('deliveryRequests').doc(event.params.rid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(reqRef);
    const delivery = snap.data();
    if (!delivery || delivery.status !== 'completed' || delivery.rated) return;
    if (delivery.clientId !== rating.clientId || !delivery.driverId) return;

    tx.update(db.collection('drivers').doc(delivery.driverId), {
      ratingCount: FieldValue.increment(1),
      ratingSum: FieldValue.increment(stars),
    });
    tx.set(
      billingRef(delivery.driverId),
      { stats: { ratingCount: FieldValue.increment(1), ratingSum: FieldValue.increment(stars) } },
      { merge: true },
    );
    tx.update(reqRef, { rated: stars });
  });
});
