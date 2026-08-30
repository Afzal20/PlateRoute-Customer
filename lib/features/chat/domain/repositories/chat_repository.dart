import '../models/chat_message_model.dart';

abstract class ChatRepository {
  Future<ChatThreadModel> getThread(String threadUuid);
  Future<List<ChatMessageModel>> getMessages(String threadUuid);
  Future<ChatMessageModel> sendMessage({
    required String threadUuid,
    required String text,
  });
}
