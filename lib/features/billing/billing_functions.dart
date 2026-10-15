import 'package:cloud_functions/cloud_functions.dart';

import '../../l10n/app_localizations.dart';

/// Refus metier renvoye par une Cloud Function de facturation.
enum BillingRefusal {
  /// La dette de 1 000 DA est atteinte : il faut payer avant d'accepter.
  debtLimit,

  /// Abonnement expire, suspendu ou piece d'identite non validee.
  notEligible,

  /// La demande n'est plus en attente (annulee par le client...).
  notPending,

  /// Un autre livreur a obtenu la demande ouverte avant vous.
  alreadyTaken,

  /// Ce n'est pas a vous d'accepter (vous avez fait la derniere proposition).
  notYourTurn,

  /// Le client voulait conclure, mais le livreur ne peut plus travailler.
  driverUnavailable,

  /// Reseau ou erreur inattendue.
  unknown,
}

class BillingException implements Exception {
  const BillingException(this.refusal);

  final BillingRefusal refusal;

  static BillingRefusal _parse(FirebaseFunctionsException e) {
    final details = e.details;
    final reason = details is Map ? details['reason'] : e.message;
    switch (reason) {
      case 'debt-limit':
        return BillingRefusal.debtLimit;
      case 'not-eligible':
        return BillingRefusal.notEligible;
      case 'not-pending':
        return BillingRefusal.notPending;
      case 'already-taken':
        return BillingRefusal.alreadyTaken;
      case 'not-your-turn':
        return BillingRefusal.notYourTurn;
      case 'driver-unavailable':
        return BillingRefusal.driverUnavailable;
    }
    return BillingRefusal.unknown;
  }

  /// Message a afficher a l'utilisateur.
  String message(AppLocalizations t) {
    switch (refusal) {
      case BillingRefusal.debtLimit:
        return t.billingErrorDebtLimit;
      case BillingRefusal.notEligible:
        return t.billingErrorNotEligible;
      case BillingRefusal.notPending:
        return t.billingErrorNotPending;
      case BillingRefusal.alreadyTaken:
        return t.billingErrorAlreadyTaken;
      case BillingRefusal.notYourTurn:
        return t.billingErrorNotYourTurn;
      case BillingRefusal.driverUnavailable:
        return t.billingErrorDriverUnavailable;
      case BillingRefusal.unknown:
        return t.genericError;
    }
  }
}

/// Actions qui touchent a la facturation : executees par le serveur
/// (functions/billing_functions.js), jamais directement dans Firestore.
class BillingFunctions {
  BillingFunctions(this._functions);

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> _call(String name, Map<String, dynamic> data) async {
    try {
      final result = await _functions.httpsCallable(name).call<dynamic>(data);
      final value = result.data;
      return value is Map ? Map<String, dynamic>.from(value) : const {};
    } on FirebaseFunctionsException catch (e) {
      throw BillingException(BillingException._parse(e));
    } catch (_) {
      throw const BillingException(BillingRefusal.unknown);
    }
  }

  /// Accord sur le prix en cours d'une demande directe (par celui qui ne
  /// l'a pas propose). Le serveur compte la course et partage les coordonnees.
  Future<void> agreeDelivery(String requestId) =>
      _call('agreeDelivery', {'requestId': requestId});

  /// Accord sur l'offre de [driverId] pour une demande ouverte ; retourne
  /// l'id de la livraison creee.
  Future<String?> agreeOffer(String openRequestId, String driverId) async {
    final data = await _call(
      'agreeOffer',
      {'openRequestId': openRequestId, 'driverId': driverId},
    );
    return data['deliveryRequestId'] as String?;
  }

  /// Formule pour la suite : monthly | per_delivery.
  Future<void> choosePlan(String plan) => _call('choosePlan', {'plan': plan});
}
