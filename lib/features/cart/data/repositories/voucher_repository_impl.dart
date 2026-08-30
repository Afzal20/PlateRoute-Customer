import '../../domain/models/voucher_model.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../datasources/voucher_remote_data_source.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherRemoteDataSource remoteDataSource;

  VoucherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VoucherModel>> getAvailableVouchers({String? restaurantUuid}) async {
    return await remoteDataSource.fetchAvailableVouchers(restaurantUuid: restaurantUuid);
  }

  @override
  Future<VoucherValidationResult> validateVoucher(
    String code, {
    required double subtotal,
    required double deliveryFee,
    String? restaurantUuid,
  }) async {
    return await remoteDataSource.validateVoucher(
      code,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      restaurantUuid: restaurantUuid,
    );
  }
}
