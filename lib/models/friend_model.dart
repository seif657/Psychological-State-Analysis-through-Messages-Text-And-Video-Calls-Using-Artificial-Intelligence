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
      id: _toInt(json['id']), // ✅ Safe conversion from string/int to int
      name: json['name'] as String,
      chatId: _toIntOrNull(
          json['chat_id']), // ✅ Handle missing chat_id from Laravel
      lastActive: _parseDateTime(
          json['last_active']), // ✅ Handle missing last_active from Laravel
    );
  }

  // ✅ Helper: Safely convert dynamic to int
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw FormatException('Cannot convert $value to int');
  }

  // ✅ Helper: Safely convert dynamic to int or null
  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.isEmpty) return null;
      return int.parse(value);
    }
    return null;
  }

  // ✅ Helper: Handle missing or invalid datetime from Laravel
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now(); // Default to now if missing
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now(); // Fallback to now if invalid format
      }
    }
    return DateTime.now(); // Default fallback
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
