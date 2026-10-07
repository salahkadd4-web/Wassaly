import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

/// Intercepte le bouton retour d'Android sur un ecran racine.
///
/// [onBack] est appele en premier : s'il renvoie true, le retour est considere
/// comme gere (par exemple retour a l'onglet principal). Sinon une boite de
/// dialogue demande confirmation avant de quitter l'application.
class ExitConfirmScope extends StatelessWidget {
  const ExitConfirmScope({super.key, required this.child, this.onBack});

  final Widget child;
  final bool Function()? onBack;

  Future<void> _confirmExit(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.exitTitle),
        content: Text(t.exitBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.exitConfirm),
          ),
        ],
      ),
    );
    if (ok == true) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (onBack?.call() == true) return;
        _confirmExit(context);
      },
      child: child,
    );
  }
}
