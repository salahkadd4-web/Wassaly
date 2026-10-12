import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../services/cloudinary_service.dart';
import '../../widgets/exit_confirm_scope.dart';
import '../verification/id_photo_picker.dart';
import '../verification/verification_providers.dart';
import 'auth_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _role; // 'client' ou 'driver'
  bool _saving = false;
  XFile? _idPhoto;
  bool _idMissing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value, AppLocalizations t) {
    // Mobiles algériens : 05 / 06 / 07 + 8 chiffres.
    return isValidAlgerianMobile(value ?? '') ? null : t.phoneInvalid;
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (_role == null) return;
    // Un livreur doit fournir une piece d'identite.
    if (_role == 'driver' && _idPhoto == null) {
      setState(() => _idMissing = true);
      return;
    }
    if (!formOk) return;

    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      String? idUrl;
      if (_role == 'driver') {
        idUrl = await ref
            .read(cloudinaryServiceProvider)
            .uploadImage(_idPhoto!);
      }
      await ref.read(profileRepositoryProvider).createProfile(
            user: user,
            phone: normalizePhone(_phoneController.text),
            role: _role!,
            idPhotoUrl: idUrl,
          );
      // Le routeur redirige automatiquement dès que le profil existe.
    } catch (e) {
      debugPrint('Erreur création du profil : $e');
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        // Numero deja reserve par un autre compte (regles Firestore).
        final taken = e is FirebaseException && e.code == 'permission-denied';
        // Echec de l'envoi de la photo (reseau, Cloudinary mal configure).
        final upload = e is CloudinaryException;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              taken ? t.phoneTaken : (upload ? t.idUploadError : t.saveError),
            ),
          ),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ExitConfirmScope(
      child: Scaffold(
      appBar: AppBar(
        title: Text(t.completeProfile),
        actions: [
          TextButton(
            onPressed:
                _saving ? null : () => ref.read(authServiceProvider).signOut(),
            child: Text(t.signOut),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(t.onboardingIntro, style: context.text.bodyLarge?.copyWith(color: context.muted)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: t.phoneLabel,
                  hintText: t.phoneHint,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  helperText: t.phonePrivacyHint,
                  helperMaxLines: 2,
                ),
                validator: (v) => _validatePhone(v, t),
              ),
              const SizedBox(height: 32),
              Text(t.roleQuestion, style: context.text.titleMedium),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.inventory_2_outlined,
                title: t.roleClient,
                subtitle: t.roleClientDesc,
                selected: _role == 'client',
                onTap: _saving ? null : () => setState(() => _role = 'client'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.two_wheeler,
                title: t.roleDriver,
                subtitle: t.roleDriverDesc,
                badge: t.roleDriverTrial,
                selected: _role == 'driver',
                onTap: _saving ? null : () => setState(() => _role = 'driver'),
              ),
              if (_role == 'driver') ...[
                const SizedBox(height: 24),
                Text(
                  t.idTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  t.idIntro,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                IdPhotoPicker(
                  file: _idPhoto,
                  enabled: !_saving,
                  errorText: _idMissing && _idPhoto == null ? t.idRequired : null,
                  onPicked: (f) => setState(() {
                    _idPhoto = f;
                    _idMissing = false;
                  }),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: (_role == null || _saving) ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.continueButton),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = context.isDark ? const Color(0xFF6B9BF7) : AppTheme.blue;

    return Material(
      color: selected
          ? AppTheme.blue.withValues(alpha: context.isDark ? 0.22 : 0.06)
          : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: BorderSide(
          color: selected ? accent : Theme.of(context).dividerColor,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: context.text.bodySmall),
                    if (badge != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.orange.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge!,
                          style: context.text.labelMedium?.copyWith(
                            color: context.ink(AppTheme.orange),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? accent : context.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
