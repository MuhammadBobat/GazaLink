import 'package:uuid/uuid.dart';

enum Priority { urgent, normal }
enum DeliveryStatus { pending, sent, delivered }

class Message {
  final String id;
  final String content;
  final Priority priority;
  final DateTime timestamp;
  final DeliveryStatus deliveryStatus;

  Message({
    String? id,
    required this.content,
    required this.priority,
    DateTime? timestamp,
    DeliveryStatus? deliveryStatus,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        deliveryStatus = deliveryStatus ?? DeliveryStatus.pending;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'priority': priority.name,
      'timestamp': timestamp.toIso8601String(),
      'deliveryStatus': deliveryStatus.name,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      deliveryStatus: DeliveryStatus.values.firstWhere(
        (e) => e.name == json['deliveryStatus'],
      ),
    );
  }

  Message copyWith({
    String? id,
    String? content,
    Priority? priority,
    DateTime? timestamp,
    DeliveryStatus? deliveryStatus,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
