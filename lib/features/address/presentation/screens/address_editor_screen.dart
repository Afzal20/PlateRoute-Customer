import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/map_pane.dart';
import '../../domain/models/delivery_address_model.dart';
import '../providers/address_provider.dart';

class AddressEditorScreen extends ConsumerStatefulWidget {
  final DeliveryAddressModel? addressToEdit;

  const AddressEditorScreen({
    super.key,
    this.addressToEdit,
  });

  @override
  ConsumerState<AddressEditorScreen> createState() => _AddressEditorScreenState();
}

class _AddressEditorScreenState extends ConsumerState<AddressEditorScreen> {
  AddressLabel _selectedLabel = AddressLabel.home;
  late final TextEditingController _customLabelController;
  late final TextEditingController _addressLineController;
  late final TextEditingController _areaController;
  late final TextEditingController _floorAptController;
  late final TextEditingController _instructionsController;
  bool _isDefault = false;
  LatLng _currentLocation = AppConstants.defaultLocation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.addressToEdit;

    _selectedLabel = addr?.label ?? AddressLabel.home;
    _customLabelController = TextEditingController(text: addr?.customLabel ?? '');
    _addressLineController = TextEditingController(text: addr?.addressLine ?? '');
    _areaController = TextEditingController(text: addr?.area ?? 'Banani, Dhaka');
    _floorAptController = TextEditingController(text: addr?.floorApt ?? '');
    _instructionsController = TextEditingController(text: addr?.deliveryInstructions ?? '');
    _isDefault = addr?.isDefault ?? false;

    if (addr != null) {
      _currentLocation = LatLng(addr.latitude, addr.longitude);
    }
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    _addressLineController.dispose();
    _areaController.dispose();
    _floorAptController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    final line = _addressLineController.text.trim();
    final area = _areaController.text.trim();

    if (line.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter street / house address line.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newAddr = DeliveryAddressModel(
        id: widget.addressToEdit?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
        label: _selectedLabel,
        customLabel: _customLabelController.text.trim(),
        addressLine: line,
        area: area.isNotEmpty ? area : 'Dhaka',
        floorApt: _floorAptController.text.trim(),
        deliveryInstructions: _instructionsController.text.trim(),
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        isDefault: _isDefault,
      );

      await ref.read(addressProvider.notifier).addAddress(newAddr);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        title: Text(widget.addressToEdit != null ? 'Edit Address' : l10n.addNewAddress),
      ),
      body: Column(
        children: [
          // 1. Interactive Map Pin Area
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MapPane(
                  initialCenter: _currentLocation,
                  initialZoom: AppConstants.defaultMapZoom,
                  onPositionChanged: (pos) {
                    _currentLocation = pos;
                  },
                ),
                // Center pin crosshair
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Icon(
                    Icons.location_pin,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // 2. Address Form Inputs
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenGutter),
              children: [
                // Label choice chips
                Text(
                  'Address Label',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: AddressLabel.values.map((label) {
                    final isSelected = label == _selectedLabel;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label.displayName),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedLabel = label),
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
                      ),
                    );
                  }).toList(),
                ),

                if (_selectedLabel == AddressLabel.other) ...[
                  const SizedBox(height: AppSpacing.s),
                  AppTextField(
                    hintText: 'Custom label (e.g. Gym, Friend\'s House)',
                    controller: _customLabelController,
                  ),
                ],
                const SizedBox(height: AppSpacing.m),

                // Street / House Address
                Text(
                  'Address Line',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  hintText: 'House 42, Road 11, Block D',
                  controller: _addressLineController,
                ),
                const SizedBox(height: AppSpacing.m),

                // Area / Neighborhood
                Text(
                  'Area / Neighborhood',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  hintText: 'Banani, Dhaka',
                  controller: _areaController,
                ),
                const SizedBox(height: AppSpacing.m),

                // Floor / Apartment
                Text(
                  'Floor / Apartment',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  hintText: 'Apt 4B (4th Floor), Green Villa',
                  controller: _floorAptController,
                ),
                const SizedBox(height: AppSpacing.m),

                // Delivery instructions
                Text(
                  l10n.deliveryInstructions,
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  hintText: 'Gate code 1234, leave with guard if absent',
                  controller: _instructionsController,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.m),

                // Set as default switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Set as default delivery address',
                    style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  value: _isDefault,
                  activeTrackColor: primaryColor,
                  onChanged: (val) => setState(() => _isDefault = val),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Save button
                AppButton.prominent(
                  label: 'Save Address',
                  variant: AppButtonVariant.primary,
                  isLoading: _isSaving,
                  onPressed: _saveAddress,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
