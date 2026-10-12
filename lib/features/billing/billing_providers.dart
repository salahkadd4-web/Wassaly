import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../models/driver_billing.dart';
import '../auth/auth_providers.dart';
import 'billing_functions.dart';

final billingFunctionsProvider = Provider<BillingFunctions>(
  (ref) => BillingFunctions(
    FirebaseFunctions.instanceFor(region: AppConfig.functionsRegion),
  ),
);

/// Facturation d'un livreur (driverBilling/{uid}) : le livreur connecte ou l'admin.
final driverBillingProvider =
    StreamProvider.family<DriverBilling, String>((ref, uid) {
  return ref
      .watch(firestoreProvider)
      .collection('driverBilling')
      .doc(uid)
      .snapshots()
      .map((s) => DriverBilling.fromMap(uid, s.data()));
});

/// Facturation du livreur connecte.
final myBillingProvider = Provider<AsyncValue<DriverBilling>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const AsyncValue.loading();
  return ref.watch(driverBillingProvider(user.uid));
});

/// Historique (debits, remboursements, paiements) du livreur connecte.
final myLedgerProvider = StreamProvider<List<LedgerEntry>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(firestoreProvider)
      .collection('driverBilling')
      .doc(user.uid)
      .collection('ledger')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => LedgerEntry.fromMap(d.id, d.data())).toList());
});
