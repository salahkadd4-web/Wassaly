import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import 'auth_providers.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      debugPrint('Erreur Google Sign-In : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kDebugMode
                  ? '${AppLocalizations.of(context)!.signInError}\n$e'
                  : AppLocalizations.of(context)!.signInError,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/branding/logo/wassaly_logo.png',
                      height: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t.welcome,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                Text(
                  t.chooseLanguage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('fr')),
                  child: const Text('Français'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('ar')),
                  child: const Text('العربية'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.continueWithGoogle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
