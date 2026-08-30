import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends ConsumerState<NotificationPreferencesScreen> {
  bool _orderUpdates = true;
  bool _riderTrackingAlerts = true;
  bool _dealsAndPromos = true;
  bool _smsConfirmations = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        children: [
          _buildSectionHeader('Order & Live Tracking', isDark),
          _buildGroup(
            isDark: isDark,
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                title: Text(
                  'Order Status Updates',
                  style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Notifications when order is accepted, preparing, or delivered',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                value: _orderUpdates,
                activeTrackColor: primaryColor,
                onChanged: (val) => setState(() => _orderUpdates = val),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                title: Text(
                  'Rider Proximity Alerts',
                  style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Alert when delivery rider is 2 minutes away from your gate',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                value: _riderTrackingAlerts,
                activeTrackColor: primaryColor,
                onChanged: (val) => setState(() => _riderTrackingAlerts = val),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),

          _buildSectionHeader('Promotions & Discounts', isDark),
          _buildGroup(
            isDark: isDark,
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                title: Text(
                  'Exclusive Offers & Flash Sales',
                  style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Receive special coupons and restaurant discount updates',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                value: _dealsAndPromos,
                activeTrackColor: primaryColor,
                onChanged: (val) => setState(() => _dealsAndPromos = val),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),

          _buildSectionHeader('Channels', isDark),
          _buildGroup(
            isDark: isDark,
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                title: Text(
                  'SMS Notifications',
                  style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Receive critical order updates and OTPs via SMS',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                value: _smsConfirmations,
                activeTrackColor: primaryColor,
                onChanged: (val) => setState(() => _smsConfirmations = val),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                title: Text(
                  'Email Newsletters',
                  style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Weekly digest of top trending restaurants in Dhaka',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                value: _marketingEmails,
                activeTrackColor: primaryColor,
                onChanged: (val) => setState(() => _marketingEmails = val),
              ),
            ],
          ),
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

  Widget _buildGroup({
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
}
