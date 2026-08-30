import '../../domain/models/chat_message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ChatThreadModel> getThread(String threadUuid) async {
    return await remoteDataSource.fetchThread(threadUuid);
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String threadUuid) async {
    return await remoteDataSource.fetchMessages(threadUuid);
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String threadUuid,
    required String text,
  }) async {
    return await remoteDataSource.sendMessage(threadUuid: threadUuid, text: text);
  }
}
