import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum TimelineStage {
  placed(0),
  accepted(1),
  picked(2),
  delivered(3),
  cancelled(-1);

  final int stepIndex;
  const TimelineStage(this.stepIndex);
}

class TimelineStrip extends StatefulWidget {
  final TimelineStage currentStage;
  final List<String>? stageLabels;

  const TimelineStrip({
    super.key,
    required this.currentStage,
    this.stageLabels,
  });

  @override
  State<TimelineStrip> createState() => _TimelineStripState();
}

class _TimelineStripState extends State<TimelineStrip> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  static const List<String> _defaultLabels = [
    'Placed',
    'Accepted',
    'Picked',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final inactiveColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final labels = widget.stageLabels ?? _defaultLabels;
    final isCancelled = widget.currentStage == TimelineStage.cancelled;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.dangerDark : AppColors.dangerLight).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Order Cancelled',
              style: AppTypography.bodySmallMedium.copyWith(
                color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
              ),
            ),
          ],
        ),
      );
    }

    final activeIndex = widget.currentStage.stepIndex;

    return Column(
      children: [
        // Track and Nodes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(7, (index) {
              // Even indices are nodes (0, 2, 4, 6) -> node 0, 1, 2, 3
              if (index.isEven) {
                final nodeIndex = index ~/ 2;
                final isCompleted = nodeIndex < activeIndex;
                final isActive = nodeIndex == activeIndex;

                return _buildNode(
                  isCompleted: isCompleted,
                  isActive: isActive,
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                );
              } else {
                // Odd indices are connecting track segments (1, 3, 5) -> segment 0, 1, 2
                final segmentIndex = index ~/ 2;
                final isCompletedSegment = segmentIndex < activeIndex;

                return Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: isCompletedSegment ? primaryColor : inactiveColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }
            }),
          ),
        ),
        const SizedBox(height: 8),
        // Node Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (index) {
            final isCompleted = index <= activeIndex;
            final isActive = index == activeIndex;

            return SizedBox(
              width: 70,
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: isActive
                      ? primaryColor
                      : (isCompleted
                          ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  fontWeight: isActive ? FontWeight.w700 : (isCompleted ? FontWeight.w600 : FontWeight.w400),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNode({
    required bool isCompleted,
    required bool isActive,
    required Color primaryColor,
    required Color inactiveColor,
  }) {
    if (isActive) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: _pulseAnimation.value * 0.3),
              border: Border.all(
                color: primaryColor,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
              ),
            ),
          );
        },
      );
    }

    if (isCompleted) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor,
        ),
        child: const Center(
          child: Icon(
            Icons.check,
            size: 13,
            color: AppColors.white,
          ),
        ),
      );
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: inactiveColor,
          width: 2.0,
        ),
      ),
    );
  }
}
