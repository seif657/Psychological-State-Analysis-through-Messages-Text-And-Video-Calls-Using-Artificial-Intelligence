import 'package:feeling_sync_chat/models/friend_request_model.dart';
import 'package:feeling_sync_chat/services/friend_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendRequestController extends GetxController {
  // Services
  final FriendService _friendService = Get.find<FriendService>();

  // Reactive state
  final RxList<FriendRequest> requests = <FriendRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  /// Loads incoming friend requests
  Future<void> loadRequests() async {
    try {
      isLoading.value = true;
      error.value = '';
      requests.assignAll(await _friendService.getIncomingRequests());
    } catch (e) {
      error.value = 'Failed to load requests: ${e.toString()}';
      _showErrorSnackbar(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Accepts a friend request
  Future<void> acceptRequest(int requestId) async {
    try {
      isLoading.value = true;
      final success = await _friendService.acceptRequest(requestId);
      
      if (success) {
        requests.removeWhere((r) => r.id == requestId);
        Get.snackbar(
          'Success', 
          'Request accepted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _showErrorSnackbar('Failed to accept request: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Rejects a friend request
  Future<void> rejectRequest(int requestId) async {
    try {
      isLoading.value = true;
      final success = await _friendService.rejectRequest(requestId);
      
      if (success) {
        requests.removeWhere((r) => r.id == requestId);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to reject request: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}