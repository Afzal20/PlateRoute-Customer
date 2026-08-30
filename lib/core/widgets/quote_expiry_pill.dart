import 'dart:async';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class QuoteExpiryPill extends StatefulWidget {
  final DateTime expiresAt;
  final VoidCallback? onExpired;

  const QuoteExpiryPill({
    super.key,
    required this.expiresAt,
    this.onExpired,
  });

  @override
  State<QuoteExpiryPill> createState() => _QuoteExpiryPillState();
}

class _QuoteExpiryPillState extends State<QuoteExpiryPill> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _remaining;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasExpired = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.expiresAt.difference(DateTime.now());
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final remaining = widget.expiresAt.difference(now);

    if (remaining.isNegative || remaining == Duration.zero) {
      if (!_hasExpired) {
        _hasExpired = true;
        widget.onExpired?.call();
      }
      if (mounted) {
        setState(() {
          _remaining = Duration.zero;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _remaining = remaining;
        });
      }
    }
  }

  @override
  void didUpdateWidget(QuoteExpiryPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt) {
      _hasExpired = false;
      _remaining = widget.expiresAt.difference(DateTime.now());
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWarning = _remaining.inSeconds > 0 && _remaining.inSeconds <= 120;
    final isExpired = _remaining.inSeconds <= 0;

    Color textColor;
    Color bgColor;
    Border? border;

    if (isExpired) {
      textColor = isDark ? AppColors.dangerDark : AppColors.dangerLight;
      bgColor = textColor.withValues(alpha: 0.12);
      border = Border.all(color: textColor, width: 1.0);
    } else if (isWarning) {
      textColor = isDark ? AppColors.warningDeepDark : AppColors.warningDeepLight;
      bgColor = (isDark ? AppColors.warningDark : AppColors.warningLight).withValues(alpha: 0.15);
      border = Border.all(color: AppColors.warningLight, width: 1.0);
    } else {
      textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      bgColor = (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.4);
      border = Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 1.0,
      );
    }

    final l10n = context.l10n;
    final label = isExpired
        ? l10n.quoteExpiring(0)
        : '${l10n.quoteExpiring(_remaining.inMinutes + (_remaining.inSeconds % 60 > 0 ? 1 : 0))} (${_formatTime(_remaining)})';

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.roundedPill,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired
                ? Icons.timer_off_outlined
                : (isWarning ? Icons.warning_amber_rounded : Icons.timer_outlined),
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    if (isWarning) {
      return FadeTransition(
        opacity: _pulseAnimation,
        child: pill,
      );
    }

    return pill;
  }
}
