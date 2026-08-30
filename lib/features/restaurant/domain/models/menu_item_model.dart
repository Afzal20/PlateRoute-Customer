class OptionItemModel {
  final String id;
  final String name;
  final String? nameBn;
  final double priceModifier;
  final bool isDefault;
  final bool isAvailable;

  const OptionItemModel({
    required this.id,
    required this.name,
    this.nameBn,
    this.priceModifier = 0.0,
    this.isDefault = false,
    this.isAvailable = true,
  });

  factory OptionItemModel.fromJson(Map<String, dynamic> json) {
    return OptionItemModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nameBn: json['name_bn'] as String?,
      priceModifier: (json['price_modifier'] ?? json['price'] ?? 0.0).toDouble(),
      isDefault: json['is_default'] == true,
      isAvailable: json['is_available'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_bn': nameBn,
      'price_modifier': priceModifier,
      'is_default': isDefault,
      'is_available': isAvailable,
    };
  }
}

class OptionGroupModel {
  final String id;
  final String name;
  final String? nameBn;
  final int minSelections;
  final int maxSelections;
  final bool isRequired;
  final List<OptionItemModel> options;

  const OptionGroupModel({
    required this.id,
    required this.name,
    this.nameBn,
    this.minSelections = 0,
    this.maxSelections = 1,
    this.isRequired = false,
    this.options = const [],
  });

  factory OptionGroupModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final List<OptionItemModel> optList = [];
    if (rawOptions is List) {
      for (final item in rawOptions) {
        if (item is Map<String, dynamic>) {
          optList.add(OptionItemModel.fromJson(item));
        }
      }
    }

    final minSel = (json['min_selections'] ?? (json['is_required'] == true ? 1 : 0)) as int;
    final maxSel = (json['max_selections'] ?? 1) as int;

    return OptionGroupModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nameBn: json['name_bn'] as String?,
      minSelections: minSel,
      maxSelections: maxSel,
      isRequired: json['is_required'] == true || minSel > 0,
      options: optList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_bn': nameBn,
      'min_selections': minSelections,
      'max_selections': maxSelections,
      'is_required': isRequired,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

class MenuItemModel {
  final String id;
  final String uuid;
  final String name;
  final String? nameBn;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final bool isAvailable;
  final bool isPopular;
  final List<OptionGroupModel> optionGroups;
  final String restaurantUuid;

  const MenuItemModel({
    required this.id,
    required this.uuid,
    required this.name,
    this.nameBn,
    this.description = '',
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.isAvailable = true,
    this.isPopular = false,
    this.optionGroups = const [],
    required this.restaurantUuid,
  });

  bool get hasCustomizations => optionGroups.isNotEmpty;

  factory MenuItemModel.fromJson(Map<String, dynamic> json, {String restaurantUuid = ''}) {
    final rawGroups = json['option_groups'] ?? json['groups'];
    final List<OptionGroupModel> groups = [];
    if (rawGroups is List) {
      for (final g in rawGroups) {
        if (g is Map<String, dynamic>) {
          groups.add(OptionGroupModel.fromJson(g));
        }
      }
    }

    return MenuItemModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      uuid: (json['uuid'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nameBn: json['name_bn'] as String?,
      description: (json['description'] ?? '').toString(),
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['original_price'] != null ? (json['original_price'] as num).toDouble() : null,
      imageUrl: (json['image_url'] ?? json['image'] ?? '').toString(),
      isAvailable: json['is_available'] != false && json['available'] != false,
      isPopular: json['is_popular'] == true || json['popular'] == true,
      optionGroups: groups,
      restaurantUuid: (json['restaurant_uuid'] ?? json['restaurant'] ?? restaurantUuid).toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'name_bn': nameBn,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'is_popular': isPopular,
      'option_groups': optionGroups.map((e) => e.toJson()).toList(),
      'restaurant_uuid': restaurantUuid,
    };
  }
}
