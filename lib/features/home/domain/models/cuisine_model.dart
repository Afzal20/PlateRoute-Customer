class CuisineModel {
  final String id;
  final String name;
  final String? nameBn;
  final String imageUrl;
  final String slug;

  const CuisineModel({
    required this.id,
    required this.name,
    this.nameBn,
    required this.imageUrl,
    required this.slug,
  });

  factory CuisineModel.fromJson(Map<String, dynamic> json) {
    return CuisineModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nameBn: json['name_bn'] as String?,
      imageUrl: (json['image_url'] ?? json['image'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_bn': nameBn,
      'image_url': imageUrl,
      'slug': slug,
    };
  }
}
