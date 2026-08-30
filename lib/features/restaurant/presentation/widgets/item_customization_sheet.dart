import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/price_text.dart';
import '../../domain/models/menu_item_model.dart';
import 'quantity_stepper.dart';

class CustomizationResult {
  final MenuItemModel item;
  final int quantity;
  final Map<String, List<OptionItemModel>> selectedOptions;
  final String specialInstructions;
  final double totalPrice;

  const CustomizationResult({
    required this.item,
    required this.quantity,
    required this.selectedOptions,
    required this.specialInstructions,
    required this.totalPrice,
  });
}

class ItemCustomizationSheet extends StatefulWidget {
  final MenuItemModel item;
  final ValueChanged<CustomizationResult> onAddToCart;

  const ItemCustomizationSheet({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  State<ItemCustomizationSheet> createState() => _ItemCustomizationSheetState();
}

class _ItemCustomizationSheetState extends State<ItemCustomizationSheet> {
  int _quantity = 1;
  final Map<String, List<OptionItemModel>> _selectedOptions = {};
  late final TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    _instructionsController = TextEditingController();
    _initDefaultSelections();
  }

  void _initDefaultSelections() {
    for (final group in widget.item.optionGroups) {
      final defaults = group.options.where((opt) => opt.isDefault).toList();
      if (defaults.isNotEmpty) {
        _selectedOptions[group.id] = defaults;
      } else if (group.isRequired && group.options.isNotEmpty) {
        _selectedOptions[group.id] = [group.options.first];
      } else {
        _selectedOptions[group.id] = [];
      }
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double get _unitPrice {
    double total = widget.item.price;
    for (final options in _selectedOptions.values) {
      for (final opt in options) {
        total += opt.priceModifier;
      }
    }
    return total;
  }

  double get _totalPrice => _unitPrice * _quantity;

  bool get _isValid {
    for (final group in widget.item.optionGroups) {
      final selections = _selectedOptions[group.id] ?? [];
      if (group.isRequired && selections.length < group.minSelections) {
        return false;
      }
      if (selections.length > group.maxSelections) {
        return false;
      }
    }
    return true;
  }

  void _toggleOption(OptionGroupModel group, OptionItemModel option) {
    setState(() {
      final currentList = List<OptionItemModel>.from(_selectedOptions[group.id] ?? []);

      if (group.maxSelections == 1) {
        // Radio behavior
        _selectedOptions[group.id] = [option];
      } else {
        // Multi-select behavior
        final existsIndex = currentList.indexWhere((o) => o.id == option.id);
        if (existsIndex >= 0) {
          currentList.removeAt(existsIndex);
        } else {
          if (currentList.length < group.maxSelections) {
            currentList.add(option);
          }
        }
        _selectedOptions[group.id] = currentList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final locale = Localizations.localeOf(context).languageCode;
    final displayName = (locale == 'bn' && widget.item.nameBn != null)
        ? widget.item.nameBn!
        : widget.item.name;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          const SizedBox(height: 10),
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

          // Scrollable options body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenGutter,
                vertical: AppSpacing.m,
              ),
              children: [
                // Header: Image & Base item info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: AppTypography.titleLarge,
                          ),
                          if (widget.item.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.item.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          PriceText(
                            amount: widget.item.price,
                            originalAmount: widget.item.originalPrice,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: widget.item.imageUrl,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Icon(
                          Icons.fastfood,
                          size: 32,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                const Divider(),

                // Option Groups
                ...widget.item.optionGroups.map((group) {
                  final selections = _selectedOptions[group.id] ?? [];
                  final isRadio = group.maxSelections == 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              group.name,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: group.isRequired
                                    ? primaryColor.withValues(alpha: 0.12)
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                group.isRequired
                                    ? (group.minSelections > 1 ? 'Select ${group.minSelections}' : 'Required')
                                    : 'Optional (up to ${group.maxSelections})',
                                style: AppTypography.caption.copyWith(
                                  color: group.isRequired
                                      ? primaryColor
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        ...group.options.map((opt) {
                          final isSelected = selections.any((s) => s.id == opt.id);

                          return InkWell(
                            onTap: opt.isAvailable ? () => _toggleOption(group, opt) : null,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    isRadio
                                        ? (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked)
                                        : (isSelected ? Icons.check_box : Icons.check_box_outline_blank),
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      opt.name,
                                      style: AppTypography.bodySmallMedium.copyWith(
                                        color: opt.isAvailable
                                            ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    opt.priceModifier > 0
                                        ? '+${AppConstants.defaultCurrencySymbol}${opt.priceModifier.toInt()}'
                                        : 'Free',
                                    style: AppTypography.caption.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: AppSpacing.s),
                        const Divider(),
                      ],
                    ),
                  );
                }),

                // Special instructions
                Text(
                  'Special Instructions',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  hintText: 'e.g. Less spicy, cutlery required',
                  controller: _instructionsController,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          // Sticky Bottom Price Bar & Quantity Stepper
          Container(
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
              top: false,
              child: Row(
                children: [
                  QuantityStepper(
                    quantity: _quantity,
                    onIncrement: () => setState(() => _quantity++),
                    onDecrement: () {
                      if (_quantity > 1) {
                        setState(() => _quantity--);
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: AppButton.prominent(
                      label: 'Add to Cart • ${AppConstants.defaultCurrencySymbol}${_totalPrice.toInt()}',
                      variant: AppButtonVariant.primary,
                      onPressed: _isValid
                          ? () {
                              widget.onAddToCart(
                                CustomizationResult(
                                  item: widget.item,
                                  quantity: _quantity,
                                  selectedOptions: _selectedOptions,
                                  specialInstructions: _instructionsController.text.trim(),
                                  totalPrice: _totalPrice,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
