import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/review_provider.dart';

class ReviewComposerScreen extends ConsumerStatefulWidget {
  final String orderUuid;
  final String restaurantUuid;

  const ReviewComposerScreen({
    super.key,
    required this.orderUuid,
    this.restaurantUuid = 'res_chillox',
  });

  @override
  ConsumerState<ReviewComposerScreen> createState() => _ReviewComposerScreenState();
}

class _ReviewComposerScreenState extends ConsumerState<ReviewComposerScreen> {
  int _selectedRating = 5;
  final List<String> _selectedTags = [];
  final List<String> _attachedPhotos = [];
  late final TextEditingController _commentController;
  bool _isSubmitting = false;

  static const List<String> _quickTags = [
    'Delicious Food',
    'Super Fast Delivery',
    'Warm & Fresh',
    'Great Packaging',
    'Value for Money',
    'Eco-Friendly Box',
  ];

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _commentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Good';
      case 3:
        return 'Average';
      case 2:
        return 'Below Expectations';
      case 1:
      default:
        return 'Disappointing';
    }
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty && _selectedRating <= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide feedback to help us improve.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(reviewRepositoryProvider);
      await repo.submitReview(
        orderUuid: widget.orderUuid,
        restaurantUuid: widget.restaurantUuid,
        rating: _selectedRating.toDouble(),
        comment: comment,
        tags: _selectedTags,
        imageUrls: _attachedPhotos,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you! Your review was published.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
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
    final charCount = _commentController.text.length;

    Color counterColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    if (charCount >= AppConstants.reviewCharCountSoftWarning) {
      counterColor = isDark ? AppColors.warningDark : AppColors.warningLight;
    }
    if (charCount > AppConstants.maxReviewCharCount) {
      counterColor = isDark ? AppColors.dangerDark : AppColors.dangerLight;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: const Text('Write a Review'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        children: [
          // 1. Interactive Star Rating Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.l, horizontal: AppSpacing.m),
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
                Text(
                  'How was your food experience?',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starNum = index + 1;
                    final isFilled = starNum <= _selectedRating;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedRating = starNum);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 40,
                          color: isFilled
                              ? (isDark ? AppColors.warningDeepDark : AppColors.warningLight)
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRatingLabel(_selectedRating),
                  style: AppTypography.bodySmallMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.warningDeepDark : AppColors.warningLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),

          // 2. Quick Impression Tags
          Text(
            'What did you like the most?',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);

              return ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                selectedColor: primaryColor.withValues(alpha: 0.15),
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                labelStyle: AppTypography.caption.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                side: BorderSide(
                  color: isSelected
                      ? primaryColor
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.m),

          // 3. Review Comment Input with Character Rules
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Review (Optional)',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '$charCount / ${AppConstants.maxReviewCharCount}',
                style: AppTypography.caption.copyWith(
                  color: counterColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppTextField(
            hintText: 'Share taste, portion size, packaging quality...',
            controller: _commentController,
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.m),

          // 4. Photo Upload Preview
          Text(
            'Add Photos',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              // Add photo button
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
                      Icon(Icons.add_a_photo_outlined, size: 24, color: primaryColor),
                      const SizedBox(height: 2),
                      Text('Upload', style: AppTypography.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Attached thumbnails
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

          // 5. Submit CTA
          AppButton.prominent(
            label: l10n.submitReview,
            variant: AppButtonVariant.primary,
            isLoading: _isSubmitting,
            onPressed: charCount > AppConstants.maxReviewCharCount ? null : _submitReview,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
