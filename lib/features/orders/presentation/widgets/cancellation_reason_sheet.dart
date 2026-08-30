import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/orders_provider.dart';

enum CancellationReason {
  changedMind('Changed my mind'),
  wrongAddress('Selected incorrect delivery address'),
  tooLong('Delivery time is longer than expected'),
  orderedMistake('Ordered wrong items by mistake'),
  other('Other reasons');

  final String label;
  const CancellationReason(this.label);
}

class CancellationReasonSheet extends ConsumerStatefulWidget {
  final String orderUuid;
  final bool isPostPreparation;
  final VoidCallback onCancelled;

  const CancellationReasonSheet({
    super.key,
    required this.orderUuid,
    this.isPostPreparation = false,
    required this.onCancelled,
  });

  @override
  ConsumerState<CancellationReasonSheet> createState() => _CancellationReasonSheetState();
}

class _CancellationReasonSheetState extends ConsumerState<CancellationReasonSheet> {
  CancellationReason _selectedReason = CancellationReason.changedMind;
  late final TextEditingController _otherController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _otherController = TextEditingController();
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _submitCancellation() async {
    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(orderRepositoryProvider);
      final reasonText = _selectedReason == CancellationReason.other
          ? _otherController.text.trim()
          : _selectedReason.label;

      await repo.cancelOrder(widget.orderUuid, reason: reasonText);

      if (mounted) {
        Navigator.pop(context);
        widget.onCancelled();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final dangerColor = isDark ? AppColors.dangerDark : AppColors.dangerLight;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screenGutter,
          right: AppSpacing.screenGutter,
          top: AppSpacing.m,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.m,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab Handle
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

            // Title
            Text('Cancel Order', style: AppTypography.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Please select the reason why you wish to cancel this order.',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Policy Notice Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isPostPreparation
                    ? dangerColor.withValues(alpha: 0.1)
                    : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                borderRadius: AppSpacing.roundedCard,
                border: Border.all(
                  color: widget.isPostPreparation
                      ? dangerColor.withValues(alpha: 0.4)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isPostPreparation ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                    color: widget.isPostPreparation ? dangerColor : primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isPostPreparation
                          ? 'Kitchen has already started cooking. A cancellation fee may be deducted from your refund.'
                          : '100% refund will be credited instantly to your original payment method.',
                      style: AppTypography.caption.copyWith(
                        color: widget.isPostPreparation
                            ? dangerColor
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Reason Options
            ...CancellationReason.values.map((reason) {
              final isSelected = reason == _selectedReason;
              return InkWell(
                onTap: () => setState(() => _selectedReason = reason),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? primaryColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason.label,
                          style: AppTypography.bodySmallMedium.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (_selectedReason == CancellationReason.other) ...[
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Please specify the reason...',
                controller: _otherController,
                maxLines: 2,
              ),
            ],

            const SizedBox(height: AppSpacing.l),

            // Actions
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Keep Order',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Confirm Cancel',
                    variant: AppButtonVariant.danger,
                    isLoading: _isSubmitting,
                    onPressed: _submitCancellation,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
