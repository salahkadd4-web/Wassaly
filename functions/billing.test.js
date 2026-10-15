// Tests de la logique de facturation : `node --test` dans le dossier functions.
const test = require('node:test');
const assert = require('node:assert/strict');
const b = require('./billing');

const NOW = Date.UTC(2026, 9, 12, 10, 0, 0);
const DAY = 24 * 60 * 60 * 1000;
const HOUR = 60 * 60 * 1000;

const driver = (over = {}) => ({
  subscriptionStatus: 'trial',
  subscriptionEnd: NOW + 10 * DAY,
  verificationStatus: 'approved',
  ...over,
});

test('essai en cours : eligible, pas facture', () => {
  const d = driver();
  assert.equal(b.isEligible(d, NOW), true);
  assert.equal(b.isPerDeliveryMode(d, NOW), false);
});

test('essai termine sans formule : non eligible', () => {
  const d = driver({ subscriptionEnd: NOW - DAY });
  assert.equal(b.isEligible(d, NOW), false);
  assert.equal(b.isPerDeliveryMode(d, NOW), false);
});

test('essai termine avec "per_delivery" : eligible et facture avant le job quotidien', () => {
  const d = driver({ subscriptionEnd: NOW - DAY, plan: 'per_delivery' });
  assert.equal(b.isEligible(d, NOW), true);
  assert.equal(b.isPerDeliveryMode(d, NOW), true);
});

test('mois paye en cours avec "per_delivery" choisi pour la suite : pas facture', () => {
  const d = driver({ subscriptionStatus: 'paid', plan: 'per_delivery' });
  assert.equal(b.isPerDeliveryMode(d, NOW), false);
});

test('a la livraison bloque, suspendu ou non verifie : non eligible', () => {
  assert.equal(b.isEligible(driver({ subscriptionStatus: 'per_delivery', billingBlocked: true }), NOW), false);
  assert.equal(b.isEligible(driver({ subscriptionStatus: 'per_delivery' }), NOW), true);
  assert.equal(b.isEligible(driver({ subscriptionStatus: 'suspended' }), NOW), false);
  assert.equal(b.isEligible(driver({ verificationStatus: 'pending' }), NOW), false);
});

test('Timestamp Firestore accepte', () => {
  const d = driver({ subscriptionEnd: { toMillis: () => NOW + DAY } });
  assert.equal(b.isEligible(d, NOW), true);
});

test('debit : +50 DA, blocage a 1 000 DA, refus au-dela', () => {
  assert.deepEqual(b.applyCharge(0), { debt: 50, blocked: false });
  assert.deepEqual(b.applyCharge(undefined), { debt: 50, blocked: false });
  assert.deepEqual(b.applyCharge(900), { debt: 950, blocked: false });
  assert.deepEqual(b.applyCharge(950), { debt: 1000, blocked: true });
  assert.equal(b.applyCharge(1000), null);
});

test('20 livraisons atteignent le plafond', () => {
  let debt = 0;
  for (let i = 0; i < 20; i++) debt = b.applyCharge(debt).debt;
  assert.equal(debt, b.DEBT_LIMIT_DA);
  assert.equal(b.applyCharge(debt), null);
});

test('remboursement dans les 2 h, compteur du mois', () => {
  const r = b.refundDecision({
    charged: 50,
    acceptedAtMs: NOW - HOUR,
    cancelledAtMs: NOW,
    refundMonth: '2026-10',
    refundsThisMonth: 1,
  });
  assert.deepEqual(r, { refund: true, refundMonth: '2026-10', refundsThisMonth: 2 });
});

test('pas de remboursement apres 2 h', () => {
  const r = b.refundDecision({
    charged: 50,
    acceptedAtMs: NOW - 3 * HOUR,
    cancelledAtMs: NOW,
    refundMonth: '2026-10',
    refundsThisMonth: 0,
  });
  assert.equal(r.refund, false);
  assert.equal(r.refundsThisMonth, 0);
});

test('pas de remboursement au-dela de 3 par mois, remis a zero le mois suivant', () => {
  const full = { charged: 50, acceptedAtMs: NOW - HOUR, cancelledAtMs: NOW, refundsThisMonth: 3 };
  assert.equal(b.refundDecision({ ...full, refundMonth: '2026-10' }).refund, false);
  const next = b.refundDecision({ ...full, refundMonth: '2026-09' });
  assert.deepEqual(next, { refund: true, refundMonth: '2026-10', refundsThisMonth: 1 });
});

test('pas de remboursement si rien n\'a ete debite', () => {
  const r = b.refundDecision({ charged: 0, acceptedAtMs: NOW, cancelledAtMs: NOW, refundsThisMonth: 0 });
  assert.equal(r.refund, false);
});

test('mois en heure d\'Alger', () => {
  // 31 octobre 23:30 UTC = 1er novembre 00:30 a Alger.
  assert.equal(b.monthKey(Date.UTC(2026, 9, 31, 23, 30)), '2026-11');
  assert.equal(b.monthKey(Date.UTC(2026, 9, 31, 22, 30)), '2026-10');
});

test('reduction de dette jamais negative', () => {
  assert.deepEqual(b.reduceDebt(1000, 50), { debt: 950, blocked: false });
  assert.deepEqual(b.reduceDebt(100, 500), { debt: 0, blocked: false });
});

test('bascule de fin de periode', () => {
  assert.equal(b.rolloverStatus(driver(), 0, NOW), null);
  assert.deepEqual(b.rolloverStatus(driver({ subscriptionEnd: NOW - 1 }), 0, NOW), {
    subscriptionStatus: 'expired',
  });
  assert.deepEqual(
    b.rolloverStatus(driver({ subscriptionEnd: NOW - 1, plan: 'per_delivery' }), 1000, NOW),
    { subscriptionStatus: 'per_delivery', billingBlocked: true },
  );
  assert.equal(b.rolloverStatus(driver({ subscriptionStatus: 'per_delivery' }), 0, NOW), null);
});

test('changement de formule', () => {
  assert.deepEqual(b.planChange(driver(), 0, 'per_delivery', NOW), { update: { plan: 'per_delivery' } });
  assert.deepEqual(b.planChange(driver({ subscriptionStatus: 'expired' }), 0, 'per_delivery', NOW), {
    update: { plan: 'per_delivery', subscriptionStatus: 'per_delivery', billingBlocked: false },
  });
  assert.deepEqual(b.planChange(driver({ subscriptionStatus: 'expired' }), 0, 'monthly', NOW), {
    update: { plan: 'monthly' },
  });
  assert.deepEqual(b.planChange(driver({ subscriptionStatus: 'per_delivery' }), 300, 'monthly', NOW), {
    update: { plan: 'monthly' },
  });
  assert.deepEqual(b.planChange(driver({ subscriptionStatus: 'suspended' }), 0, 'monthly', NOW), {
    error: 'not-eligible',
  });
  assert.deepEqual(b.planChange(driver(), 0, 'gratuit', NOW), { error: 'invalid-plan' });
});

test('prix de course : 100 a 300 DA par pas de 10', () => {
  for (const p of [100, 110, 150, 200, 290, 300]) assert.equal(b.isValidPrice(p), true, String(p));
  for (const p of [0, 90, 105, 310, 1000, '200', 200.5, null, undefined]) {
    assert.equal(b.isValidPrice(p), false, String(p));
  }
});

test('negociation : seul celui qui n a pas propose peut accepter', () => {
  assert.equal(b.canAgree('driver', false), true); // le client accepte l'offre du livreur
  assert.equal(b.canAgree('driver', true), false); // le livreur ne s'accepte pas lui-meme
  assert.equal(b.canAgree('client', true), true);
  assert.equal(b.canAgree('client', false), false);
  assert.equal(b.canAgree(undefined, true), false);
});
