/**
 * Retire les numeros de telephone des documents lisibles par d'autres
 * utilisateurs, crees AVANT la facturation des livreurs :
 *   - drivers/{uid}.phone
 *   - deliveryRequests/{id}.clientPhone
 *   - openRequests/{id}.clientPhone
 * Le numero reste dans users/{uid} (prive). Pour les livraisons deja
 * acceptees ou terminees, il est recopie dans deliveryRequests/{id}/private/contact
 * pour que client et livreur se joignent toujours.
 *
 * A lancer UNE SEULE FOIS, depuis votre ordinateur, apres le deploiement des
 * nouvelles regles (meme preparation que backfill_phones.js :
 * tools/serviceAccountKey.json + npm install firebase-admin dans tools).
 *
 * Utilisation :
 *   node strip_public_phones.js          # simulation : affiche ce qui serait fait
 *   node strip_public_phones.js --apply  # ecrit dans Firestore
 */
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json')),
});
const db = admin.firestore();
const { FieldValue } = admin.firestore;
const apply = process.argv.includes('--apply');

async function userPhone(uid, cache) {
  if (!cache.has(uid)) {
    const snap = await db.collection('users').doc(uid).get();
    cache.set(uid, (snap.data() || {}).phone || '');
  }
  return cache.get(uid);
}

(async () => {
  const phones = new Map();
  let count = 0;

  for (const doc of (await db.collection('drivers').get()).docs) {
    if (!('phone' in doc.data())) continue;
    if (apply) await doc.ref.update({ phone: FieldValue.delete() });
    count++;
  }
  console.log(`drivers : ${count} numero(s) ${apply ? 'retire(s)' : 'a retirer'}.`);

  count = 0;
  let contacts = 0;
  for (const doc of (await db.collection('deliveryRequests').get()).docs) {
    const r = doc.data();
    if (['accepted', 'completed'].includes(r.status)) {
      const contactRef = doc.ref.collection('private').doc('contact');
      if (!(await contactRef.get()).exists) {
        if (apply) {
          await contactRef.set({
            clientPhone: await userPhone(r.clientId, phones),
            driverPhone: await userPhone(r.driverId, phones),
          });
        }
        contacts++;
      }
    }
    if (!('clientPhone' in r)) continue;
    if (apply) await doc.ref.update({ clientPhone: FieldValue.delete() });
    count++;
  }
  console.log(`deliveryRequests : ${count} numero(s) ${apply ? 'retire(s)' : 'a retirer'}, ` +
    `${contacts} contact(s) ${apply ? 'cree(s)' : 'a creer'}.`);

  count = 0;
  for (const doc of (await db.collection('openRequests').get()).docs) {
    if (!('clientPhone' in doc.data())) continue;
    if (apply) await doc.ref.update({ clientPhone: FieldValue.delete() });
    count++;
  }
  console.log(`openRequests : ${count} numero(s) ${apply ? 'retire(s)' : 'a retirer'}.`);
  if (!apply) console.log('Simulation terminee. Relancez avec --apply pour ecrire.');
})();
