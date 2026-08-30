class BannerModel {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? actionUrl;
  final String? targetRestaurantUuid;

  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.actionUrl,
    this.targetRestaurantUuid,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: json['subtitle'] as String?,
      imageUrl: (json['image_url'] ?? json['image'] ?? '').toString(),
      actionUrl: json['action_url'] as String?,
      targetRestaurantUuid: json['target_restaurant_uuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'target_restaurant_uuid': targetRestaurantUuid,
    };
  }
}
