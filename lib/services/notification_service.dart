import 'package:feeling_sync_chat/models/notification_model.dart';
import 'package:feeling_sync_chat/services/api_service.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final _notifications = <Notification>[].obs;

  List<Notification> get notifications => _notifications;

  /// Fetches all notifications from the server - adapts to Laravel response structure
  Future<void> fetchNotifications() async {
    try {
      final response = await _apiService.get('/api/notifications');

      // ✅ FIX: Handle different Laravel response structures
      List<dynamic> notificationsData;
      if (response.data is List) {
        notificationsData = response.data; // Direct array from Laravel
      } else {
        notificationsData =
            response.data['notifications'] ?? []; // Wrapped array fallback
      }

      _notifications.assignAll(
        notificationsData.map((json) => Notification.fromJson(json)).toList(),
      );
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Clears all notifications
  Future<void> clearNotifications() async {
    try {
      await _apiService.delete('/api/notifications');
      _notifications.clear();
    } catch (e) {
      throw Exception('Failed to clear notifications: $e');
    }
  }

  /// Marks a notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiService.post(
        '/api/notifications/$notificationId/mark-read',
        {},
      );
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
