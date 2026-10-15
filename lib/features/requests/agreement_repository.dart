import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/delivery_request.dart';
import '../../models/driver_profile.dart';
import '../../models/open_request.dart';
import '../auth/auth_providers.dart';

/// Pourquoi un accord n'a pas pu etre conclu.
enum AgreementRefusal {
  /// Ce n'est pas a vous d'accepter (vous avez fait la derniere proposition).
  notYourTurn,

  /// La demande n'est plus en negociation (annulee, refusee...).
  notPending,

  /// Demande ouverte : un autre livreur a deja ete retenu.
  alreadyTaken,

  /// Livreur : votre solde a atteint le plafond de 1 000 DA.
  debtLimit,

  /// Livreur : votre formule ne permet pas de travailler.
  notEligible,

  /// Client : le livreur ne peut plus travailler pour le moment.
  driverUnavailable,

  unknown,
}

class AgreementException implements Exception {
  const AgreementException(this.refusal);

  final AgreementRefusal refusal;

  String message(AppLocalizations t) => switch (refusal) {
        AgreementRefusal.notYourTurn => t.billingErrorNotYourTurn,
        AgreementRefusal.notPending => t.billingErrorNotPending,
        AgreementRefusal.alreadyTaken => t.billingErrorAlreadyTaken,
        AgreementRefusal.debtLimit => t.billingErrorDebtLimit,
        AgreementRefusal.notEligible => t.billingErrorNotEligible,
        AgreementRefusal.driverUnavailable => t.billingErrorDriverUnavailable,
        AgreementRefusal.unknown => t.genericError,
      };
}

/// Frais debites au livreur a l'accord : 50 DA en formule a la livraison
/// (y compris essai / mois termine avec "a la livraison" choisi), 0 sinon.
/// Meme regle que perDeliveryMode dans firestore.rules.
int agreementFee(DriverProfile driver, DateTime now) =>
    driver.perDeliveryModeAt(now) ? AppConfig.perDeliveryPriceDa : 0;

/// Conclusion d'un accord sur un prix, sans serveur (offre Firebase gratuite).
///
/// Tout part dans UNE transaction : passage a "accepted" et, pour un livreur
/// a la livraison, dette +50 DA liee a cette course et ecriture comptable.
/// firestore.rules refusent le lot entier si une seule piece manque ou est
/// fausse (mauvais tour, prix modifie, debit absent, dette au plafond...).
/// Les coordonnees ont ete deposees avant par chacun ; les regles ne les
/// rendent lisibles a l'autre qu'apres l'accord.
class AgreementRepository {
  AgreementRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _billing(String driverId) =>
      _db.collection('driverBilling').doc(driverId);

  /// Ecritures du debit (si [fee] > 0), dans la transaction de l'accord.
  void _charge(Transaction tx, String driverId, String requestId, int fee) {
    if (fee == 0) return;
    tx.set(
      _billing(driverId),
      {
        'debt': FieldValue.increment(fee),
        'lastChargeRequestId': requestId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    tx.set(_billing(driverId).collection('ledger').doc('charge_$requestId'), {
      'type': 'charge',
      'amount': fee,
      'requestId': requestId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Le livreur verifie lui-meme son plafond (il peut lire sa dette) ;
  /// le client, lui, s'en remet aux regles.
  Future<void> _checkOwnDebt(Transaction tx, String driverId, int fee) async {
    if (fee == 0) return;
    final snap = await tx.get(_billing(driverId));
    final debt = (snap.data()?['debt'] as num?)?.toInt() ?? 0;
    if (debt >= AppConfig.debtLimitDa) {
      throw const AgreementException(AgreementRefusal.debtLimit);
    }
  }

  Future<T> _guard<T>(bool asDriver, Future<T> Function() action) async {
    try {
      return await action();
    } on AgreementException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AgreementException(
          asDriver ? AgreementRefusal.notEligible : AgreementRefusal.driverUnavailable,
        );
      }
      throw const AgreementException(AgreementRefusal.unknown);
    } catch (_) {
      throw const AgreementException(AgreementRefusal.unknown);
    }
  }

  /// Accord sur une demande directe, par celui qui n'a pas fait la derniere
  /// proposition.
  Future<void> agreeDelivery(String requestId, {required bool asDriver}) {
    final reqRef = _db.collection('deliveryRequests').doc(requestId);
    return _guard(asDriver, () => _db.runTransaction((tx) async {
          final reqSnap = await tx.get(reqRef);
          final req = DeliveryRequest.fromMap(requestId, reqSnap.data() ?? {});
          if (!reqSnap.exists || !req.isNegotiating) {
            throw const AgreementException(AgreementRefusal.notPending);
          }
          if (!req.myTurn(asDriver: asDriver)) {
            throw const AgreementException(AgreementRefusal.notYourTurn);
          }
          final driverSnap = await tx.get(_db.collection('drivers').doc(req.driverId));
          final driver = DriverProfile.fromMap(req.driverId, driverSnap.data() ?? {});
          final fee = agreementFee(driver, DateTime.now());
          if (asDriver) await _checkOwnDebt(tx, req.driverId, fee);

          tx.update(reqRef, {
            'status': RequestStatus.accepted,
            'acceptedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'charged': fee,
          });
          _charge(tx, req.driverId, requestId, fee);
        }));
  }

  /// Accord sur l'offre de [driverId] pour une demande ouverte : la livraison
  /// est creee deja acceptee et la demande est attribuee. Retourne l'id de
  /// la livraison.
  Future<String> agreeOffer({
    required String openRequestId,
    required String driverId,
    required bool asDriver,
  }) {
    final openRef = _db.collection('openRequests').doc(openRequestId);
    final offerRef = openRef.collection('offers').doc(driverId);
    final deliveryRef = _db.collection('deliveryRequests').doc();
    return _guard(asDriver, () async {
      await _db.runTransaction((tx) async {
        final openSnap = await tx.get(openRef);
        final offerSnap = await tx.get(offerRef);
        final open = OpenRequest.fromMap(openRequestId, openSnap.data() ?? {});
        if (!openSnap.exists || !open.isOpen) {
          throw const AgreementException(AgreementRefusal.alreadyTaken);
        }
        if (!offerSnap.exists) throw const AgreementException(AgreementRefusal.notPending);
        final offer = Offer.fromMap(openRequestId, driverId, offerSnap.data()!);
        if (!offer.isOpen) throw const AgreementException(AgreementRefusal.notPending);
        if (!offer.myTurn(asDriver: asDriver)) {
          throw const AgreementException(AgreementRefusal.notYourTurn);
        }
        final driverSnap = await tx.get(_db.collection('drivers').doc(driverId));
        final driver = DriverProfile.fromMap(driverId, driverSnap.data() ?? {});
        final fee = agreementFee(driver, DateTime.now());
        if (asDriver) await _checkOwnDebt(tx, driverId, fee);

        // Copie exacte de la demande et de l'offre (verifiee par les regles).
        final raw = openSnap.data()!;
        tx.set(deliveryRef, {
          'clientId': open.clientId,
          'driverId': driverId,
          'clientName': open.clientName,
          'driverName': offer.driverName,
          'pickupArea': raw['pickupArea'],
          'deliveryArea': raw['deliveryArea'],
          'distanceKm': raw['distanceKm'],
          'note': raw['note'],
          'status': RequestStatus.accepted,
          'source': 'open',
          'openRequestId': openRequestId,
          'price': offer.price,
          'lastBy': offer.lastBy,
          'charged': fee,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'acceptedAt': FieldValue.serverTimestamp(),
        });
        tx.update(openRef, {
          'status': OpenRequestStatus.taken,
          'takenBy': driverId,
          'takenByName': offer.driverName,
          'deliveryRequestId': deliveryRef.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        tx.update(offerRef, {'status': 'agreed', 'updatedAt': FieldValue.serverTimestamp()});
        _charge(tx, driverId, deliveryRef.id, fee);
      });
      return deliveryRef.id;
    });
  }
}

final agreementRepositoryProvider = Provider<AgreementRepository>(
  (ref) => AgreementRepository(ref.watch(firestoreProvider)),
);
