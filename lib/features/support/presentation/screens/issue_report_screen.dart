import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/models/support_ticket_model.dart';
import '../providers/support_provider.dart';

class IssueReportScreen extends ConsumerStatefulWidget {
  final String orderUuid;

  const IssueReportScreen({
    super.key,
    required this.orderUuid,
  });

  @override
  ConsumerState<IssueReportScreen> createState() => _IssueReportScreenState();
}

class _IssueReportScreenState extends ConsumerState<IssueReportScreen> {
  IssueCategory _selectedCategory = IssueCategory.missingItems;
  late final TextEditingController _descriptionController;
  final List<String> _attachedPhotos = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    final desc = _descriptionController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue in detail.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(supportRepositoryProvider);
      final ticket = await repo.createTicket(
        orderUuid: widget.orderUuid,
        category: _selectedCategory,
        title: '${_selectedCategory.title} (#${widget.orderUuid.substring(0, widget.orderUuid.length > 6 ? 6 : widget.orderUuid.length)})',
        description: desc,
        evidenceImageUrls: _attachedPhotos,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support ticket created. Our team is investigating.')),
        );
        context.pushReplacement(RoutePaths.supportTicketUri(ticket.uuid));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit ticket: $e')),
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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: Text(l10n.reportIssue),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        children: [
          // Header order badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                Icon(Icons.receipt_outlined, size: 18, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Order #${widget.orderUuid}',
                  style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),

          // Category Selector
          Text(
            'What went wrong?',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),

          ...IssueCategory.values.map((cat) {
            final isSelected = cat == _selectedCategory;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: AppSpacing.roundedCard,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppSpacing.roundedCard,
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.title,
                                style: AppTypography.bodySmallMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cat.description,
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected
                              ? primaryColor
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.m),

          // Description input
          Text(
            'Describe the Issue',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          AppTextField(
            hintText: 'Provide specific details so our support team can take action immediately...',
            controller: _descriptionController,
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.m),

          // Photo evidence
          Text(
            'Attach Photos / Evidence',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (_attachedPhotos.length < 3) {
                    setState(() {
                      _attachedPhotos.add('https://images.unsplash.com/photo-1550547660-d9450f859349?w=400&q=80');
                    });
                  }
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: AppSpacing.roundedCard,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 24, color: primaryColor),
                      const SizedBox(height: 2),
                      Text('Attach', style: AppTypography.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              ..._attachedPhotos.asMap().entries.map((entry) {
                final idx = entry.key;
                return Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: AppSpacing.roundedCard,
                        image: DecorationImage(
                          image: NetworkImage(entry.value),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => setState(() => _attachedPhotos.removeAt(idx)),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Submit CTA
          AppButton.prominent(
            label: 'Submit Support Ticket',
            variant: AppButtonVariant.primary,
            isLoading: _isSubmitting,
            onPressed: _submitTicket,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
