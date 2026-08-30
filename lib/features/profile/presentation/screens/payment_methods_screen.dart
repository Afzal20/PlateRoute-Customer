import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class SavedPaymentItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDefault;

  const SavedPaymentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isDefault = false,
  });
}

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final List<SavedPaymentItem> _paymentMethods = [
    const SavedPaymentItem(
      id: 'pay_bkash',
      title: 'bKash Wallet',
      subtitle: '+880 1712 ***678 (Verified)',
      icon: Icons.account_balance_wallet_rounded,
      isDefault: true,
    ),
    const SavedPaymentItem(
      id: 'pay_card',
      title: 'Visa Platinum',
      subtitle: '•••• •••• •••• 4242 (Exp 12/28)',
      icon: Icons.credit_card_rounded,
      isDefault: false,
    ),
    const SavedPaymentItem(
      id: 'pay_nagad',
      title: 'Nagad Account',
      subtitle: '+880 1812 ***456',
      icon: Icons.payments_rounded,
      isDefault: false,
    ),
  ];

  void _showAddPaymentSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.roundedSheet),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.screenGutter,
              right: AppSpacing.screenGutter,
              top: AppSpacing.m,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.m,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: AppSpacing.sheetGrabHandleWidth,
                    height: AppSpacing.sheetGrabHandleHeight,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text('Link Payment Method', style: AppTypography.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Link your bKash or Nagad wallet for instant 1-tap checkout.',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  hintText: 'e.g. 01712345678',
                  label: 'MFS Mobile Number',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.l),
                AppButton.prominent(
                  label: 'Send Verification OTP',
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP sent to your phone for verification.')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        children: [
          Text(
            'Saved Accounts & Cards',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s),

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
              children: _paymentMethods.map((pm) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withValues(alpha: 0.12),
                    child: Icon(pm.icon, color: primaryColor, size: 20),
                  ),
                  title: Text(
                    pm.title,
                    style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    pm.subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  trailing: pm.isDefault
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: AppTypography.caption.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        )
                      : null,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.l),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(Icons.add_rounded, size: 20, color: primaryColor),
            label: Text(
              'Add New Payment Method',
              style: AppTypography.bodySmallMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            onPressed: () => _showAddPaymentSheet(context),
          ),
        ],
      ),
    );
  }
}
