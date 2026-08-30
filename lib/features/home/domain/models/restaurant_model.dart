class OperatingHoursModel {
  final int dayOfWeek;
  final String openTime;
  final String closeTime;
  final bool isOpenNow;

  const OperatingHoursModel({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    this.isOpenNow = true,
  });

  factory OperatingHoursModel.fromJson(Map<String, dynamic> json) {
    return OperatingHoursModel(
      dayOfWeek: (json['day_of_week'] ?? 0) as int,
      openTime: (json['open_time'] ?? '').toString(),
      closeTime: (json['close_time'] ?? '').toString(),
      isOpenNow: json['is_open_now'] == true || json['open'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'open_time': openTime,
      'close_time': closeTime,
      'is_open_now': isOpenNow,
    };
  }
}

class BranchModel {
  final String id;
  final String uuid;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final bool isOperating;
  final double? distanceKm;
  final int estimatedDeliveryMinutes;
  final double deliveryFee;

  const BranchModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    this.isOperating = true,
    this.distanceKm,
    this.estimatedDeliveryMinutes = 30,
    this.deliveryFee = 50.0,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      uuid: (json['uuid'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? json['formatted_address'] ?? '').toString(),
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? 0.0).toDouble(),
      phoneNumber: (json['phone_number'] ?? json['phone'] ?? '').toString(),
      isOperating: json['is_operating'] == true || json['is_active'] == true,
      distanceKm: json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
      estimatedDeliveryMinutes: (json['estimated_delivery_minutes'] ?? json['prep_time_minutes'] ?? 30) as int,
      deliveryFee: (json['delivery_fee'] ?? 50.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'is_operating': isOperating,
      'distance_km': distanceKm,
      'estimated_delivery_minutes': estimatedDeliveryMinutes,
      'delivery_fee': deliveryFee,
    };
  }
}

class RestaurantModel {
  final String id;
  final String uuid;
  final String name;
  final String? logoUrl;
  final String coverImageUrl;
  final double rating;
  final int reviewCount;
  final List<String> cuisines;
  final List<BranchModel> branches;
  final double minOrderAmount;
  final double deliveryFee;
  final int estimatedDeliveryMinutes;
  final bool hasActiveDeal;
  final String? dealDescription;
  final bool isOpenNow;
  final bool isFeatured;
  final String? about;

  const RestaurantModel({
    required this.id,
    required this.uuid,
    required this.name,
    this.logoUrl,
    required this.coverImageUrl,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.cuisines = const [],
    this.branches = const [],
    this.minOrderAmount = 0.0,
    this.deliveryFee = 50.0,
    this.estimatedDeliveryMinutes = 35,
    this.hasActiveDeal = false,
    this.dealDescription,
    this.isOpenNow = true,
    this.isFeatured = false,
    this.about,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final rawCuisines = json['cuisines'];
    final List<String> cuisineList = [];
    if (rawCuisines is List) {
      for (final item in rawCuisines) {
        if (item is String) {
          cuisineList.add(item);
        } else if (item is Map && item.containsKey('name')) {
          cuisineList.add(item['name'].toString());
        }
      }
    }

    final rawBranches = json['branches'];
    final List<BranchModel> branchList = [];
    if (rawBranches is List) {
      for (final item in rawBranches) {
        if (item is Map<String, dynamic>) {
          branchList.add(BranchModel.fromJson(item));
        }
      }
    }

    return RestaurantModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      uuid: (json['uuid'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: (json['cover_image_url'] ?? json['image'] ?? '').toString(),
      rating: (json['rating'] ?? json['average_rating'] ?? 4.5).toDouble(),
      reviewCount: (json['review_count'] ?? json['total_reviews'] ?? 0) as int,
      cuisines: cuisineList,
      branches: branchList,
      minOrderAmount: (json['min_order_amount'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 50.0).toDouble(),
      estimatedDeliveryMinutes: (json['estimated_delivery_minutes'] ?? json['prep_time_minutes'] ?? 35) as int,
      hasActiveDeal: json['has_active_deal'] == true || json['deal'] != null,
      dealDescription: json['deal_description'] as String?,
      isOpenNow: json['is_open_now'] != false && json['is_closed'] != true,
      isFeatured: json['is_featured'] == true,
      about: json['about'] as String? ?? json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'logo_url': logoUrl,
      'cover_image_url': coverImageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'cuisines': cuisines,
      'branches': branches.map((e) => e.toJson()).toList(),
      'min_order_amount': minOrderAmount,
      'delivery_fee': deliveryFee,
      'estimated_delivery_minutes': estimatedDeliveryMinutes,
      'has_active_deal': hasActiveDeal,
      'deal_description': dealDescription,
      'is_open_now': isOpenNow,
      'is_featured': isFeatured,
      'about': about,
    };
  }
}
