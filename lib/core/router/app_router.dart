import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_screen.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/error_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/client/client_home_screen.dart';
import '../../features/client/driver_detail_screen.dart';
import '../../features/client/new_open_request_screen.dart';
import '../../features/client/new_request_screen.dart';
import '../../features/driver/driver_home_screen.dart';
import '../../features/subscription/subscription_screen.dart';
import '../../models/chat.dart';

const _gateRoutes = {'/splash', '/welcome', '/onboarding', '/error'};

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

  // Un utilisateur connecte ne reste pas sur les ecrans d'accueil/inscription.
  if (_gateRoutes.contains(loc)) return home;

  // Chaque role reste dans son espace.
  if (data.isDriver && loc.startsWith('/client')) return home;
  if (!data.isDriver && loc.startsWith('/driver')) return home;

  return null;
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
      GoRoute(path: '/error', builder: (_, __) => const ErrorScreen()),
      GoRoute(
        path: '/client',
        builder: (_, __) => const ClientHomeScreen(),
        routes: [
          GoRoute(
            path: 'driver/:id',
            builder: (_, state) =>
                DriverDetailScreen(driverId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'open-request',
            builder: (_, __) => const NewOpenRequestScreen(),
          ),
          GoRoute(
            path: 'request/:driverId',
            builder: (_, state) =>
                NewRequestScreen(driverId: state.pathParameters['driverId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/driver',
        builder: (_, __) => const DriverHomeScreen(),
        routes: [
          GoRoute(
            path: 'subscription',
            builder: (_, __) => const SubscriptionScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) {
          final extra = state.extra;
          return ChatScreen(
            conversationId: state.pathParameters['id']!,
            args: extra is ChatArgs ? extra : null,
          );
        },
      ),
      GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
