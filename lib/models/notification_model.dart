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
      id: _toInt(json['id']), // ✅ Safe conversion from string/int to int
      type: json['type'] as String? ?? 'general', // ✅ Default type if missing
      content: json['content'] as String? ?? '', // ✅ Default content if missing
      isRead: _toBool(json[
          'is_read']), // ✅ Convert int (0/1) to bool (false/true) from Laravel
      createdAt:
          _parseDateTime(json['created_at']), // ✅ Handle datetime from Laravel
    );
  }

  // ✅ Helper: Safely convert dynamic to int
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw FormatException('Cannot convert $value to int');
  }

  // ✅ Helper: Convert Laravel int (0/1) to Dart bool (false/true)
  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0; // 0 = false, any other int = true
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return false; // Default to false for null or invalid values
  }

  // ✅ Helper: Handle datetime from Laravel
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
