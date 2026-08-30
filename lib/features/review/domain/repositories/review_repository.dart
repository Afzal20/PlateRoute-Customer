import '../models/review_model.dart';

abstract class ReviewRepository {
  Future<ReviewModel> submitReview({
    required String orderUuid,
    required String restaurantUuid,
    required double rating,
    required String comment,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  });

  Future<List<ReviewModel>> getRestaurantReviews(String restaurantUuid);
}
