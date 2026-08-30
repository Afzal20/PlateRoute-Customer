import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class SecurityCenterScreen extends ConsumerStatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  ConsumerState<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends ConsumerState<SecurityCenterScreen> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _is2faEnabled = true;
  bool _isBiometricEnabled = false;
  bool _isUpdatingPassword = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all password fields.')),
      );
      return;
    }

    if (next.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 8 characters.')),
      );
      return;
    }

    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }

    setState(() => _isUpdatingPassword = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      setState(() => _isUpdatingPassword = false);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: const Text('Security Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        children: [
          // 1. Password Update Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Password',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  hintText: 'Current Password',
                  controller: _currentPasswordController,
                  isPassword: true,
                ),
                const SizedBox(height: AppSpacing.s),
                AppTextField(
                  hintText: 'New Password (min. 8 characters)',
                  controller: _newPasswordController,
                  isPassword: true,
                ),
                const SizedBox(height: AppSpacing.s),
                AppTextField(
                  hintText: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                ),
                const SizedBox(height: AppSpacing.m),
                AppButton(
                  label: 'Update Password',
                  variant: AppButtonVariant.primary,
                  isLoading: _isUpdatingPassword,
                  onPressed: _updatePassword,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),

          // 2. Authentication & 2FA Toggles
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: AppSpacing.roundedCard,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  secondary: Icon(Icons.phonelink_lock_rounded, color: primaryColor),
                  title: Text(
                    'Two-Factor Authentication (2FA)',
                    style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Receive SMS OTP when signing in from new devices',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  value: _is2faEnabled,
                  activeTrackColor: primaryColor,
                  onChanged: (val) => setState(() => _is2faEnabled = val),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  secondary: Icon(Icons.fingerprint_rounded, color: primaryColor),
                  title: Text(
                    'Biometric Quick Unlock',
                    style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Unlock app using Fingerprint or Face ID',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  value: _isBiometricEnabled,
                  activeTrackColor: primaryColor,
                  onChanged: (val) => setState(() => _isBiometricEnabled = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),

          // 3. Active Sessions Manager
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Devices',
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All other device sessions revoked.')),
                        );
                      },
                      child: Text(
                        'Revoke Other Devices',
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.phone_android_rounded, color: primaryColor),
                  title: Text(
                    'Current Phone (Android)',
                    style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Dhaka, Bangladesh • Active Now',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'THIS DEVICE',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.successLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
