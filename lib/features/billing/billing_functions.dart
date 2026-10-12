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

  /// Un autre livreur a pris la demande ouverte avant vous.
  alreadyTaken,

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

  /// Le livreur accepte une demande directe (50 DA en formule a la livraison).
  Future<void> acceptDelivery(String requestId) =>
      _call('acceptDelivery', {'requestId': requestId});

  /// Le livreur prend une demande ouverte ; retourne l'id de la livraison creee.
  Future<String?> takeOpenRequest(String openRequestId) async {
    final data = await _call('takeOpenRequest', {'openRequestId': openRequestId});
    return data['deliveryRequestId'] as String?;
  }

  /// Formule pour la suite : monthly | per_delivery.
  Future<void> choosePlan(String plan) => _call('choosePlan', {'plan': plan});
}
