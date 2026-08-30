import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/language_switcher_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    LanguageSwitcherSheet.show(context);
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your PlateRoute account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerLight),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(RoutePaths.login);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        children: [
          // 1. User Info Header Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: AppSpacing.roundedCard,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: primaryColor.withValues(alpha: 0.15),
                  child: Text(
                    (user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'U').toUpperCase(),
                    style: AppTypography.titleLarge.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user?.fullName ?? 'Afzal Hossain',
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 16, color: AppColors.successLight),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'afzal@example.com',
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.phoneNumber ?? '+880 1712 345678',
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),

          // 2. Account & Shortcuts Section
          _buildSectionHeader('Account & Quick Access', isDark),
          _buildSettingsGroup(
            isDark: isDark,
            children: [
              _buildSettingsTile(
                icon: Icons.location_on_outlined,
                title: l10n.savedAddresses,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () => context.push(RoutePaths.addresses),
              ),
              _buildSettingsTile(
                icon: Icons.confirmation_number_outlined,
                title: l10n.availableVouchers,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () => context.push(RoutePaths.vouchers),
              ),
              _buildSettingsTile(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () => context.push(RoutePaths.paymentMethods),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),

          // 3. App Preferences Section
          _buildSectionHeader('Preferences', isDark),
          _buildSettingsGroup(
            isDark: isDark,
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: primaryColor,
                  size: 22,
                ),
                title: Text(
                  'Dark Theme',
                  style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                value: themeMode == ThemeMode.dark,
                activeTrackColor: primaryColor,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).setThemeMode(
                        val ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
              _buildSettingsTile(
                icon: Icons.translate_rounded,
                title: 'Language / ভাষা',
                subtitle: ref.watch(localeNotifierProvider).languageCode == 'bn' ? 'বাংলা' : 'English',
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () => _showLanguageSelector(context, ref),
              ),
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notification Preferences',
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () => context.push(RoutePaths.notificationPreferences),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),

          // 4. Security & Help Section
          _buildSectionHeader('Security & Help', isDark),
          _buildSettingsGroup(
            isDark: isDark,
            children: [
              _buildSettingsTile(
                icon: Icons.security_rounded,
                title: 'Security Center & 2FA',
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () => context.push(RoutePaths.securityCenter),
              ),
              _buildSettingsTile(
                icon: Icons.support_agent_rounded,
                title: 'Customer Support Tickets',
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () => context.push(RoutePaths.issueReportUri('general_support')),
              ),
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About PlateRoute',
                subtitle: 'Version ${AppConstants.appVersion}',
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // 5. Sign Out Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(
              Icons.logout_rounded,
              size: 20,
              color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
            ),
            label: Text(
              l10n.logout,
              style: AppTypography.bodySmallMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
              ),
            ),
            onPressed: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor, size: 22),
      title: Text(
        title,
        style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      onTap: onTap,
    );
  }
}
