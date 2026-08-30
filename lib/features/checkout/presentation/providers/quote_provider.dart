import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/quote_remote_data_source.dart';
import '../../domain/models/quote_model.dart';

final quoteRemoteDataSourceProvider = Provider<QuoteRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuoteRemoteDataSourceImpl(apiClient);
});

class QuoteState {
  final bool isLoading;
  final QuoteModel? quote;
  final int remainingSeconds;
  final bool isExpired;
  final String? errorMessage;

  const QuoteState({
    this.isLoading = false,
    this.quote,
    this.remainingSeconds = 300,
    this.isExpired = false,
    this.errorMessage,
  });

  QuoteState copyWith({
    bool? isLoading,
    QuoteModel? quote,
    int? remainingSeconds,
    bool? isExpired,
    String? errorMessage,
  }) {
    return QuoteState(
      isLoading: isLoading ?? this.isLoading,
      quote: quote ?? this.quote,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isExpired: isExpired ?? this.isExpired,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final quoteProvider = StateNotifierProvider.autoDispose<QuoteNotifier, QuoteState>((ref) {
  final remoteDataSource = ref.watch(quoteRemoteDataSourceProvider);
  return QuoteNotifier(remoteDataSource);
});

class QuoteNotifier extends StateNotifier<QuoteState> {
  final QuoteRemoteDataSource _dataSource;
  Timer? _countdownTimer;

  QuoteNotifier(this._dataSource) : super(const QuoteState());

  Future<void> fetchQuote({
    required String restaurantUuid,
    required String deliveryAddressId,
    required List<dynamic> items,
    required double deliveryFee,
    String? voucherCode,
    double discountAmount = 0.0,
  }) async {
    _countdownTimer?.cancel();
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final quote = await _dataSource.requestQuote(
        restaurantUuid: restaurantUuid,
        deliveryAddressId: deliveryAddressId,
        items: items.cast(),
        deliveryFee: deliveryFee,
        voucherCode: voucherCode,
        discountAmount: discountAmount,
      );

      final seconds = quote.remainingDuration.inSeconds;
      state = state.copyWith(
        isLoading: false,
        quote: quote,
        remainingSeconds: seconds,
        isExpired: seconds <= 0,
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(remainingSeconds: 0, isExpired: true);
      }
    });
  }

  Future<void> refreshActiveQuote() async {
    if (state.quote == null) return;
    _countdownTimer?.cancel();
    state = state.copyWith(isLoading: true);

    try {
      final newQuote = await _dataSource.refreshQuote(state.quote!.quoteId);
      final seconds = newQuote.remainingDuration.inSeconds > 0
          ? newQuote.remainingDuration.inSeconds
          : 300;

      state = state.copyWith(
        isLoading: false,
        quote: newQuote,
        remainingSeconds: seconds,
        isExpired: false,
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
