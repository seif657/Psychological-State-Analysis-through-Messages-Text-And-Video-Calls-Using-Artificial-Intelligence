import 'package:feeling_sync_chat/controllers/notification_controller.dart';
import 'package:feeling_sync_chat/views/drawer%20pages/friend_requests_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class NotificationPage extends StatelessWidget {
  final NotificationController notificationController =
      Get.put(NotificationController());

  NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch notifications when the page is loaded
    // (Already handled inside controller's onInit(), so optional here)
    // notificationController.fetchNotifications();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              await notificationController.clearNotifications();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (notificationController.notifications.isEmpty) {
          return const Center(
            child: Text(
              'No Notifications',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: notificationController.notifications.length,
          itemBuilder: (context, index) {
            final notification = notificationController.notifications[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: _getNotificationIcon(notification.type),
                title: Text(notification.content,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                    .format(notification.createdAt)),
                onTap: () {
                  // Handle notification click based on type
                  _handleNotificationTap(notification);
                },
              ),
            );
          },
        );
      }),
    );
  }

  // Get icon based on notification type
  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'friend_request':
        return const Icon(Icons.person_add, color: Colors.blue);
      case 'new_message':
        return const Icon(Icons.message, color: Colors.green);
      case 'call-started':
        return const Icon(Icons.call, color: Colors.red);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  // Handle notification tap actions
  void _handleNotificationTap(dynamic notification) {
    switch (notification.type) {
      case 'friend_request':
        Get.to(() => FriendRequestPage());
        break;
      case 'new_message':
        Get.snackbar(
          'New Message',
          'Navigating to chat.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'call-started':
        Get.snackbar(
          'Incoming Call',
          'Navigating to incoming call.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      default:
        Get.snackbar(
          'Notification',
          'Action not defined for this notification.',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }
}
