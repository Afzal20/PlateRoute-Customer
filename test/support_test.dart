import 'package:customer/features/chat/domain/models/chat_message_model.dart';
import 'package:customer/features/review/domain/models/review_model.dart';
import 'package:customer/features/support/domain/models/support_ticket_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Review Domain Tests', () {
    test('ReviewModel serialization and field preservation', () {
      final json = {
        'id': 'rev_99',
        'order_uuid': 'ord_99',
        'restaurant_uuid': 'res_chillox',
        'rating': 4.5,
        'comment': 'Awesome burger and crispy fries',
        'tags': ['Warm & Fresh', 'Great Packaging'],
        'images': ['https://example.com/img.jpg'],
        'created_at': DateTime.now().toIso8601String(),
      };

      final review = ReviewModel.fromJson(json);

      expect(review.rating, 4.5);
      expect(review.tags.length, 2);
      expect(review.imageUrls.first, 'https://example.com/img.jpg');
      expect(review.comment, 'Awesome burger and crispy fries');
    });
  });

  group('Support Ticket Tests', () {
    test('IssueCategory enum fromString mapping and apiValue', () {
      expect(IssueCategory.fromString('late_delivery'), IssueCategory.lateDelivery);
      expect(IssueCategory.fromString('missing_items'), IssueCategory.missingItems);
      expect(IssueCategory.fromString('food_quality'), IssueCategory.foodQuality);
      expect(IssueCategory.fromString('other_unknown'), IssueCategory.other);

      expect(IssueCategory.lateDelivery.apiValue, 'late_delivery');
      expect(IssueCategory.foodQuality.apiValue, 'food_quality');
    });

    test('SupportTicketModel status mapping and message attachments', () {
      final json = {
        'id': 'tkt_123',
        'uuid': 'tkt_123',
        'order_uuid': 'ord_123',
        'category': 'food_quality',
        'title': 'Leaking packaging',
        'description': 'Drink leaked in bag',
        'status': 'in_progress',
        'refund_amount': 250.0,
        'messages': [
          {
            'id': 'm1',
            'sender_type': 'customer',
            'text': 'Here is photo evidence',
            'attachments': ['https://example.com/spill.jpg'],
            'created_at': DateTime.now().toIso8601String(),
          }
        ],
      };

      final ticket = SupportTicketModel.fromJson(json);

      expect(ticket.category, IssueCategory.foodQuality);
      expect(ticket.status, TicketStatus.inProgress);
      expect(ticket.refundAmount, 250.0);
      expect(ticket.messages.length, 1);
      expect(ticket.messages.first.isFromCustomer, true);
      expect(ticket.messages.first.attachments.length, 1);
    });
  });

  group('Chat Message Tests', () {
    test('ChatMessageModel sender recognition and status checkmarks', () {
      final now = DateTime.now();
      final customerMsg = ChatMessageModel(
        id: 'c1',
        threadUuid: 't1',
        senderType: MessageSenderType.customer,
        senderName: 'You',
        text: 'I am downstairs',
        status: MessageStatus.delivered,
        createdAt: now,
      );

      expect(customerMsg.isMe, true);
      expect(customerMsg.status, MessageStatus.delivered);

      final riderMsg = ChatMessageModel(
        id: 'r1',
        threadUuid: 't1',
        senderType: MessageSenderType.rider,
        senderName: 'Rahim',
        text: 'Got it, waiting by gate',
        status: MessageStatus.read,
        createdAt: now,
      );

      expect(riderMsg.isMe, false);
      expect(riderMsg.senderType, MessageSenderType.rider);
    });
  });
}
