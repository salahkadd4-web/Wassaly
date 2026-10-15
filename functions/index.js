/**
 * Wassaly - Cloud Functions.
 *
 * OPTIONNEL : necessite l'offre Firebase Blaze (carte bancaire). Wassaly
 * fonctionne sans : la facturation, la negociation, les accords et les notes
 * sont faits par l'application et verifies par firestore.rules. Ces
 * fonctions n'ajoutent que les notifications push (application fermee),
 * aux livreurs et aux clients (Firebase Cloud Messaging).
 *
 * Notifications, declencheurs Firestore :
 *   1. nouveau message dans une conversation  -> notifie le destinataire
 *   2. nouvelle demande ouverte d'un client   -> notifie tous les livreurs abonnes
 *   3. nouvelle demande de livraison          -> notifie le livreur concerne ;
 *      accord sur l'offre d'une demande ouverte -> notifie celui qui avait propose
 *   4. negociation d'une demande directe (proposition, contre-proposition,
 *      accord, refus), fin de livraison         -> notifie l'autre partie
 *   5. offres sur une demande ouverte (nouvelle offre, contre-proposition,
 *      refus)                                   -> notifie l'autre partie
 *
 * Seuls les appareils qui ont enregistre un jeton dans `deviceTokens/{uid}`
 * recoivent une notification (clients et livreurs).
 *
 * ATTENTION : REGION doit etre la meme region que votre base Firestore
 * (console Firebase > Firestore Database > onglet Donnees : "Emplacement"),
 * et la meme que AppConfig.functionsRegion dans l'application.
 */
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions } = require('firebase-functions/v2');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const billing = require('./billing');

admin.initializeApp();
const db = admin.firestore();

const REGION = 'europe-west1'; // <-- a adapter a la region de Firestore
setGlobalOptions({ region: REGION, maxInstances: 5 });

// Doit rester identique a MainActivity.kt et AndroidManifest.xml.
const CHANNEL_ID = 'wassaly_high';

const BAD_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

// ---------------------------------------------------------------- Textes

const TEXTS = {
  fr: {
    message: (from) => (from ? `Message de ${from}` : 'Nouveau message'),
    openTitle: 'Nouvelle demande de livraison',
    openBody: (client, route) =>
      route ? `${client} : ${route}` : `${client} cherche un livreur`,
    directTitle: 'Nouvelle demande pour vous',
    directBody: (client) => `${client} vous a envoye une demande de livraison`,
    acceptedTitle: 'Demande acceptee',
    acceptedBody: (driver, price) =>
      price ? `${driver} arrive. Prix convenu : ${price} DA` : `${driver} a accepte votre demande`,
    takenTitle: 'Un livreur a pris votre course',
    rejectedTitle: 'Demande refusee',
    rejectedBody: (driver) => `${driver} ne peut pas faire cette livraison. Essayez un autre livreur.`,
    completedTitle: 'Livraison terminee',
    completedBody: (driver) => `Comment s'est passee la livraison avec ${driver} ? Laissez une note.`,
    cancelledTitle: 'Demande annulee',
    cancelledBody: (client) => `${client} a annule sa demande`,
    priceTitle: 'Proposition de prix',
    priceBody: (from, price) => `${from} propose ${price} DA`,
    agreedTitle: 'Accord conclu',
    agreedBody: (other, price) =>
      `${other} est d'accord pour ${price} DA. Les coordonnees sont maintenant visibles.`,
    newOfferTitle: 'Nouvelle offre pour votre course',
    refusedTitle: 'Proposition refusee',
    refusedBody: (other) => `${other} a refuse. La negociation est terminee.`,
  },
  ar: {
    message: (from) => (from ? `رسالة من ${from}` : 'رسالة جديدة'),
    openTitle: 'طلب توصيل جديد',
    openBody: (client, route) =>
      route ? `${client} : ${route}` : `${client} يبحث عن موصّل`,
    directTitle: 'طلب جديد لك',
    directBody: (client) => `${client} أرسل لك طلب توصيل`,
    acceptedTitle: 'تم قبول طلبك',
    acceptedBody: (driver, price) =>
      price ? `${driver} في الطريق. السعر المتفق عليه: ${price} دج` : `${driver} قبل طلبك`,
    takenTitle: 'موصّل أخذ طلبك',
    rejectedTitle: 'تم رفض الطلب',
    rejectedBody: (driver) => `${driver} لا يستطيع القيام بهذا التوصيل. جرّب موصّلًا آخر.`,
    completedTitle: 'اكتمل التوصيل',
    completedBody: (driver) => `كيف كان التوصيل مع ${driver}؟ اترك تقييمًا.`,
    cancelledTitle: 'تم إلغاء الطلب',
    cancelledBody: (client) => `${client} ألغى طلبه`,
    priceTitle: 'اقتراح سعر',
    priceBody: (from, price) => `${from} يقترح ${price} دج`,
    agreedTitle: 'تم الاتفاق',
    agreedBody: (other, price) => `${other} موافق على ${price} دج. أصبحت معلومات الاتصال ظاهرة.`,
    newOfferTitle: 'عرض جديد لطلبك',
    refusedTitle: 'تم رفض الاقتراح',
    refusedBody: (other) => `${other} رفض. انتهى التفاوض.`,
  },
};

const clip = (s, n) => {
  const t = String(s || '').trim();
  return t.length > n ? `${t.slice(0, n - 1)}…` : t;
};

// ---------------------------------------------------------------- Envoi

/**
 * Envoie une notification aux appareils des utilisateurs [uids].
 * [build] recoit la langue ('fr' | 'ar') et renvoie { title, body }.
 */
async function notifyUsers(uids, build, data) {
  const unique = [...new Set(uids)].filter(Boolean);
  if (unique.length === 0) return;

  // Jetons groupes par langue ; on garde le proprietaire pour nettoyer.
  const byLang = { fr: [], ar: [] };
  const owner = new Map(); // jeton -> reference du document

  for (let i = 0; i < unique.length; i += 100) {
    const refs = unique
      .slice(i, i + 100)
      .map((uid) => db.collection('deviceTokens').doc(uid));
    const snaps = await db.getAll(...refs);
    for (const snap of snaps) {
      if (!snap.exists) continue;
      const { tokens = [], lang = 'fr' } = snap.data();
      for (const token of tokens) {
        (byLang[lang === 'ar' ? 'ar' : 'fr']).push(token);
        owner.set(token, snap.ref);
      }
    }
  }

  const dead = [];
  for (const lang of ['fr', 'ar']) {
    const tokens = byLang[lang];
    const { title, body } = build(lang);
    for (let i = 0; i < tokens.length; i += 500) {
      const batch = tokens.slice(i, i + 500);
      const res = await admin.messaging().sendEachForMulticast({
        tokens: batch,
        notification: { title, body },
        data: Object.fromEntries(
          Object.entries(data).map(([k, v]) => [k, String(v)]),
        ),
        android: {
          priority: 'high',
          notification: { channelId: CHANNEL_ID },
        },
      });
      res.responses.forEach((r, idx) => {
        if (!r.success && BAD_TOKEN_CODES.has(r.error && r.error.code)) {
          dead.push(batch[idx]);
        } else if (!r.success) {
          logger.warn('Envoi echoue', r.error && r.error.code);
        }
      });
    }
  }

  // Nettoyage des jetons devenus invalides (application desinstallee...).
  await Promise.all(
    dead.map((token) =>
      owner
        .get(token)
        .update({ tokens: admin.firestore.FieldValue.arrayRemove(token) })
        .catch(() => {}),
    ),
  );
  logger.info(`Notification "${data.type}" : ${owner.size} appareil(s)`);
}

// ---------------------------------------------------------------- 1. Messages

exports.onNewMessage = onDocumentCreated(
  'conversations/{cid}/messages/{mid}',
  async (event) => {
    const msg = event.data && event.data.data();
    if (!msg) return;

    const convSnap = await db.collection('conversations').doc(event.params.cid).get();
    const conv = convSnap.data();
    if (!conv) return;

    const fromClient = msg.senderId === conv.clientId;
    const recipient = fromClient ? conv.driverId : conv.clientId;
    const senderName = fromClient ? conv.clientName : conv.driverName;

    await notifyUsers(
      [recipient],
      (lang) => ({
        title: TEXTS[lang].message(senderName),
        body: clip(msg.text, 120),
      }),
      { type: 'message', conversationId: event.params.cid },
    );
  },
);

// ---------------------------------------------------------------- 2. Demandes ouvertes

/** Livreurs qui voient les demandes ouvertes (meme regle que firestore.rules). */
async function subscribedDriverIds() {
  const now = Date.now();
  const snap = await db.collection('drivers').get();
  return snap.docs.filter((d) => billing.isEligible(d.data(), now)).map((d) => d.id);
}

exports.onNewOpenRequest = onDocumentCreated('openRequests/{rid}', async (event) => {
  const req = event.data && event.data.data();
  if (!req || req.status !== 'open') return;

  // Quartiers seulement : l'adresse exacte reste privee jusqu'a l'accord.
  const route = [req.pickupArea, req.deliveryArea]
    .filter(Boolean)
    .map((a) => clip(a, 40))
    .join(' > ');
  const client = req.clientName || '';

  await notifyUsers(
    await subscribedDriverIds(),
    (lang) => ({
      title: TEXTS[lang].openTitle,
      body: clip(TEXTS[lang].openBody(client, route), 140),
    }),
    { type: 'open_request', requestId: event.params.rid },
  );
});

// ---------------------------------------------------------------- 3. Demande directe

exports.onNewDeliveryRequest = onDocumentCreated(
  'deliveryRequests/{rid}',
  async (event) => {
    const req = event.data && event.data.data();
    if (!req || !req.driverId) return;

    // Accord sur l'offre d'une demande ouverte (creee deja acceptee) : on
    // previent celui qui avait fait la derniere proposition.
    if (req.status === 'accepted' && req.source === 'open') {
      const proposerIsDriver = req.lastBy === 'driver';
      const other = proposerIsDriver ? req.clientName : req.driverName;
      await notifyUsers(
        [proposerIsDriver ? req.driverId : req.clientId],
        (lang) => ({
          title: TEXTS[lang].agreedTitle,
          body: TEXTS[lang].agreedBody(other || '', req.price),
        }),
        { type: 'request_update', requestId: event.params.rid },
      );
      return;
    }
    if (req.status !== 'pending') return;

    await notifyUsers(
      [req.driverId],
      (lang) => ({
        title: TEXTS[lang].directTitle,
        body: TEXTS[lang].directBody(req.clientName || ''),
      }),
      { type: 'delivery_request', requestId: event.params.rid },
    );
  },
);

// ---------------------------------------------------------------- 4. Suivi d'une demande

exports.onDeliveryStatusChanged = onDocumentUpdated('deliveryRequests/{rid}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!before || !after) return;

  const driver = after.driverName || '';
  const client = after.clientName || '';
  const forClient = { type: 'request_update', requestId: event.params.rid };
  const forDriver = { type: 'delivery_request', requestId: event.params.rid };
  const send = (uid, title, body, data) =>
    notifyUsers([uid], (lang) => ({ title: title(lang), body: body(lang) }), data);

  // Negociation : nouvelle proposition (prix ou auteur change).
  if (
    after.status === 'negotiating' &&
    (before.price !== after.price || before.lastBy !== after.lastBy)
  ) {
    if (after.lastBy === 'driver') {
      await send(after.clientId, (l) => TEXTS[l].priceTitle,
        (l) => TEXTS[l].priceBody(driver, after.price), forClient);
    } else {
      await send(after.driverId, (l) => TEXTS[l].priceTitle,
        (l) => TEXTS[l].priceBody(client, after.price), forDriver);
    }
    return;
  }
  if (before.status === after.status) return;

  switch (after.status) {
    case 'accepted': {
      // Accord : celui qui a propose le prix apprend que l'autre l'accepte.
      const proposerIsDriver = after.lastBy === 'driver';
      await send(
        proposerIsDriver ? after.driverId : after.clientId,
        (l) => TEXTS[l].agreedTitle,
        (l) => TEXTS[l].agreedBody(proposerIsDriver ? client : driver, after.price),
        proposerIsDriver ? forDriver : forClient,
      );
      break;
    }
    case 'rejected':
      await send(after.clientId, (l) => TEXTS[l].rejectedTitle, (l) => TEXTS[l].rejectedBody(driver), forClient);
      break;
    case 'completed':
      await send(after.clientId, (l) => TEXTS[l].completedTitle, (l) => TEXTS[l].completedBody(driver), forClient);
      break;
    case 'cancelled':
      await send(after.driverId, (l) => TEXTS[l].cancelledTitle, (l) => TEXTS[l].cancelledBody(client), forDriver);
      break;
  }
});

// ---------------------------------------------------------------- 5. Offres (demandes ouvertes)

/** Nom du client d'une demande ouverte (pour les notifications au livreur). */
async function openRequestOf(openId) {
  return (await db.collection('openRequests').doc(openId).get()).data() || {};
}

exports.onOfferCreated = onDocumentCreated('openRequests/{rid}/offers/{driverId}', async (event) => {
  const offer = event.data && event.data.data();
  if (!offer) return;
  const open = await openRequestOf(event.params.rid);
  if (!open.clientId) return;
  await notifyUsers(
    [open.clientId],
    (lang) => ({
      title: TEXTS[lang].newOfferTitle,
      body: TEXTS[lang].priceBody(offer.driverName || '', offer.price),
    }),
    { type: 'offer', requestId: event.params.rid },
  );
});

exports.onOfferUpdated = onDocumentUpdated('openRequests/{rid}/offers/{driverId}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!before || !after) return;
  const open = await openRequestOf(event.params.rid);
  const driverName = after.driverName || '';
  const clientName = open.clientName || '';
  const data = { type: 'offer', requestId: event.params.rid };

  if (after.status === 'open' && (before.price !== after.price || before.lastBy !== after.lastBy)) {
    const toDriver = after.lastBy === 'client';
    await notifyUsers(
      [toDriver ? after.driverId : open.clientId],
      (lang) => ({
        title: TEXTS[lang].priceTitle,
        body: TEXTS[lang].priceBody(toDriver ? clientName : driverName, after.price),
      }),
      data,
    );
    return;
  }
  if (before.status === 'open' && after.status === 'refused') {
    const toDriver = after.refusedBy === 'client';
    await notifyUsers(
      [toDriver ? after.driverId : open.clientId],
      (lang) => ({
        title: TEXTS[lang].refusedTitle,
        body: TEXTS[lang].refusedBody(toDriver ? clientName : driverName),
      }),
      data,
    );
  }
});
