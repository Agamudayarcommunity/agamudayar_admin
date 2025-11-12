import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import screens
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/news/screens/news_approval_screen.dart';
import '../features/news/screens/news_api_screen.dart';
import '../features/jobs/screens/jobs_approval_screen.dart';
import '../features/advertisements/screens/advertisements_approval_screen.dart';
import '../features/matrimony/screens/matrimony_approval_screen.dart';
import '../features/auth/providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isLoading = authProvider.isLoading;
        final currentPath = state.uri.path;

        print(
          'Router redirect: isLoggedIn=$isLoggedIn, isLoading=$isLoading, path=$currentPath',
        );

        // Don't redirect while loading
        if (isLoading) {
          print('Router: Skipping redirect - loading in progress');
          return null;
        }

        // If not logged in and trying to access protected routes
        if (!isLoggedIn && currentPath != '/login') {
          print('Router: Redirecting to login - not authenticated');
          return '/login';
        }

        // If logged in and on login page, redirect to dashboard
        if (isLoggedIn && currentPath == '/login') {
          print('Router: Redirecting to dashboard - already authenticated');
          return '/dashboard';
        }

        print('Router: No redirect needed');
        return null;
      },
      refreshListenable: _AuthStateNotifier(authProvider),
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/news',
          builder: (context, state) => const NewsApprovalScreen(),
        ),
        GoRoute(
          path: '/news/api',
          builder: (context, state) => const NewsApiScreen(),
        ),
        GoRoute(
          path: '/jobs',
          builder: (context, state) => const JobsApprovalScreen(),
        ),
        GoRoute(
          path: '/advertisements',
          builder: (context, state) => const AdvertisementsApprovalScreen(),
        ),
        GoRoute(
          path: '/matrimony',
          builder: (context, state) => const MatrimonyApprovalScreen(),
        ),
      ],
      errorBuilder: (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
    );
  }
}

// Custom notifier to listen to auth state changes
class _AuthStateNotifier extends ChangeNotifier {
  final AuthProvider authProvider;

  _AuthStateNotifier(this.authProvider) {
    authProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    authProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
