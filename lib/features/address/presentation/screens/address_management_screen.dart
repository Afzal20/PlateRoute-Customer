import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/delivery_address_model.dart';
import '../providers/address_provider.dart';

class AddressManagementScreen extends ConsumerWidget {
  const AddressManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: Text(l10n.savedAddresses),
      ),
      body: addressState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addressState.addresses.isEmpty
              ? _buildEmptyState(context, isDark, l10n)
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenGutter),
                  itemCount: addressState.addresses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                  itemBuilder: (context, index) {
                    final addr = addressState.addresses[index];
                    final isDefault = addr.isDefault;

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: AppSpacing.roundedCard,
                        border: Border.all(
                          color: isDefault
                              ? primaryColor
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          width: isDefault ? 1.5 : 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      addr.label == AddressLabel.home
                                          ? Icons.home_rounded
                                          : (addr.label == AddressLabel.work
                                              ? Icons.work_rounded
                                              : Icons.location_on_rounded),
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      addr.formattedLabel,
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isDefault)
                                  Container(
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
                                else
                                  TextButton(
                                    onPressed: () {
                                      ref.read(addressRepositoryProvider).setDefaultAddress(addr.id);
                                      ref.read(addressProvider.notifier).loadAddresses();
                                    },
                                    child: Text(
                                      'Set Default',
                                      style: AppTypography.caption.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${addr.addressLine}, ${addr.area}',
                              style: AppTypography.bodySmallMedium.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            if (addr.floorApt != null && addr.floorApt!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                addr.floorApt!,
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                            if (addr.deliveryInstructions != null && addr.deliveryInstructions!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Note: ${addr.deliveryInstructions}',
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.s),
                            const Divider(),
                            const SizedBox(height: 4),

                            // Edit / Delete Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                                  ),
                                  onPressed: () {
                                    ref.read(addressProvider.notifier).deleteAddress(addr.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          AppSpacing.s,
          AppSpacing.screenGutter,
          AppSpacing.m,
        ),
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
          child: AppButton.prominent(
            label: l10n.addNewAddress,
            variant: AppButtonVariant.primary,
            onPressed: () => context.push(RoutePaths.addressEditor),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, dynamic l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'No Addresses Saved',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add your delivery locations (Home, Work, etc.) for rapid 1-tap checkout.',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
