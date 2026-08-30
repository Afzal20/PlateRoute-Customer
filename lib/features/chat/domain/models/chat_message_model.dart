enum MessageSenderType {
  customer,
  rider,
  agent,
  system;

  static MessageSenderType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'customer':
      case 'me':
      case 'user':
        return MessageSenderType.customer;
      case 'rider':
      case 'driver':
      case 'courier':
        return MessageSenderType.rider;
      case 'agent':
      case 'support':
        return MessageSenderType.agent;
      case 'system':
      default:
        return MessageSenderType.system;
    }
  }
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read;

  static MessageStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
      default:
        return MessageStatus.read;
    }
  }
}

class ChatMessageModel {
  final String id;
  final String threadUuid;
  final MessageSenderType senderType;
  final String senderName;
  final String text;
  final MessageStatus status;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.threadUuid,
    required this.senderType,
    required this.senderName,
    required this.text,
    this.status = MessageStatus.sent,
    required this.createdAt,
  });

  bool get isMe => senderType == MessageSenderType.customer;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {String defaultThreadUuid = ''}) {
    return ChatMessageModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      threadUuid: (json['thread_uuid'] ?? json['thread_id'] ?? defaultThreadUuid).toString(),
      senderType: MessageSenderType.fromString((json['sender_type'] ?? json['sender'] ?? 'agent').toString()),
      senderName: (json['sender_name'] ?? json['name'] ?? 'Support').toString(),
      text: (json['text'] ?? json['message'] ?? '').toString(),
      status: MessageStatus.fromString((json['status'] ?? 'sent').toString()),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thread_uuid': threadUuid,
      'sender_type': senderType.name,
      'sender_name': senderName,
      'text': text,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ChatMessageModel copyWith({
    MessageStatus? status,
  }) {
    return ChatMessageModel(
      id: id,
      threadUuid: threadUuid,
      senderType: senderType,
      senderName: senderName,
      text: text,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

class ChatThreadModel {
  final String uuid;
  final String orderUuid;
  final String participantName;
  final String participantRole; // Rider, Customer Support
  final List<ChatMessageModel> messages;

  const ChatThreadModel({
    required this.uuid,
    required this.orderUuid,
    required this.participantName,
    required this.participantRole,
    this.messages = const [],
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    final rawMsgs = json['messages'] as List? ?? [];
    final threadUuid = (json['uuid'] ?? json['id'] ?? '').toString();

    final msgs = rawMsgs
        .whereType<Map<String, dynamic>>()
        .map((m) => ChatMessageModel.fromJson(m, defaultThreadUuid: threadUuid))
        .toList();

    return ChatThreadModel(
      uuid: threadUuid,
      orderUuid: (json['order_uuid'] ?? '').toString(),
      participantName: (json['participant_name'] ?? 'Rahim Uddin (Rider)').toString(),
      participantRole: (json['participant_role'] ?? 'Delivery Rider').toString(),
      messages: msgs,
    );
  }
}
