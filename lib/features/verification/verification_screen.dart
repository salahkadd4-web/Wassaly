import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/exit_confirm_scope.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_providers.dart';
import 'id_photo_picker.dart';
import 'verification_providers.dart';

/// Ecran affiche a un livreur tant que sa piece d'identite n'est pas validee
/// par l'administrateur (le routeur bloque l'acces au reste de l'application).
class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  XFile? _photo;
  bool _sending = false;

  Future<void> _resend(String uid) async {
    final t = AppLocalizations.of(context)!;
    final photo = _photo;
    if (photo == null) {
      showSnack(context, t.idRequired);
      return;
    }
    setState(() => _sending = true);
    try {
      await ref
          .read(verificationRepositoryProvider)
          .resubmit(uid: uid, photo: photo);
      if (mounted) {
        setState(() => _photo = null);
        showSnack(context, t.verifResent);
      }
    } catch (e) {
      debugPrint('Renvoi de la piece d\'identite : $e');
      if (mounted) showSnack(context, t.idUploadError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final driver = ref.watch(myDriverProvider).value;
    if (user == null || driver == null) {
      return const Scaffold(body: LoadingState());
    }
    final identity = ref.watch(driverIdentityProvider(user.uid)).value;
    final rejected = driver.isVerificationRejected;

    return ExitConfirmScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.verifTitle),
          actions: [
            TextButton(
              onPressed:
                  _sending ? null : () => ref.read(authServiceProvider).signOut(),
              child: Text(
                t.signOut,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(
                rejected ? Icons.gpp_bad_outlined : Icons.hourglass_top,
                size: 72,
                color: rejected ? AppTheme.danger : AppTheme.orange,
              ),
              const SizedBox(height: 16),
              Text(
                rejected ? t.verifRejectedTitle : t.verifPendingTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                rejected ? t.verifRejectedBody : t.verifPendingBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              if (rejected &&
                  (identity?.rejectReason?.trim().isNotEmpty ?? false)) ...[
                const SizedBox(height: 12),
                Text(
                  t.verifReason(identity!.rejectReason!.trim()),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (rejected) ...[
                IdPhotoPicker(
                  file: _photo,
                  enabled: !_sending,
                  onPicked: (f) => setState(() => _photo = f),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _sending ? null : () => _resend(user.uid),
                  child: _sending
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.verifResend),
                ),
              ] else if (identity != null && identity.idUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 190,
                    child: Image.network(
                      identity.idUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
