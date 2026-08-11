import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/main_shell_screen.dart';
import '../../features/expenses/presentation/expense_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class RouterTransitionNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

@riverpod
Listenable routerTransitionListenable(RouterTransitionListenableRef ref) {
  final listenable = RouterTransitionNotifier();
  ref.listen(authStateStreamProvider, (_, __) {
    listenable.notify();
  });
  ref.onDispose(() {
    listenable.dispose();
  });
  return listenable;
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final listenable = ref.watch(routerTransitionListenableProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authStateStreamProvider);
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final user = authState.valueOrNull;

      if (isLoading || hasError) return null;

      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (user == null && !isLoggingIn) {
        return '/login';
      }

      if (user != null && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const ExpenseListScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
