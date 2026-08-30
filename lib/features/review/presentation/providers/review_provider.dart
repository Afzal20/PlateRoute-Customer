import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/review_remote_data_source.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/models/review_model.dart';
import '../../domain/repositories/review_repository.dart';

final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewRemoteDataSourceImpl(apiClient);
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final remoteDataSource = ref.watch(reviewRemoteDataSourceProvider);
  return ReviewRepositoryImpl(remoteDataSource: remoteDataSource);
});

final restaurantReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, restaurantUuid) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return await repo.getRestaurantReviews(restaurantUuid);
});
