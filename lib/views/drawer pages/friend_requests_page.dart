import 'package:feeling_sync_chat/controllers/friend_request_controller.dart';
import 'package:feeling_sync_chat/controllers/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class FriendRequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Use GetX dependency injection instead of direct instantiation
    final FriendRequestController controller = Get.put(FriendRequestController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // ✅ FIX: Properly reload requests
              controller.loadRequests();
            },
          ),
        ],
      ),
      // ✅ FIX: Use Obx for reactive UI instead of StatefulWidget
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.error.value,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.loadRequests();
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        if (controller.requests.isEmpty) {
          return const Center(
            child: Text(
              "No incoming friend requests.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        // ✅ FIX: Use controller.requests directly (reactive)
        return ListView.builder(
          itemCount: controller.requests.length,
          itemBuilder: (context, index) {
            final request = controller.requests[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red[100],
                  child: Text(
                    request.name.isNotEmpty ? request.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  request.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: controller.isLoading.value 
                          ? null 
                          : () async {
                              await controller.acceptRequest(request.id);
                              // ✅ FIX: Refresh home page friends list
                              try {
                                final homePageController = Get.find<HomePageController>();
                                homePageController.refreshAcceptedFriends();
                              } catch (e) {
                                // HomePageController might not be available
                                print('HomePageController not found: $e');
                              }
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: controller.isLoading.value 
                          ? null 
                          : () async {
                              await controller.rejectRequest(request.id);
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}