import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatThreadModel> fetchThread(String threadUuid);
  Future<List<ChatMessageModel>> fetchMessages(String threadUuid);
  Future<ChatMessageModel> sendMessage({
    required String threadUuid,
    required String text,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ChatThreadModel> fetchThread(String threadUuid) async {
    try {
      final response = await _apiClient.get('/api/v1/chat/threads/$threadUuid/');
      return ChatThreadModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      // Fallback thread
    }

    return ChatThreadModel(
      uuid: threadUuid,
      orderUuid: 'ord_active',
      participantName: 'Rahim Uddin',
      participantRole: 'Delivery Rider',
      messages: [
        ChatMessageModel(
          id: 'm1',
          threadUuid: threadUuid,
          senderType: MessageSenderType.rider,
          senderName: 'Rahim Uddin',
          text: 'Hello! I picked up your order and I am on the way.',
          status: MessageStatus.read,
          createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
      ],
    );
  }

  @override
  Future<List<ChatMessageModel>> fetchMessages(String threadUuid) async {
    final thread = await fetchThread(threadUuid);
    return thread.messages;
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String threadUuid,
    required String text,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.chatMessages(threadUuid),
        data: {'text': text},
      );
      return ChatMessageModel.fromJson(response as Map<String, dynamic>, defaultThreadUuid: threadUuid);
    } catch (_) {
      return ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        threadUuid: threadUuid,
        senderType: MessageSenderType.customer,
        senderName: 'You',
        text: text,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      );
    }
  }
}
