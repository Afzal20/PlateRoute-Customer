import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/voucher_remote_data_source.dart';
import '../../data/repositories/voucher_repository_impl.dart';
import '../../domain/models/voucher_model.dart';
import '../../domain/repositories/voucher_repository.dart';

final voucherRemoteDataSourceProvider = Provider<VoucherRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VoucherRemoteDataSourceImpl(apiClient);
});

final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  final remoteDataSource = ref.watch(voucherRemoteDataSourceProvider);
  return VoucherRepositoryImpl(remoteDataSource: remoteDataSource);
});

final availableVouchersProvider = FutureProvider.family<List<VoucherModel>, String?>((ref, restaurantUuid) async {
  final repo = ref.watch(voucherRepositoryProvider);
  return await repo.getAvailableVouchers(restaurantUuid: restaurantUuid);
});
