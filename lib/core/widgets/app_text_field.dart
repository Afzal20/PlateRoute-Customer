import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final bool autofocus;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final bool showClearButton;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.helperText,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.showClearButton = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.autofillHints,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late TextEditingController _effectiveController;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _effectiveController = widget.controller ?? TextEditingController();
    _showClear = widget.showClearButton && _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    } else {
      _effectiveController.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final shouldShow = widget.showClearButton && _effectiveController.text.isNotEmpty;
    if (shouldShow != _showClear && mounted) {
      setState(() => _showClear = shouldShow);
    }
  }

  Widget? _buildSuffixIcon(bool isDark) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          size: 20,
        ),
        onPressed: () {
          setState(() => _obscureText = !_obscureText);
        },
      );
    }

    if (_showClear && !widget.readOnly) {
      return IconButton(
        icon: Icon(
          Icons.cancel,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          size: 18,
        ),
        onPressed: () {
          _effectiveController.clear();
          widget.onChanged?.call('');
        },
      );
    }

    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final field = TextFormField(
      controller: _effectiveController,
      obscureText: _obscureText,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      style: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        errorText: widget.errorText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(isDark),
        counterText: widget.maxLength != null ? null : '',
      ),
    );

    if (widget.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label!,
            style: AppTypography.bodySmallMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          field,
        ],
      );
    }

    return field;
  }
}
