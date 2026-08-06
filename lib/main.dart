import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'api/api_client.dart';
import 'app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/register_screen.dart';
import 'screens/shell_screen.dart';

void main() {
  runApp(const FinanceManagerApp());
}

class FinanceManagerApp extends StatelessWidget {
  const FinanceManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finance Manager',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}

// Same protected/auth path split as src/middleware.ts.
const _protectedPaths = [
  '/dashboard', '/transactions', '/income', '/expenses', '/accounts',
  '/budget', '/goals', '/credits', '/subscriptions', '/analytics',
  '/calendar', '/reports', '/settings',
];
const _authPaths = ['/login', '/register'];

final _router = GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) async {
    final loggedIn = await ApiClient.instance.isLoggedIn;
    final path = state.matchedLocation;

    final isProtected = _protectedPaths.any((p) => path.startsWith(p));
    final isAuthPath = _authPaths.any((p) => path.startsWith(p));

    if (isProtected && !loggedIn) return '/login';
    if (isAuthPath && loggedIn) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    ..._protectedPaths.map(
      (path) => GoRoute(
        path: path,
        builder: (context, state) => ShellScreen(
          currentPath: path,
          child: path == '/dashboard'
              ? const DashboardScreen()
              : path == '/transactions'
                  ? const TransactionsScreen()
                  : PlaceholderScreen(title: _titleFor(path)),
        ),
      ),
    ),
  ],
);

String _titleFor(String path) {
  final name = path.replaceFirst('/', '');
  return name[0].toUpperCase() + name.substring(1);
}
