import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  String? _message;

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _message = null;
    });

    await ref.read(authProvider.notifier).checkAuthStatus();

    if (!mounted) return;

    final authState = ref.read(authProvider);
    setState(() => _isChecking = false);

    if (authState.isAuthenticated) {
      context.go(RoutePaths.home);
    } else {
      setState(() {
        _message = 'Email is not verified yet. Please check your inbox and click the link.';
      });
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
      _message = null;
    });

    final authState = ref.read(authProvider);
    final email = authState.unverifiedEmail;

    if (email != null) {
      await ref.read(authProvider.notifier).requestPasswordResetOtp(email);
    }

    if (!mounted) return;

    setState(() {
      _isResending = false;
      _message = 'Verification email resent successfully.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final authState = ref.watch(authProvider);
    final l10n = context.l10n;
    final email = authState.unverifiedEmail ?? 'your email address';

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mail Icon
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 44,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                l10n.emailVerificationNotice,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'We sent a verification link to\n$email\nPlease click the link to activate your account.',
                style: AppTypography.body.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.l),

              if (_message != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.roundedInput,
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _message!,
                    style: AppTypography.bodySmall.copyWith(
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              // Check Status Button
              AppButton.prominent(
                label: "I've Verified My Email",
                variant: AppButtonVariant.primary,
                isLoading: _isChecking,
                onPressed: _checkVerification,
              ),
              const SizedBox(height: AppSpacing.m),

              // Resend Button
              AppButton.secondary(
                label: 'Resend Verification Email',
                isLoading: _isResending,
                onPressed: _resendEmail,
              ),
              const SizedBox(height: AppSpacing.l),

              // Back to login
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go(RoutePaths.login);
                },
                child: Text(
                  l10n.backToLogin,
                  style: AppTypography.bodySmallMedium.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
