import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/websocket_client.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/models/chat_message_model.dart';
import '../../domain/repositories/chat_repository.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatRemoteDataSourceImpl(apiClient);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource: remoteDataSource);
});

class ChatState {
  final bool isLoading;
  final ChatThreadModel? thread;
  final List<ChatMessageModel> messages;
  final String? errorMessage;

  const ChatState({
    this.isLoading = true,
    this.thread,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    bool? isLoading,
    ChatThreadModel? thread,
    List<ChatMessageModel>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      thread: thread ?? this.thread,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final chatProvider = StateNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, String>((ref, threadUuid) {
  final repository = ref.watch(chatRepositoryProvider);
  final wsClient = ref.watch(webSocketClientProvider);

  return ChatNotifier(
    threadUuid: threadUuid,
    repository: repository,
    wsClient: wsClient,
  );
});

class ChatNotifier extends StateNotifier<ChatState> {
  final String threadUuid;
  final ChatRepository repository;
  final WebSocketClient wsClient;

  ChatNotifier({
    required this.threadUuid,
    required this.repository,
    required this.wsClient,
  }) : super(const ChatState()) {
    initChat();
  }

  Future<void> initChat() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final thread = await repository.getThread(threadUuid);
      state = state.copyWith(
        isLoading: false,
        thread: thread,
        messages: thread.messages,
      );

      _connectSocket();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void _connectSocket() {
    wsClient.connect('/ws/chat/$threadUuid/');
    wsClient.messageStream.listen((msg) {
      if (msg['event'] == 'chat.message' || msg['text'] != null) {
        final data = msg['data'] as Map<String, dynamic>? ?? msg;
        final newMsg = ChatMessageModel.fromJson(data, defaultThreadUuid: threadUuid);

        // Append if not already in list
        if (!state.messages.any((m) => m.id == newMsg.id)) {
          state = state.copyWith(
            messages: List<ChatMessageModel>.from(state.messages)..add(newMsg),
          );
        }
      }
    });
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Optimistic local insertion
    final optimisticMsg = ChatMessageModel(
      id: 'opt_${DateTime.now().millisecondsSinceEpoch}',
      threadUuid: threadUuid,
      senderType: MessageSenderType.customer,
      senderName: 'You',
      text: trimmed,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );

    final updated = List<ChatMessageModel>.from(state.messages)..add(optimisticMsg);
    state = state.copyWith(messages: updated);

    try {
      final sent = await repository.sendMessage(threadUuid: threadUuid, text: trimmed);
      final confirmedList = state.messages.map((m) {
        return m.id == optimisticMsg.id ? sent : m;
      }).toList();

      state = state.copyWith(messages: confirmedList);
    } catch (_) {
      // Revert or mark error
    }
  }
}
