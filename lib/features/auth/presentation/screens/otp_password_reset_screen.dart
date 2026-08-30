import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

enum PasswordResetStep {
  requestOtp,
  verifyOtpAndReset,
}

class OtpPasswordResetScreen extends ConsumerStatefulWidget {
  const OtpPasswordResetScreen({super.key});

  @override
  ConsumerState<OtpPasswordResetScreen> createState() => _OtpPasswordResetScreenState();
}

class _OtpPasswordResetScreenState extends ConsumerState<OtpPasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  PasswordResetStep _currentStep = PasswordResetStep.requestOtp;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final success = await ref.read(authProvider.notifier).requestPasswordResetOtp(email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        _currentStep = PasswordResetStep.verifyOtpAndReset;
        _successMessage = 'A 6-digit OTP code has been sent to $email';
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please check your email address.';
      });
    }
  }

  Future<void> _handleConfirmReset() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;

    final success = await ref.read(authProvider.notifier).confirmPasswordReset(
          email: email,
          otp: otp,
          newPassword: newPassword,
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully! Please log in.')),
      );
      context.go(RoutePaths.login);
    } else {
      setState(() {
        _errorMessage = 'Invalid or expired OTP code. Please try again.';
      });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep == PasswordResetStep.verifyOtpAndReset) {
              setState(() => _currentStep = PasswordResetStep.requestOtp);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step header
                Text(
                  _currentStep == PasswordResetStep.requestOtp
                      ? l10n.resetPassword
                      : 'Set New Password',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _currentStep == PasswordResetStep.requestOtp
                      ? 'Enter your registered email address to receive an OTP code'
                      : 'Enter the OTP code received and choose your new password',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // Success Notice
                if (_successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.roundedInput,
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _successMessage!,
                      style: AppTypography.bodySmall.copyWith(color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],

                // Error Notice
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.dangerDark : AppColors.dangerLight)
                          .withValues(alpha: 0.12),
                      borderRadius: AppSpacing.roundedInput,
                      border: Border.all(
                        color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],

                // Step 1: Email input
                if (_currentStep == PasswordResetStep.requestOtp) ...[
                  AppTextField(
                    label: l10n.email,
                    hintText: 'name@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    autofillHints: const [AutofillHints.email],
                    onSubmitted: (_) => _handleRequestOtp(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!AppConstants.emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.prominent(
                    label: l10n.sendOtp,
                    variant: AppButtonVariant.primary,
                    isLoading: _isLoading,
                    onPressed: _handleRequestOtp,
                  ),
                ],

                // Step 2: OTP and New Password inputs
                if (_currentStep == PasswordResetStep.verifyOtpAndReset) ...[
                  AppTextField(
                    label: l10n.enterOtp,
                    hintText: '123456',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the 6-digit OTP';
                      }
                      if (value.trim().length < 4) {
                        return 'Please enter a valid OTP code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    label: 'New Password',
                    hintText: '••••••••',
                    controller: _newPasswordController,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    label: 'Confirm New Password',
                    hintText: '••••••••',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    onSubmitted: (_) => _handleConfirmReset(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.prominent(
                    label: l10n.resetPassword,
                    variant: AppButtonVariant.primary,
                    isLoading: _isLoading,
                    onPressed: _handleConfirmReset,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextButton(
                    onPressed: _handleRequestOtp,
                    child: Text(
                      l10n.resendOtp,
                      style: AppTypography.bodySmallMedium.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
