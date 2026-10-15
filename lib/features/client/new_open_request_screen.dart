import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/snack.dart';
import '../auth/auth_providers.dart';
import '../common/home_tab_provider.dart';
import '../open_requests/open_request_providers.dart';
import '../requests/route_form.dart';

/// Demande ouverte : publiee aux livreurs proches, qui font chacun une offre ;
/// le client negocie et conclut avec celui qu'il choisit.
class NewOpenRequestScreen extends ConsumerWidget {
  const NewOpenRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.newOpenRequest)),
      body: RouteForm(
        header: Text(
          t.openRequestIntro,
          style: context.text.bodyLarge?.copyWith(color: context.muted),
        ),
        submitLabel: t.publishAction,
        submitIcon: Icons.campaign_rounded,
        onSubmit: (course) async {
          final user = ref.read(authStateProvider).value;
          final profile = ref.read(userProfileProvider).value;
          if (user == null || profile == null) return;
          await ref.read(openRequestRepositoryProvider).create(
                clientId: user.uid,
                clientName: profile.name,
                course: course,
              );
          if (!context.mounted) return;
          ref.read(homeTabProvider.notifier).select(1);
          showSnack(context, t.openRequestPublished);
          context.go('/client');
        },
      ),
    );
  }
}
