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
