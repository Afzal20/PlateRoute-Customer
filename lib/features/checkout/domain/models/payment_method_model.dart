import 'package:flutter/material.dart';

enum PaymentMethodType {
  bkash,
  nagad,
  card,
  cod;

  String get displayName {
    switch (this) {
      case PaymentMethodType.bkash:
        return 'bKash';
      case PaymentMethodType.nagad:
        return 'Nagad';
      case PaymentMethodType.card:
        return 'Credit / Debit Card';
      case PaymentMethodType.cod:
        return 'Cash on Delivery';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethodType.bkash:
        return 'Pay instantly with bKash wallet';
      case PaymentMethodType.nagad:
        return 'Pay instantly with Nagad wallet';
      case PaymentMethodType.card:
        return 'Visa, Mastercard, AMEX';
      case PaymentMethodType.cod:
        return 'Pay exact cash to rider upon delivery';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.bkash:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethodType.nagad:
        return Icons.payments_rounded;
      case PaymentMethodType.card:
        return Icons.credit_card_rounded;
      case PaymentMethodType.cod:
        return Icons.handshake_rounded;
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentMethodType.bkash:
        return 'bkash';
      case PaymentMethodType.nagad:
        return 'nagad';
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.cod:
        return 'cash_on_delivery';
    }
  }
}
