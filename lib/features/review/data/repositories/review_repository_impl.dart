import '../../domain/models/review_model.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ReviewModel> submitReview({
    required String orderUuid,
    required String restaurantUuid,
    required double rating,
    required String comment,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  }) async {
    return await remoteDataSource.createReview(
      orderUuid: orderUuid,
      restaurantUuid: restaurantUuid,
      rating: rating,
      comment: comment,
      tags: tags,
      imageUrls: imageUrls,
    );
  }

  @override
  Future<List<ReviewModel>> getRestaurantReviews(String restaurantUuid) async {
    return await remoteDataSource.fetchRestaurantReviews(restaurantUuid);
  }
}
