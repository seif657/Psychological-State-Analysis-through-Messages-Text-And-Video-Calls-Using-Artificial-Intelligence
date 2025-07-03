class Friend {
  final int id;
  final String name;
  final int? chatId;
  final DateTime lastActive;

  Friend({
    required this.id,
    required this.name,
    this.chatId,
    required this.lastActive,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      chatId: json['chat_id'],
      lastActive: DateTime.parse(json['last_active']),
    );
  }

  Friend copyWith({
    int? id,
    String? name,
    int? chatId,
    DateTime? lastActive,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      chatId: chatId ?? this.chatId,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}