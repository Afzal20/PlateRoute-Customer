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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _inlineError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _inlineError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = context.l10n;
    final success = await ref.read(authProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      final authState = ref.read(authProvider);
      if (authState.unverifiedEmail != null) {
        context.go(RoutePaths.verifyEmail);
      } else {
        context.go(RoutePaths.home);
      }
    } else {
      final authState = ref.read(authProvider);
      setState(() {
        _inlineError = authState.errorMessage ?? l10n.genericError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
                Text(
                  l10n.signup,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Create your PlateRoute customer account',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // Error Banner
                if (_inlineError != null) ...[
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 18,
                          color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            _inlineError!,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],

                // Full Name
                AppTextField(
                  label: l10n.fullName,
                  hintText: 'John Doe',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.m),

                // Email
                AppTextField(
                  label: l10n.email,
                  hintText: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  autofillHints: const [AutofillHints.email],
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
                const SizedBox(height: AppSpacing.m),

                // Phone
                AppTextField(
                  label: l10n.phoneNumber,
                  hintText: '01700000000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.trim().length < 8) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.m),

                // Password
                AppTextField(
                  label: l10n.password,
                  hintText: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.m),

                // Confirm Password
                AppTextField(
                  label: l10n.confirmPassword,
                  hintText: '••••••••',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  onSubmitted: (_) => _handleRegister(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.l),

                // Submit Button
                AppButton.prominent(
                  label: l10n.register,
                  variant: AppButtonVariant.primary,
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: AppSpacing.l),

                // Already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        l10n.login,
                        style: AppTypography.bodySmallMedium.copyWith(
                          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
