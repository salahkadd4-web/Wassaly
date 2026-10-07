import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/exit_confirm_scope.dart';
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
    if (!(_formKey.currentState?.validate() ?? false) || _role == null) return;

    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .createProfile(
            user: user,
            phone: normalizePhone(_phoneController.text),
            role: _role!,
          );
      // Le routeur redirige automatiquement dès que le profil existe.
    } catch (e) {
      debugPrint('Erreur création du profil : $e');
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        // Numero deja reserve par un autre compte (regles Firestore).
        final taken = e is FirebaseException && e.code == 'permission-denied';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(taken ? t.phoneTaken : t.saveError)),
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
              onPressed: _saving
                  ? null
                  : () => ref.read(authServiceProvider).signOut(),
              child: Text(
                t.signOut,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: t.phoneLabel,
                    hintText: t.phoneHint,
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => _validatePhone(v, t),
                ),
                const SizedBox(height: 32),
                Text(
                  t.roleQuestion,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  icon: Icons.person,
                  title: t.roleClient,
                  subtitle: t.roleClientDesc,
                  selected: _role == 'client',
                  onTap: _saving
                      ? null
                      : () => setState(() => _role = 'client'),
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  icon: Icons.two_wheeler,
                  title: t.roleDriver,
                  subtitle: t.roleDriverDesc,
                  selected: _role == 'driver',
                  onTap: _saving
                      ? null
                      : () => setState(() => _role = 'driver'),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
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
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? scheme.secondary : Theme.of(context).dividerColor,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: scheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: scheme.secondary),
          ],
        ),
      ),
    );
  }
}
