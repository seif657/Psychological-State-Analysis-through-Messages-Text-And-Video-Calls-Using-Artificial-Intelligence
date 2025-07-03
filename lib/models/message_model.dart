import 'package:feeling_sync_chat/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

@immutable
class Message {
  final int id;
  final int userId;
  final String content;
  final DateTime createdAt;
  final String sentiment;
  final bool isPending;
  final bool isFailed;
  final int? replyToId;

  const Message({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.sentiment = 'neutral',
    this.isPending = false,
    this.isFailed = false,
    this.replyToId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      sentiment: (json['sentiment'] ?? 'neutral') as String,
      replyToId: json['reply_to_id'] as int?,
    );
  }

  Message copyWith({
    int? id,
    int? userId,
    String? content,
    DateTime? createdAt,
    String? sentiment,
    bool? isPending,
    bool? isFailed,
    int? replyToId,
  }) {
    return Message(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      sentiment: sentiment ?? this.sentiment,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
      replyToId: replyToId ?? this.replyToId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'sentiment': sentiment,
      if (replyToId != null) 'reply_to_id': replyToId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.userId == userId &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.sentiment == sentiment &&
        other.isPending == isPending &&
        other.isFailed == isFailed &&
        other.replyToId == replyToId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      content,
      createdAt,
      sentiment,
      isPending,
      isFailed,
      replyToId,
    );
  }

  @override
  String toString() {
    return 'Message('
        'id: $id, '
        'userId: $userId, '
        'content: $content, '
        'createdAt: $createdAt, '
        'sentiment: $sentiment, '
        'isPending: $isPending, '
        'isFailed: $isFailed, '
        'replyToId: $replyToId)';
  }

  /// Helper methods
  bool get isPositive => sentiment == 'positive';
  bool get isNegative => sentiment == 'negative';
  bool get isNeutral => sentiment == 'neutral';

  bool get isFromCurrentUser {
    final authService = Get.find<AuthService>();
    return userId == authService.currentUserId;
  }
}
