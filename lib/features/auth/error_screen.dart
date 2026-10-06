import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'auth_providers.dart';

class ErrorScreen extends ConsumerWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final error = ref.watch(userProfileProvider).error;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                t.profileLoadError,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (kDebugMode && error != null) ...[
                const SizedBox(height: 12),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                child: Text(t.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
