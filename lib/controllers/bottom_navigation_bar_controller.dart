import 'package:feeling_sync_chat/views/bottom%20navigation%20bar%20pages/notification_page.dart';
import 'package:feeling_sync_chat/views/bottom%20navigation%20bar%20pages/home_page.dart';
import 'package:feeling_sync_chat/services/friend_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigationBarController extends GetxController {
  // Reactive state variables
  final currentTab = 0.obs;
  final isLoading = false.obs;

  final List<Widget> screens = [
    HomePage(),
    NotificationPage(),
  ];

  // Services
  final FriendService _friendService = Get.find<FriendService>();

  // Tab management
  void changeTab(int index) {
    currentTab.value = index;
  }

  // Friend search and requests
  Future<String?> searchFriend(String name) async {
    try {
      isLoading.value = true;
      return await _friendService.searchFriend(name);
    } catch (e) {
      _showError('Search failed: ${e.toString()}');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> sendFriendRequest(String name) async {
    try {
      isLoading.value = true;
      return await _friendService.sendFriendRequest(name);
    } catch (e) {
      _showError('Failed to send request: ${e.toString()}');
      return 'Failed to send request: ${e.toString()}'; // Added return statement
    } finally {
      isLoading.value = false;
    }
  }

  // Error handling
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
    );
  }

  Future<String?> fetchFriendName(String name) async {
    try {
      isLoading.value = true;
      // Assuming your FriendService has a method to fetch user info by name
      final friendName = await _friendService.searchFriend(name);
      return friendName;
    } catch (e) {
      _showError('Search failed: ${e.toString()}');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clean up controllers if needed
    super.onClose();
  }
}
