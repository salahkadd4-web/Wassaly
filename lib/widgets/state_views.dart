import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'empty_state.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.error_outline,
      message: t.genericError,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(t.retry),
            ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
