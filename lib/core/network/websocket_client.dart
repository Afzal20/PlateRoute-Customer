import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_client.dart';

enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  degraded, // Using HTTP polling fallback
}

class WebSocketClient {
  final String baseWsUrl;
  final SecureStorageService secureStorage;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  final _stateController = StreamController<WsConnectionState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  WsConnectionState _currentState = WsConnectionState.disconnected;

  WebSocketClient({
    required this.baseWsUrl,
    required this.secureStorage,
  });

  Stream<WsConnectionState> get stateStream => _stateController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  WsConnectionState get currentState => _currentState;

  Future<void> connect(String endpointPath) async {
    if (_currentState == WsConnectionState.connected ||
        _currentState == WsConnectionState.connecting) {
      return;
    }

    _setState(WsConnectionState.connecting);

    try {
      final token = await secureStorage.getAccessToken();
      final uriString = '$baseWsUrl$endpointPath${token != null ? '?token=$token' : ''}';
      final uri = Uri.parse(uriString);

      _channel = WebSocketChannel.connect(uri);
      await _channel?.ready;

      _setState(WsConnectionState.connected);
      _reconnectAttempts = 0;
      _startPing();

      _subscription = _channel?.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data.toString()) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (_) {
            // Non-json or ping/pong frame
          }
        },
        onError: (error) {
          _handleDisconnect(endpointPath);
        },
        onDone: () {
          _handleDisconnect(endpointPath);
        },
      );
    } catch (e) {
      _handleDisconnect(endpointPath);
    }
  }

  void _handleDisconnect(String endpointPath) {
    _cleanupChannel();

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      _setState(WsConnectionState.reconnecting);

      final delayMs = 1000 * (1 << _reconnectAttempts); // Exponential backoff: 2s, 4s, 8s...
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
        connect(endpointPath);
      });
    } else {
      // Degraded state: fallback to HTTP polling
      _setState(WsConnectionState.degraded);
    }
  }

  void send(Map<String, dynamic> message) {
    if (_currentState == WsConnectionState.connected && _channel != null) {
      _channel?.sink.add(jsonEncode(message));
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentState == WsConnectionState.connected) {
        send({'type': 'ping'});
      }
    });
  }

  void _setState(WsConnectionState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void _cleanupChannel() {
    _pingTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _cleanupChannel();
    _setState(WsConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _messageController.close();
  }
}

// WebSocketClient Provider
final webSocketClientProvider = Provider.autoDispose<WebSocketClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final wsUrl = AppConfig.instance.wsBaseUrl;
  final client = WebSocketClient(
    baseWsUrl: wsUrl,
    secureStorage: secureStorage,
  );

  ref.onDispose(() {
    client.dispose();
  });

  return client;
});
