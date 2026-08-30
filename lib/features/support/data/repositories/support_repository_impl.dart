import '../../domain/models/support_ticket_model.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;

  SupportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SupportTicketModel> createTicket({
    String? orderUuid,
    required IssueCategory category,
    required String title,
    required String description,
    List<String> evidenceImageUrls = const [],
  }) async {
    return await remoteDataSource.createTicket(
      orderUuid: orderUuid,
      category: category,
      title: title,
      description: description,
      evidenceImageUrls: evidenceImageUrls,
    );
  }

  @override
  Future<SupportTicketModel> getTicketDetails(String uuid) async {
    return await remoteDataSource.fetchTicketDetails(uuid);
  }

  @override
  Future<List<SupportTicketModel>> getCustomerTickets() async {
    return await remoteDataSource.fetchCustomerTickets();
  }

  @override
  Future<SupportMessageModel> replyToTicket(String uuid, String text, {List<String>? attachments}) async {
    return await remoteDataSource.replyToTicket(uuid, text, attachments: attachments);
  }
}
