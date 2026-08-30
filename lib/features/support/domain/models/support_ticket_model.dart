enum IssueCategory {
  lateDelivery('Late Delivery', 'Delivery arrived well past estimated arrival window'),
  missingItems('Missing Items', 'One or more items or toppings were missing from package'),
  foodQuality('Food Quality / Spilled', 'Food was cold, spoiled, leaked or poorly handled'),
  wrongOrder('Wrong Order', 'Received another customer\'s package entirely'),
  paymentIssue('Payment / Refund', 'Overcharged or refund not reflected in wallet'),
  riderBehavior('Rider Behavior', 'Unprofessional conduct during handoff'),
  other('Other', 'Any other issue requiring support assistance');

  final String title;
  final String description;
  const IssueCategory(this.title, this.description);

  static IssueCategory fromString(String val) {
    switch (val.toLowerCase()) {
      case 'late_delivery':
      case 'late':
        return IssueCategory.lateDelivery;
      case 'missing_items':
      case 'missing':
        return IssueCategory.missingItems;
      case 'food_quality':
      case 'spilled':
        return IssueCategory.foodQuality;
      case 'wrong_order':
        return IssueCategory.wrongOrder;
      case 'payment_issue':
      case 'refund':
        return IssueCategory.paymentIssue;
      case 'rider_behavior':
        return IssueCategory.riderBehavior;
      default:
        return IssueCategory.other;
    }
  }

  String get apiValue {
    switch (this) {
      case IssueCategory.lateDelivery:
        return 'late_delivery';
      case IssueCategory.missingItems:
        return 'missing_items';
      case IssueCategory.foodQuality:
        return 'food_quality';
      case IssueCategory.wrongOrder:
        return 'wrong_order';
      case IssueCategory.paymentIssue:
        return 'payment_issue';
      case IssueCategory.riderBehavior:
        return 'rider_behavior';
      case IssueCategory.other:
        return 'other';
    }
  }
}

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  static TicketStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'open':
        return TicketStatus.open;
      case 'in_progress':
      case 'investigating':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
      default:
        return TicketStatus.closed;
    }
  }

  String get displayName {
    switch (this) {
      case TicketStatus.open:
        return 'Ticket Opened';
      case TicketStatus.inProgress:
        return 'Under Investigation';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }
}

class SupportMessageModel {
  final String id;
  final String senderType; // customer, agent, system
  final String text;
  final List<String> attachments;
  final DateTime timestamp;

  const SupportMessageModel({
    required this.id,
    required this.senderType,
    required this.text,
    this.attachments = const [],
    required this.timestamp,
  });

  bool get isFromCustomer => senderType == 'customer';

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: (json['id'] ?? '').toString(),
      senderType: (json['sender_type'] ?? json['sender'] ?? 'agent').toString(),
      text: (json['text'] ?? json['message'] ?? '').toString(),
      attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_type': senderType,
      'text': text,
      'attachments': attachments,
      'created_at': timestamp.toIso8601String(),
    };
  }
}

class SupportTicketModel {
  final String id;
  final String uuid;
  final String? orderUuid;
  final IssueCategory category;
  final String title;
  final String description;
  final TicketStatus status;
  final List<SupportMessageModel> messages;
  final List<String> evidenceImageUrls;
  final double? refundAmount;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const SupportTicketModel({
    required this.id,
    required this.uuid,
    this.orderUuid,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    this.messages = const [],
    this.evidenceImageUrls = const [],
    this.refundAmount,
    required this.createdAt,
    this.resolvedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final rawMsgs = json['messages'] as List? ?? [];
    final parsedMsgs = rawMsgs
        .whereType<Map<String, dynamic>>()
        .map((m) => SupportMessageModel.fromJson(m))
        .toList();

    return SupportTicketModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      uuid: (json['uuid'] ?? json['id'] ?? '').toString(),
      orderUuid: json['order_uuid'] as String? ?? json['order_id'] as String?,
      category: IssueCategory.fromString((json['category'] ?? 'other').toString()),
      title: (json['title'] ?? 'Support Inquiry').toString(),
      description: (json['description'] ?? '').toString(),
      status: TicketStatus.fromString((json['status'] ?? 'open').toString()),
      messages: parsedMsgs,
      evidenceImageUrls: (json['evidence_images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      refundAmount: json['refund_amount'] != null ? (json['refund_amount'] as num).toDouble() : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'order_uuid': orderUuid,
      'category': category.apiValue,
      'title': title,
      'description': description,
      'status': status.name,
      'messages': messages.map((e) => e.toJson()).toList(),
      'evidence_images': evidenceImageUrls,
      'refund_amount': refundAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
