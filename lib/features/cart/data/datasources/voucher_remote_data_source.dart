import '../../../../core/network/api_client.dart';
import '../../domain/models/voucher_model.dart';

abstract class VoucherRemoteDataSource {
  Future<List<VoucherModel>> fetchAvailableVouchers({String? restaurantUuid});
  Future<VoucherValidationResult> validateVoucher(
    String code, {
    required double subtotal,
    required double deliveryFee,
    String? restaurantUuid,
  });
}

class VoucherRemoteDataSourceImpl implements VoucherRemoteDataSource {
  final ApiClient _apiClient;

  VoucherRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<VoucherModel>> fetchAvailableVouchers({String? restaurantUuid}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/vouchers/',
        queryParameters: {
          'restaurant': ?restaurantUuid,
        },
      );

      if (response is List) {
        return response.map((e) => VoucherModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map && response.containsKey('results') && response['results'] is List) {
        return (response['results'] as List)
            .map((e) => VoucherModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback coupons
    }

    return _getFallbackVouchers();
  }

  @override
  Future<VoucherValidationResult> validateVoucher(
    String code, {
    required double subtotal,
    required double deliveryFee,
    String? restaurantUuid,
  }) async {
    final upperCode = code.trim().toUpperCase();

    try {
      final response = await _apiClient.post(
        '/api/v1/vouchers/validate/',
        data: {
          'code': upperCode,
          'subtotal': subtotal,
          'restaurant_uuid': restaurantUuid,
        },
      );

      if (response is Map<String, dynamic>) {
        final isValid = response['is_valid'] == true;
        final discount = (response['discount_amount'] ?? 0.0).toDouble();
        final voucherJson = response['voucher'] as Map<String, dynamic>?;

        return VoucherValidationResult(
          isValid: isValid,
          voucher: voucherJson != null ? VoucherModel.fromJson(voucherJson) : null,
          discountAmount: discount,
          failureReason: response['message'] as String?,
        );
      }
    } catch (_) {
      // Client-side validation using fallback list
    }

    final list = _getFallbackVouchers();
    final match = list.firstWhere(
      (v) => v.code == upperCode,
      orElse: () => const VoucherModel(
        code: '',
        title: '',
        type: VoucherType.fixedAmount,
        discountValue: 0,
        isApplicable: false,
      ),
    );

    if (match.code.isEmpty) {
      return const VoucherValidationResult(
        isValid: false,
        failureReason: 'Invalid coupon code. Please check and try again.',
      );
    }

    if (subtotal < match.minOrderAmount) {
      return VoucherValidationResult(
        isValid: false,
        voucher: match,
        failureReason: 'Minimum order of ৳${match.minOrderAmount.toInt()} required for this coupon.',
      );
    }

    final discount = match.calculateDiscount(subtotal: subtotal, deliveryFee: deliveryFee);

    return VoucherValidationResult(
      isValid: true,
      voucher: match,
      discountAmount: discount,
    );
  }

  List<VoucherModel> _getFallbackVouchers() {
    return [
      const VoucherModel(
        code: 'WELCOME50',
        title: '৳50 Off First Order',
        titleBn: 'প্রথম অর্ডারে ৫০ টাকা ছাড়',
        description: 'Get flat ৳50 off on orders above ৳200 across all restaurants.',
        type: VoucherType.fixedAmount,
        discountValue: 50.0,
        minOrderAmount: 200.0,
      ),
      const VoucherModel(
        code: 'PLATE20',
        title: '20% Mega Savings',
        titleBn: '২০% মেগা ডিসকাউন্ট',
        description: 'Save 20% up to ৳100 on qualifying orders above ৳300.',
        type: VoucherType.percentage,
        discountValue: 20.0,
        minOrderAmount: 300.0,
        maxDiscountAmount: 100.0,
      ),
      const VoucherModel(
        code: 'FREEDEL',
        title: 'Free Delivery Weekend',
        titleBn: 'ফ্রি ডেলিভারি উইকএন্ড',
        description: 'Enjoy 100% free delivery fee on orders above ৳250.',
        type: VoucherType.freeDelivery,
        discountValue: 100.0,
        minOrderAmount: 250.0,
      ),
    ];
  }
}
