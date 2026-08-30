import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityState {
  final bool isConnected;
  final bool isDegraded;

  const ConnectivityState({
    this.isConnected = true,
    this.isDegraded = false,
  });

  ConnectivityState copyWith({
    bool? isConnected,
    bool? isDegraded,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      isDegraded: isDegraded ?? this.isDegraded,
    );
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  Timer? _healthCheckTimer;

  ConnectivityNotifier() : super(const ConnectivityState()) {
    _startMonitoring();
  }

  void _startMonitoring() {
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // Periodic health check
    });
  }

  void setOffline() {
    state = state.copyWith(isConnected: false);
  }

  void setOnline() {
    state = state.copyWith(isConnected: true, isDegraded: false);
  }

  void setDegraded() {
    state = state.copyWith(isDegraded: true);
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    super.dispose();
  }
}
