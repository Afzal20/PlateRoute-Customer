enum VoucherType {
  percentage,
  fixedAmount,
  freeDelivery;

  static VoucherType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'fixed_amount':
      case 'fixed':
        return VoucherType.fixedAmount;
      case 'free_delivery':
      case 'delivery':
        return VoucherType.freeDelivery;
      case 'percentage':
      default:
        return VoucherType.percentage;
    }
  }

  String get apiValue {
    switch (this) {
      case VoucherType.percentage:
        return 'percentage';
      case VoucherType.fixedAmount:
        return 'fixed_amount';
      case VoucherType.freeDelivery:
        return 'free_delivery';
    }
  }
}

class VoucherModel {
  final String code;
  final String title;
  final String? titleBn;
  final String description;
  final VoucherType type;
  final double discountValue; // percentage (e.g. 20%) or fixed amount (e.g. 50 BDT)
  final double minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? expiryDate;
  final bool isApplicable;

  const VoucherModel({
    required this.code,
    required this.title,
    this.titleBn,
    this.description = '',
    required this.type,
    required this.discountValue,
    this.minOrderAmount = 0.0,
    this.maxDiscountAmount,
    this.expiryDate,
    this.isApplicable = true,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      code: (json['code'] ?? '').toString().toUpperCase(),
      title: (json['title'] ?? json['name'] ?? json['code'] ?? '').toString(),
      titleBn: json['title_bn'] as String?,
      description: (json['description'] ?? '').toString(),
      type: VoucherType.fromString((json['type'] ?? json['discount_type'] ?? 'percentage').toString()),
      discountValue: (json['discount_value'] ?? json['discount'] ?? json['amount'] ?? 0.0).toDouble(),
      minOrderAmount: (json['min_order_amount'] ?? json['min_spend'] ?? 0.0).toDouble(),
      maxDiscountAmount: json['max_discount_amount'] != null
          ? (json['max_discount_amount'] as num).toDouble()
          : null,
      expiryDate: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      isApplicable: json['is_applicable'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'title_bn': titleBn,
      'description': description,
      'type': type.apiValue,
      'discount_value': discountValue,
      'min_order_amount': minOrderAmount,
      'max_discount_amount': maxDiscountAmount,
      'expires_at': expiryDate?.toIso8601String(),
      'is_applicable': isApplicable,
    };
  }

  double calculateDiscount({required double subtotal, required double deliveryFee}) {
    if (subtotal < minOrderAmount) return 0.0;

    switch (type) {
      case VoucherType.percentage:
        final rawDiscount = subtotal * (discountValue / 100.0);
        if (maxDiscountAmount != null) {
          return rawDiscount > maxDiscountAmount! ? maxDiscountAmount! : rawDiscount;
        }
        return rawDiscount;
      case VoucherType.fixedAmount:
        return discountValue > subtotal ? subtotal : discountValue;
      case VoucherType.freeDelivery:
        return deliveryFee;
    }
  }
}

class VoucherValidationResult {
  final bool isValid;
  final VoucherModel? voucher;
  final double discountAmount;
  final String? failureReason;

  const VoucherValidationResult({
    required this.isValid,
    this.voucher,
    this.discountAmount = 0.0,
    this.failureReason,
  });
}
