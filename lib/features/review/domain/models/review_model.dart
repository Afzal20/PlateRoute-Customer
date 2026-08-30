class ReviewModel {
  final String id;
  final String orderUuid;
  final String restaurantUuid;
  final double rating;
  final String comment;
  final List<String> tags;
  final List<String> imageUrls;
  final String? userName;
  final String? userAvatar;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.orderUuid,
    required this.restaurantUuid,
    required this.rating,
    required this.comment,
    this.tags = const [],
    this.imageUrls = const [],
    this.userName,
    this.userAvatar,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] ?? '').toString(),
      orderUuid: (json['order_uuid'] ?? json['order_id'] ?? '').toString(),
      restaurantUuid: (json['restaurant_uuid'] ?? json['restaurant'] ?? '').toString(),
      rating: (json['rating'] ?? 5.0).toDouble(),
      comment: (json['comment'] ?? json['review'] ?? '').toString(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      imageUrls: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_uuid': orderUuid,
      'restaurant_uuid': restaurantUuid,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'images': imageUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
