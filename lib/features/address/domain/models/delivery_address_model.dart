enum AddressLabel {
  home,
  work,
  other;

  static AddressLabel fromString(String val) {
    switch (val.toLowerCase()) {
      case 'home':
        return AddressLabel.home;
      case 'work':
      case 'office':
        return AddressLabel.work;
      case 'other':
      default:
        return AddressLabel.other;
    }
  }

  String get displayName {
    switch (this) {
      case AddressLabel.home:
        return 'Home';
      case AddressLabel.work:
        return 'Work';
      case AddressLabel.other:
        return 'Other';
    }
  }
}

class DeliveryAddressModel {
  final String id;
  final AddressLabel label;
  final String customLabel;
  final String addressLine;
  final String area;
  final String? floorApt;
  final String? deliveryInstructions;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const DeliveryAddressModel({
    required this.id,
    this.label = AddressLabel.home,
    this.customLabel = '',
    required this.addressLine,
    required this.area,
    this.floorApt,
    this.deliveryInstructions,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  String get formattedLabel => label == AddressLabel.other && customLabel.isNotEmpty
      ? customLabel
      : label.displayName;

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      label: AddressLabel.fromString((json['label'] ?? 'home').toString()),
      customLabel: (json['custom_label'] ?? '').toString(),
      addressLine: (json['address_line'] ?? json['address'] ?? json['street'] ?? '').toString(),
      area: (json['area'] ?? json['city'] ?? 'Dhaka').toString(),
      floorApt: json['floor_apt'] as String? ?? json['building'] as String?,
      deliveryInstructions: json['delivery_instructions'] as String? ?? json['notes'] as String?,
      latitude: (json['latitude'] ?? json['lat'] ?? 23.8103).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? 90.4125).toDouble(),
      isDefault: json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label.name,
      'custom_label': customLabel,
      'address_line': addressLine,
      'area': area,
      'floor_apt': floorApt,
      'delivery_instructions': deliveryInstructions,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  DeliveryAddressModel copyWith({
    String? id,
    AddressLabel? label,
    String? customLabel,
    String? addressLine,
    String? area,
    String? floorApt,
    String? deliveryInstructions,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return DeliveryAddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      customLabel: customLabel ?? this.customLabel,
      addressLine: addressLine ?? this.addressLine,
      area: area ?? this.area,
      floorApt: floorApt ?? this.floorApt,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
