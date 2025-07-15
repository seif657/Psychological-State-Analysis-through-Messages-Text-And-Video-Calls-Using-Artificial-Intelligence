import 'package:feeling_sync_chat/models/notification_model.dart' as model;
import 'package:feeling_sync_chat/services/notification_service.dart';
import 'package:feeling_sync_chat/services/pusher_service.dart';
import 'package:feeling_sync_chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  // Dependencies
  final NotificationService _notificationService;
  final PusherService _pusherService;
  final AuthService _authService; // ADD THIS
  // Reactive State
  final RxList<model.Notification> notifications = <model.Notification>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt unreadCount = 0.obs;
  NotificationController({
    NotificationService? notificationService,
    PusherService? pusherService,
    AuthService? authService, // ADD THIS
  })  : _notificationService =
            notificationService ?? Get.find<NotificationService>(),
        _pusherService = pusherService ?? Get.find<PusherService>(),
        _authService = authService ?? Get.find<AuthService>(); //ADD THIS
  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _setupRealtimeUpdates(); // This now properly handles async
  }

  /// Wrapper: Fetch notifications via service, update state
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      error.value = '';
      await _notificationService.fetchNotifications();
      notifications.assignAll(_notificationService.notifications);
      _updateUnreadCount();
    } catch (e) {
      error.value = 'Failed to load notifications: ${e.toString()}';
      _showError(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Wrapper: Clear notifications via service, update state
  Future<void> clearNotifications() async {
    try {
      await _notificationService.clearNotifications();
      notifications.clear();
      unreadCount.value = 0;
      Get.snackbar('Success', 'Notifications cleared');
    } catch (e) {
      _showError('Failed to clear notifications: ${e.toString()}');
    }
  }

  /// FIXED: Now properly async and waits for channel subscription
  Future<void> _setupRealtimeUpdates() async {
    try {
      final userId = _getUserId();
      if (userId == null) {
        Get.log('User ID not available, skipping Pusher setup');
        return;
      }
      // Wait for channel subscription to complete before binding
      await _pusherService.subscribeToPrivateChannel('notifications.$userId');
      // Now safely bind to events
      _pusherService.bindEvent('new-notification', (data) {
        final notification = model.Notification.fromJson(data);
        notifications.insert(0, notification);
        unreadCount.value++;
      });
    } catch (e) {
      Get.log('Failed to setup realtime updates: $e');
      _showError('Failed to setup real-time notifications');
    }
  }

  Future<void> markAsRead(model.Notification notification) async {
    try {
      await _notificationService.markAsRead(notification.id);
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification.copyWith(isRead: true);
        _updateUnreadCount();
      }
    } catch (e) {
      _showError('Failed to mark as read: ${e.toString()}');
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  /// FIXED: Now retrieves actual user ID from AuthService
  int? _getUserId() {
    return _authService.currentUserId;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    final userId = _getUserId();
    if (userId != null) {
      _pusherService.unsubscribe('notifications.$userId');
    }
    super.onClose();
  }
}
