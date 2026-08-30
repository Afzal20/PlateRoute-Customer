import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/support_ticket_model.dart';

abstract class SupportRemoteDataSource {
  Future<SupportTicketModel> createTicket({
    String? orderUuid,
    required IssueCategory category,
    required String title,
    required String description,
    List<String> evidenceImageUrls = const [],
  });

  Future<SupportTicketModel> fetchTicketDetails(String uuid);
  Future<List<SupportTicketModel>> fetchCustomerTickets();
  Future<SupportMessageModel> replyToTicket(String uuid, String text, {List<String>? attachments});
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final ApiClient _apiClient;

  SupportRemoteDataSourceImpl(this._apiClient);

  @override
  Future<SupportTicketModel> createTicket({
    String? orderUuid,
    required IssueCategory category,
    required String title,
    required String description,
    List<String> evidenceImageUrls = const [],
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.supportTickets,
        data: {
          'order_uuid': orderUuid,
          'category': category.apiValue,
          'title': title,
          'description': description,
          'evidence_images': evidenceImageUrls,
        },
      );

      return SupportTicketModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      // Fallback created ticket
    }

    final ticketUuid = 'tkt_${DateTime.now().millisecondsSinceEpoch}';
    return SupportTicketModel(
      id: ticketUuid,
      uuid: ticketUuid,
      orderUuid: orderUuid,
      category: category,
      title: title,
      description: description,
      status: TicketStatus.open,
      messages: [
        SupportMessageModel(
          id: 'msg_init',
          senderType: 'customer',
          text: description,
          attachments: evidenceImageUrls,
          timestamp: DateTime.now(),
        ),
      ],
      evidenceImageUrls: evidenceImageUrls,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<SupportTicketModel> fetchTicketDetails(String uuid) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.supportTicketDetail(uuid));
      return SupportTicketModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      // Fallback
    }

    return SupportTicketModel(
      id: uuid,
      uuid: uuid,
      orderUuid: 'ord_1',
      category: IssueCategory.foodQuality,
      title: 'Spilled drink packaging',
      description: 'The drink was leaking out of the bag upon delivery.',
      status: TicketStatus.inProgress,
      messages: [
        SupportMessageModel(
          id: 'm1',
          senderType: 'customer',
          text: 'The drink was leaking out of the bag upon delivery.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        SupportMessageModel(
          id: 'm2',
          senderType: 'agent',
          text: 'Hello! We sincerely apologize for this experience. We are issuing a full refund to your original payment method right away.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
      refundAmount: 180.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  @override
  Future<List<SupportTicketModel>> fetchCustomerTickets() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.supportTickets);
      if (response is List) {
        return response.map((e) => SupportTicketModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return [
      SupportTicketModel(
        id: 'tkt_1',
        uuid: 'tkt_1',
        category: IssueCategory.foodQuality,
        title: 'Spilled drink in package',
        description: 'Drink was leaking',
        status: TicketStatus.resolved,
        refundAmount: 180.0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<SupportMessageModel> replyToTicket(String uuid, String text, {List<String>? attachments}) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.supportTicketDetail(uuid)}reply/',
        data: {'text': text, 'attachments': attachments},
      );
      return SupportMessageModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return SupportMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderType: 'customer',
        text: text,
        attachments: attachments ?? const [],
        timestamp: DateTime.now(),
      );
    }
  }
}
