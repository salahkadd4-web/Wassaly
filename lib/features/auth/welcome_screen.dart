import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/city_illustration.dart';
import '../../widgets/exit_confirm_scope.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(kDebugMode ? '$msg\n$e' : msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.65);

    return ExitConfirmScope(
      child: Scaffold(
        backgroundColor: dark ? null : Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton<String>(
                          tooltip: t.language,
                          icon: const Icon(Icons.language),
                          onSelected: (code) => ref
                              .read(localeProvider.notifier)
                              .setLocale(Locale(code)),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'fr', child: Text('Français')),
                            PopupMenuItem(value: 'ar', child: Text('العربية')),
                          ],
                        ),
                        const ThemeToggleButton(),
                        const SizedBox(width: 4),
                      ],
                    ),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/branding/logo/wassaly_logo.png',
                          height: 120,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.welcomeGreeting,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.welcomeTagline,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _signIn,
                        icon: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(t.continueWithGoogle),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 260, child: CityIllustration()),
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
