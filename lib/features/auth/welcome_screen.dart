import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/city_illustration.dart';
import '../../widgets/exit_confirm_scope.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/theme_toggle_button.dart';
import 'auth_providers.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _loading = false;

  /// Connexion Google. Le routeur envoie ensuite l'utilisateur vers son espace
  /// s'il a deja un profil, sinon vers l'inscription (telephone + role).
  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      debugPrint('Erreur Google Sign-In : $e');
      if (mounted) {
        final msg = AppLocalizations.of(context)!.signInError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(kDebugMode ? '$msg\n$e' : msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    return ExitConfirmScope(
      child: Scaffold(
        backgroundColor: context.isDark ? null : Colors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                      child: Row(
                        children: [
                          const LogoMark(size: 40),
                          const Spacer(),
                          TextButton(
                            onPressed: () => ref
                                .read(localeProvider.notifier)
                                .setLocale(Locale(lang == 'ar' ? 'fr' : 'ar')),
                            child: Text(lang == 'ar' ? 'Français' : 'العربية'),
                          ),
                          const ThemeToggleButton(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.welcomeHeadline,
                            style: context.text.headlineMedium?.copyWith(
                              fontSize: 30,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.welcomeTagline,
                            style: context.text.bodyLarge?.copyWith(color: context.muted),
                          ),
                          const SizedBox(height: 28),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                            ),
                            onPressed: _loading ? null : _signIn,
                            icon: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login_rounded),
                            label: Text(t.continueWithGoogle),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.welcomeForWho,
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    const SizedBox(height: 240, child: CityIllustration()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
