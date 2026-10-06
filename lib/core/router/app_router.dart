import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/error_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/client/client_home_screen.dart';
import '../../features/driver/driver_home_screen.dart';

String? _redirect(Ref ref, GoRouterState state) {
  final loc = state.matchedLocation;

  final auth = ref.read(authStateProvider);
  if (auth.isLoading && !auth.hasValue) {
    return loc == '/splash' ? null : '/splash';
  }

  final user = auth.value;
  if (user == null) {
    return loc == '/welcome' ? null : '/welcome';
  }

  final profile = ref.read(userProfileProvider);
  if (profile.isLoading) {
    return loc == '/splash' ? null : '/splash';
  }
  if (profile.hasError) {
    return loc == '/error' ? null : '/error';
  }

  final data = profile.value;
  if (data == null) {
    return loc == '/onboarding' ? null : '/onboarding';
  }

  final home = data.isDriver ? '/driver' : '/client';
  return loc == home ? null : home;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refresh.value++);
  ref.listen(userProfileProvider, (_, __) => refresh.value++);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/client', builder: (_, __) => const ClientHomeScreen()),
      GoRoute(path: '/driver', builder: (_, __) => const DriverHomeScreen()),
      GoRoute(path: '/error', builder: (_, __) => const ErrorScreen()),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
