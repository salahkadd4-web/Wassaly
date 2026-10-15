/**
 * Wassaly - eligibilite d'un livreur (logique pure, sans Firebase), utilisee
 * par les notifications push pour savoir qui previent d'une demande ouverte.
 *
 * La facturation elle-meme (50 DA a l'accord, plafond de 1 000 DA) est faite
 * par l'application et verifiee par firestore.rules ; cette logique doit
 * rester alignee sur lib/models/driver_profile.dart et la fonction
 * driverEligible de firestore.rules.
 */

/** Timestamp Firestore, Date, nombre (ms) ou null -> millisecondes (ou null). */
function toMillis(value) {
  if (value == null) return null;
  if (typeof value === 'number') return value;
  if (value instanceof Date) return value.getTime();
  if (typeof value.toMillis === 'function') return value.toMillis();
  return null;
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

module.exports = {
  toMillis,
  isPerDeliveryMode,
  isEligible,
};
