import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _onTap(context, index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: isDark
                ? AppColors.primaryDark.withValues(alpha: 0.15)
                : AppColors.primaryLight.withValues(alpha: 0.12),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                ),
                label: l10n.home,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(
                  Icons.receipt_long_rounded,
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                ),
                label: l10n.orders,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: Icon(
                  Icons.person_rounded,
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                ),
                label: l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
