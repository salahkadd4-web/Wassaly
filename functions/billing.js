/**
 * Wassaly - regles de facturation des livreurs (logique pure, sans Firebase).
 *
 * Formules apres l'essai gratuit :
 *   - "monthly"      : 1 000 DA / 30 jours, valide par l'admin ;
 *   - "per_delivery" : 50 DA par livraison acceptee, ajoutes a une dette.
 *     A 1 000 DA de dette, le livreur est bloque jusqu'au paiement.
 *
 * Doit rester aligne sur lib/core/constants/app_config.dart,
 * lib/models/driver_profile.dart et firestore.rules (fonction driverEligible).
 */

const PER_DELIVERY_PRICE_DA = 50;

/** Prix d'une course negociee : de 100 a 300 DA, par pas de 10 DA. */
const PRICE_MIN_DA = 100;
const PRICE_MAX_DA = 300;
const PRICE_STEP_DA = 10;
const DEBT_LIMIT_DA = 1000;
const REFUND_WINDOW_MS = 2 * 60 * 60 * 1000;
const MAX_REFUNDS_PER_MONTH = 3;

/** Timestamp Firestore, Date, nombre (ms) ou null -> millisecondes (ou null). */
function toMillis(value) {
  if (value == null) return null;
  if (typeof value === 'number') return value;
  if (value instanceof Date) return value.getTime();
  if (typeof value.toMillis === 'function') return value.toMillis();
  return null;
}

/** Mois civil en heure d'Alger (UTC+1, sans heure d'ete) : "2026-10". */
function monthKey(ms) {
  const d = new Date(ms + 60 * 60 * 1000);
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, '0')}`;
}

function periodRunning(driver, nowMs) {
  const end = toMillis(driver.subscriptionEnd);
  return ['trial', 'paid'].includes(driver.subscriptionStatus) && end != null && end > nowMs;
}

/**
 * Le livreur est facture a la livraison : formule active, ou essai / mois
 * paye termine alors qu'il a choisi "per_delivery" (avant le job quotidien).
 */
function isPerDeliveryMode(driver, nowMs) {
  if (driver.subscriptionStatus === 'per_delivery') return true;
  return (
    ['trial', 'paid'].includes(driver.subscriptionStatus) &&
    !periodRunning(driver, nowMs) &&
    driver.plan === 'per_delivery'
  );
}

/** Le livreur peut travailler : visible, voit les demandes ouvertes, accepte. */
function isEligible(driver, nowMs) {
  if ((driver.verificationStatus || 'approved') !== 'approved') return false;
  if (driver.subscriptionStatus === 'suspended') return false;
  if (periodRunning(driver, nowMs)) return true;
  return isPerDeliveryMode(driver, nowMs) && driver.billingBlocked !== true;
}

/**
 * Debit d'une livraison. Retourne null si la dette a deja atteint le plafond.
 */
function applyCharge(debt) {
  const current = debt || 0;
  if (current >= DEBT_LIMIT_DA) return null;
  const next = current + PER_DELIVERY_PRICE_DA;
  return { debt: next, blocked: next >= DEBT_LIMIT_DA };
}

/**
 * Remboursement quand le client annule une livraison acceptee : seulement si
 * elle a ete debitee, annulee moins de 2 h apres l'acceptation, et moins de
 * 3 remboursements ce mois-ci.
 */
function refundDecision({ charged, acceptedAtMs, cancelledAtMs, refundMonth, refundsThisMonth }) {
  const month = monthKey(cancelledAtMs);
  const used = refundMonth === month ? refundsThisMonth || 0 : 0;
  const refund =
    (charged || 0) > 0 &&
    acceptedAtMs != null &&
    cancelledAtMs - acceptedAtMs <= REFUND_WINDOW_MS &&
    used < MAX_REFUNDS_PER_MONTH;
  return { refund, refundMonth: month, refundsThisMonth: refund ? used + 1 : used };
}

/** Prix de course valide : entier, entre 100 et 300 DA, multiple de 10. */
function isValidPrice(price) {
  return (
    Number.isInteger(price) &&
    price >= PRICE_MIN_DA &&
    price <= PRICE_MAX_DA &&
    price % PRICE_STEP_DA === 0
  );
}

/**
 * Negociation : qui peut accepter le prix en cours ? Celui qui ne l'a pas
 * propose (lastBy = 'driver' -> le client, lastBy = 'client' -> le livreur).
 */
function canAgree(lastBy, callerIsDriver) {
  if (lastBy === 'driver') return !callerIsDriver;
  if (lastBy === 'client') return callerIsDriver;
  return false;
}

/** Dette apres un remboursement ou un paiement (jamais negative). */
function reduceDebt(debt, amount) {
  const next = Math.max(0, (debt || 0) - amount);
  return { debt: next, blocked: next >= DEBT_LIMIT_DA };
}

/**
 * Fin d'essai ou de mois paye : nouveau statut, ou null si rien ne change.
 */
function rolloverStatus(driver, debt, nowMs) {
  if (!['trial', 'paid'].includes(driver.subscriptionStatus)) return null;
  if (periodRunning(driver, nowMs)) return null;
  if (driver.plan === 'per_delivery') {
    return { subscriptionStatus: 'per_delivery', billingBlocked: (debt || 0) >= DEBT_LIMIT_DA };
  }
  return { subscriptionStatus: 'expired' };
}

/**
 * Changement de formule demande par le livreur. Retourne les champs a ecrire
 * sur drivers/{uid}, ou { error } si le changement est refuse.
 *   - essai / mois paye en cours : la formule s'appliquera a la fin ;
 *   - expire : "per_delivery" demarre tout de suite, "monthly" attend le paiement ;
 *   - a la livraison : "monthly" attend le paiement dette + 1 000 DA.
 */
function planChange(driver, debt, plan, nowMs) {
  if (!['monthly', 'per_delivery'].includes(plan)) return { error: 'invalid-plan' };
  if (driver.subscriptionStatus === 'suspended') return { error: 'not-eligible' };
  if (periodRunning(driver, nowMs) || driver.subscriptionStatus === 'per_delivery') {
    return { update: { plan } };
  }
  if (plan === 'per_delivery') {
    return {
      update: {
        plan,
        subscriptionStatus: 'per_delivery',
        billingBlocked: (debt || 0) >= DEBT_LIMIT_DA,
      },
    };
  }
  return { update: { plan } };
}

module.exports = {
  PER_DELIVERY_PRICE_DA,
  PRICE_MIN_DA,
  PRICE_MAX_DA,
  PRICE_STEP_DA,
  DEBT_LIMIT_DA,
  REFUND_WINDOW_MS,
  MAX_REFUNDS_PER_MONTH,
  toMillis,
  monthKey,
  isPerDeliveryMode,
  isEligible,
  applyCharge,
  isValidPrice,
  canAgree,
  refundDecision,
  reduceDebt,
  rolloverStatus,
  planChange,
};
