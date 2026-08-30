import '../models/support_ticket_model.dart';

abstract class SupportRepository {
  Future<SupportTicketModel> createTicket({
    String? orderUuid,
    required IssueCategory category,
    required String title,
    required String description,
    List<String> evidenceImageUrls = const [],
  });

  Future<SupportTicketModel> getTicketDetails(String uuid);
  Future<List<SupportTicketModel>> getCustomerTickets();
  Future<SupportMessageModel> replyToTicket(String uuid, String text, {List<String>? attachments});
}
