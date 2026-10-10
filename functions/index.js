/**
 * Wassaly - notifications push aux livreurs (Firebase Cloud Messaging).
 *
 * Trois declencheurs Firestore :
 *   1. nouveau message dans une conversation  -> notifie le destinataire
 *   2. nouvelle demande ouverte d'un client   -> notifie tous les livreurs abonnes
 *   3. nouvelle demande de livraison          -> notifie le livreur concerne
 *
 * Seuls les appareils qui ont enregistre un jeton dans `deviceTokens/{uid}`
 * (l'application ne le fait que pour les livreurs) recoivent une notification.
 *
 * ATTENTION : REGION doit etre la meme region que votre base Firestore
 * (console Firebase > Firestore Database > onglet Donnees : "Emplacement").
 */
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions } = require('firebase-functions/v2');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');

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
  },
  ar: {
    message: (from) => (from ? `رسالة من ${from}` : 'رسالة جديدة'),
    openTitle: 'طلب توصيل جديد',
    openBody: (client, route) =>
      route ? `${client} : ${route}` : `${client} يبحث عن موصّل`,
    directTitle: 'طلب جديد لك',
    directBody: (client) => `${client} أرسل لك طلب توصيل`,
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

/** Livreurs qui voient les demandes ouvertes : abonnement valide + identite verifiee. */
async function subscribedDriverIds() {
  const snap = await db
    .collection('drivers')
    .where('subscriptionEnd', '>', admin.firestore.Timestamp.now())
    .get();
  return snap.docs
    .filter((d) => {
      const x = d.data();
      return (
        ['trial', 'paid'].includes(x.subscriptionStatus) &&
        (x.verificationStatus || 'approved') === 'approved'
      );
    })
    .map((d) => d.id);
}

exports.onNewOpenRequest = onDocumentCreated('openRequests/{rid}', async (event) => {
  const req = event.data && event.data.data();
  if (!req || req.status !== 'open') return;

  const route = [req.pickup && req.pickup.address, req.delivery && req.delivery.address]
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
    if (!req || req.status !== 'pending' || !req.driverId) return;

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
