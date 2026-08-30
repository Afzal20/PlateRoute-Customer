import '../../domain/models/voucher_model.dart';

abstract class VoucherRepository {
  Future<List<VoucherModel>> getAvailableVouchers({String? restaurantUuid});
  Future<VoucherValidationResult> validateVoucher(
    String code, {
    required double subtotal,
    required double deliveryFee,
    String? restaurantUuid,
  });
}
