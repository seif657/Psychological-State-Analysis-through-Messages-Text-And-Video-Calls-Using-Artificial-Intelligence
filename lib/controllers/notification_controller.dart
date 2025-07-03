import 'package:feeling_sync_chat/models/notification_model.dart' as model;
import 'package:feeling_sync_chat/services/notification_service.dart';
import 'package:feeling_sync_chat/services/pusher_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  // Dependencies
  final NotificationService _notificationService;
  final PusherService _pusherService;

  // Reactive State
  final RxList<model.Notification> notifications = <model.Notification>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt unreadCount = 0.obs;

  NotificationController({
    NotificationService? notificationService,
    PusherService? pusherService,
  })  : _notificationService = notificationService ?? Get.find<NotificationService>(),
        _pusherService = pusherService ?? Get.find<PusherService>();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _setupRealtimeUpdates();
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

  void _setupRealtimeUpdates() {
    _pusherService.subscribeToPrivateChannel('notifications.${_getUserId()}');
    _pusherService.bindEvent('new-notification', (data) {
      final notification = model.Notification.fromJson(data);
      notifications.insert(0, notification);
      unreadCount.value++;
    });
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

  int _getUserId() {
    // TODO: Replace with actual user ID retrieval logic
    return 0;
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
    _pusherService.unsubscribe('notifications.${_getUserId()}');
    super.onClose();
  }
}
