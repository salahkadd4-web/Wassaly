import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/phone_guard.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/snack.dart';
import '../auth/auth_providers.dart';

/// Note d'une livraison terminee : ratings/{idDeLaLivraison}, une seule par
/// livraison (creation seule). La moyenne du livreur est calculee par le
/// serveur (onRatingCreated), qui marque aussi la livraison comme notee.
class RatingRepository {
  RatingRepository(this._db);

  final FirebaseFirestore _db;

  Future<void> rate({
    required String requestId,
    required String clientId,
    required String driverId,
    required int stars,
    required String comment,
  }) {
    return _db.collection('ratings').doc(requestId).set({
      'clientId': clientId,
      'driverId': driverId,
      'stars': stars,
      'comment': comment.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

final ratingRepositoryProvider = Provider<RatingRepository>(
  (ref) => RatingRepository(ref.watch(firestoreProvider)),
);

/// Etoiles en lecture seule (note d'une livraison, moyenne d'un livreur).
class StarsRow extends StatelessWidget {
  const StarsRow({super.key, required this.stars, this.size = 20});

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i <= stars ? AppTheme.orange : context.muted,
          ),
      ],
    );
  }
}

/// Note moyenne compacte : etoile + "4,6 (12)". Rien sans avis.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.average, required this.count});

  final double? average;
  final int count;

  @override
  Widget build(BuildContext context) {
    final avg = average;
    if (avg == null) return const SizedBox.shrink();
    final comma = Localizations.localeOf(context).languageCode == 'fr';
    final text = avg.toStringAsFixed(1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppTheme.orange),
        const SizedBox(width: 3),
        Text(
          '${comma ? text.replaceAll('.', ',') : text} ($count)',
          textDirection: TextDirection.ltr,
          style: context.text.labelMedium?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

Future<void> showRatingSheet(
  BuildContext context, {
  required String requestId,
  required String driverId,
  required String driverName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _RatingSheet(
      requestId: requestId,
      driverId: driverId,
      driverName: driverName,
    ),
  );
}

class _RatingSheet extends ConsumerStatefulWidget {
  const _RatingSheet({
    required this.requestId,
    required this.driverId,
    required this.driverName,
  });

  final String requestId;
  final String driverId;
  final String driverName;

  @override
  ConsumerState<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends ConsumerState<_RatingSheet> {
  final _commentCtrl = TextEditingController();
  int _stars = 0;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = AppLocalizations.of(context)!;
    final me = ref.read(authStateProvider).value;
    if (me == null || _stars == 0) return;
    if (containsPhoneNumber(_commentCtrl.text)) {
      setState(() => _error = t.phoneNotAllowed);
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(ratingRepositoryProvider).rate(
            requestId: widget.requestId,
            clientId: me.uid,
            driverId: widget.driverId,
            stars: _stars,
            comment: _commentCtrl.text,
          );
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, t.ratingSent);
    } on FirebaseException catch (e) {
      // Deja notee : la creation devient une mise a jour, refusee.
      if (mounted) {
        showSnack(context, e.code == 'permission-denied' ? t.ratingAlreadySent : t.genericError);
      }
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.rateTitle(widget.driverName), style: context.text.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      iconSize: 40,
                      tooltip: '$i',
                      onPressed: () => setState(() => _stars = i),
                      icon: Icon(
                        i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: i <= _stars ? AppTheme.orange : context.muted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentCtrl,
                maxLines: 3,
                maxLength: 300,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: InputDecoration(
                  labelText: t.rateCommentLabel,
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: (_stars == 0 || _sending) ? null : _send,
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.rateSend),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
