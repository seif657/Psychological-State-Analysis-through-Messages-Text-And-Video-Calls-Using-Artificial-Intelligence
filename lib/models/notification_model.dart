class Notification {
  final int id;
  final String type;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.type,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Notification copyWith({
    bool? isRead,
  }) {
    return Notification(
      id: id,
      type: type,
      content: content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}