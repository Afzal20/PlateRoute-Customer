import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/models/order_model.dart';
import '../../domain/repositories/order_repository.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrderRemoteDataSourceImpl(apiClient);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource: remoteDataSource);
});

class OrdersListState {
  final bool isLoading;
  final List<OrderModel> activeOrders;
  final List<OrderModel> pastOrders;
  final String? errorMessage;

  const OrdersListState({
    this.isLoading = true,
    this.activeOrders = const [],
    this.pastOrders = const [],
    this.errorMessage,
  });

  OrdersListState copyWith({
    bool? isLoading,
    List<OrderModel>? activeOrders,
    List<OrderModel>? pastOrders,
    String? errorMessage,
  }) {
    return OrdersListState(
      isLoading: isLoading ?? this.isLoading,
      activeOrders: activeOrders ?? this.activeOrders,
      pastOrders: pastOrders ?? this.pastOrders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final ordersListProvider = StateNotifierProvider<OrdersListNotifier, OrdersListState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrdersListNotifier(repository);
});

class OrdersListNotifier extends StateNotifier<OrdersListState> {
  final OrderRepository _repository;

  OrdersListNotifier(this._repository) : super(const OrdersListState()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final active = await _repository.getActiveOrders();
      final past = await _repository.getOrderHistory();

      state = state.copyWith(
        isLoading: false,
        activeOrders: active,
        pastOrders: past,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}
