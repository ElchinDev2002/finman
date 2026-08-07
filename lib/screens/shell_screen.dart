import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/api_client.dart';
import '../app_theme.dart';

/// Same section list as src/components/Sidebar.tsx. Rendered as a Drawer
/// here since 13 items don't fit a bottom nav bar; swap for
/// BottomNavigationBar with your top ~5 if you'd rather match the
/// MobileNav.tsx behavior instead.
class ShellScreen extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const ShellScreen({super.key, required this.child, required this.currentPath});

  static const _sections = [
    (label: 'Dashboard', path: '/dashboard', icon: Icons.dashboard_outlined),
    (label: 'Transactions', path: '/transactions', icon: Icons.receipt_long_outlined),
    (label: 'Accounts', path: '/accounts', icon: Icons.account_balance_wallet_outlined),
    (label: 'Budget / Goals', path: '/budget', icon: Icons.pie_chart_outline),
    (label: 'Credits / Subscription', path: '/credits', icon: Icons.credit_card_outlined),
    (label: 'Analytics', path: '/analytics', icon: Icons.bar_chart_outlined),
    (label: 'Calendar', path: '/calendar', icon: Icons.calendar_today_outlined),
    (label: 'Reports', path: '/reports', icon: Icons.description_outlined),
    (label: 'Settings', path: '/settings', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                      child: const Text('FM',
                          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Finance Manager', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: _sections.map((s) {
                    final selected = currentPath.startsWith(s.path);
                    return ListTile(
                      leading: Icon(s.icon, color: selected ? AppColors.accent : AppColors.muted, size: 20),
                      title: Text(s.label,
                          style: TextStyle(
                            color: selected ? AppColors.fg : AppColors.muted,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 14,
                          )),
                      selected: selected,
                      selectedTileColor: AppColors.surface2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      onTap: () {
                        Navigator.pop(context);
                        context.go(s.path);
                      },
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger, size: 20),
                title: const Text('Log out', style: TextStyle(color: AppColors.danger, fontSize: 14)),
                onTap: () async {
                  await ApiClient.instance.logout();
                  if (context.mounted) context.go('/login');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (innerContext) => Stack(
          children: [
            child,
            Positioned(
              top: 8,
              left: 8,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
