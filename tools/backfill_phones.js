/**
 * Reserve dans la collection `phones` les numeros des comptes crees AVANT la
 * regle d'unicite, et liste les doublons deja presents.
 *
 * A lancer UNE SEULE FOIS, depuis votre ordinateur (non teste : verifiez d'abord
 * sur une copie ou relisez le resultat du mode simulation).
 *
 * Preparation :
 *   1. Console Firebase > Parametres du projet > Comptes de service >
 *      "Generer une nouvelle cle privee" -> enregistrez-la sous tools/serviceAccountKey.json
 *      (NE PAS la partager ni la publier ; ajoutez-la a .gitignore).
 *   2. cd tools && npm init -y && npm install firebase-admin
 *
 * Utilisation :
 *   node backfill_phones.js          # simulation : affiche ce qui serait fait
 *   node backfill_phones.js --apply  # ecrit dans Firestore
 */
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json')),
});
const db = admin.firestore();
const apply = process.argv.includes('--apply');

(async () => {
  const users = await db.collection('users').get();
  const byPhone = new Map();

  for (const doc of users.docs) {
    const phone = String(doc.data().phone || '').replace(/[\s.\-]/g, '');
    if (!/^0[5-7][0-9]{8}$/.test(phone)) {
      console.log(`Numero invalide ignore : ${doc.id} -> "${doc.data().phone}"`);
      continue;
    }
    if (!byPhone.has(phone)) byPhone.set(phone, []);
    byPhone.get(phone).push({ uid: doc.id, name: doc.data().name, role: doc.data().role });
  }

  let created = 0;
  for (const [phone, list] of byPhone) {
    if (list.length > 1) {
      console.log(`DOUBLON ${phone} :`, list.map((u) => `${u.name} (${u.role}, ${u.uid})`).join(' | '));
    }
    // Le numero est reserve au premier compte trouve ; a vous de traiter les doublons.
    const ref = db.collection('phones').doc(phone);
    if ((await ref.get()).exists) continue;
    if (apply) {
      await ref.set({ uid: list[0].uid, createdAt: admin.firestore.FieldValue.serverTimestamp() });
    }
    created++;
  }
  console.log(`${apply ? 'Reserves' : 'A reserver (simulation)'} : ${created} numero(s) sur ${byPhone.size}.`);
})();
