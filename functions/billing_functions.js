/**
 * Wassaly - Cloud Functions de facturation des livreurs.
 *
 * Toute operation qui touche a l'argent passe par ici : le code de
 * l'application est public, on ne lui fait pas confiance. La logique pure
 * (montants, plafonds, remboursements) est dans billing.js et testee.
 *
 * Appelees par l'application (callable) :
 *   - acceptDelivery   : le livreur accepte une demande directe ;
 *   - takeOpenRequest  : le livreur prend une demande ouverte (le premier l'obtient) ;
 *   - choosePlan       : le livreur choisit sa formule.
 * Declencheurs : remboursement a l'annulation, compteurs anti-fraude.
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
async function readParties(tx, uid, clientId) {
  const [driverSnap, billingSnap, clientUser, driverUser] = await Promise.all([
    tx.get(db.collection('drivers').doc(uid)),
    tx.get(billingRef(uid)),
    tx.get(db.collection('users').doc(clientId)),
    tx.get(db.collection('users').doc(uid)),
  ]);
  if (!driverSnap.exists) throw fail('not-eligible');
  return {
    driver: driverSnap.data(),
    billingData: billingSnap.data() || {},
    clientUser: clientUser.data(),
    driverUser: driverUser.data(),
  };
}

exports.acceptDelivery = onCall(async (request) => {
  const uid = requireUid(request);
  const requestId = String((request.data && request.data.requestId) || '');
  if (!requestId) throw new HttpsError('invalid-argument', 'requestId');

  await db.runTransaction(async (tx) => {
    const reqRef = db.collection('deliveryRequests').doc(requestId);
    const req = (await tx.get(reqRef)).data();
    if (!req || req.driverId !== uid || req.status !== 'pending') throw fail('not-pending');

    const p = await readParties(tx, uid, req.clientId);
    const charged = chargeInTransaction(tx, {
      uid,
      driver: p.driver,
      billingData: p.billingData,
      requestId,
      now: Date.now(),
    });
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

exports.takeOpenRequest = onCall(async (request) => {
  const uid = requireUid(request);
  const openId = String((request.data && request.data.openRequestId) || '');
  if (!openId) throw new HttpsError('invalid-argument', 'openRequestId');

  const deliveryRef = db.collection('deliveryRequests').doc();
  await db.runTransaction(async (tx) => {
    const openRef = db.collection('openRequests').doc(openId);
    const open = (await tx.get(openRef)).data();
    if (!open || open.status !== 'open') throw fail('already-taken');

    const p = await readParties(tx, uid, open.clientId);
    const charged = chargeInTransaction(tx, {
      uid,
      driver: p.driver,
      billingData: p.billingData,
      requestId: deliveryRef.id,
      now: Date.now(),
    });
    tx.set(deliveryRef, {
      clientId: open.clientId,
      driverId: uid,
      clientName: open.clientName || '',
      driverName: p.driver.name || '',
      pickup: open.pickup || {},
      delivery: open.delivery || {},
      note: open.note || '',
      status: 'accepted',
      source: 'open',
      openRequestId: openId,
      charged,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      acceptedAt: FieldValue.serverTimestamp(),
    });
    tx.update(openRef, {
      status: 'taken',
      takenBy: uid,
      takenByName: p.driver.name || '',
      deliveryRequestId: deliveryRef.id,
      updatedAt: FieldValue.serverTimestamp(),
    });
    writeContact(tx, deliveryRef.id, p.clientUser, p.driverUser);
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
