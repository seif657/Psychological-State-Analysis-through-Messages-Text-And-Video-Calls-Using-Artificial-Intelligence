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
    // ✅ Load requests immediately when controller is initialized
    loadRequests();
  }
  /// Loads incoming friend requests with improved error handling
  Future<void> loadRequests() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // ✅ Enhanced debug logging
      print('🔍 [FriendRequestController] Loading friend requests...');
      
      final requestsList = await _friendService.getIncomingRequests();
      
      print('🔍 [FriendRequestController] Received ${requestsList.length} friend requests');
      for (var request in requestsList) {
        print('🔍 [FriendRequestController] Request: ${request.toString()}');
      }
      
      // ✅ Update reactive state
      requests.assignAll(requestsList);
      
      // ✅ Clear any previous errors on success
      if (requestsList.isNotEmpty || error.value.isNotEmpty) {
        error.value = '';
      }
      
      print('✅ [FriendRequestController] Successfully loaded ${requests.length} requests');
      
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to load requests: ${e.toString()}';
      error.value = errorMessage;
      
      // ✅ Enhanced error logging
      print('❌ [FriendRequestController] Error loading requests: $e');
      print('❌ [FriendRequestController] Stack trace: $stackTrace');
      
      _showErrorSnackbar(errorMessage);
      
      // ✅ Clear requests list on error to prevent showing stale data
      requests.clear();
      
    } finally {
      isLoading.value = false;
      print('🏁 [FriendRequestController] Load requests completed. Loading: ${isLoading.value}');
    }
  }
  /// Accepts a friend request with improved error handling
  Future<void> acceptRequest(int userId) async {
    try {
      isLoading.value = true;
      
      print('🔍 [FriendRequestController] Accepting request for user ID: $userId');
      
      final success = await _friendService.acceptRequest(userId);
      
      if (success) {
        // ✅ Remove from local list immediately for better UX
        requests.removeWhere((r) => r.id == userId);
        
        print('✅ [FriendRequestController] Successfully accepted request for user ID: $userId');
        
        Get.snackbar(
          'Success', 
          'Friend request accepted!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Server returned false for accept request');
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to accept request: ${e.toString()}';
      
      print('❌ [FriendRequestController] Error accepting request: $e');
      print('❌ [FriendRequestController] Stack trace: $stackTrace');
      
      _showErrorSnackbar(errorMessage);
      
      // ✅ Reload requests to sync with server state
      await loadRequests();
    } finally {
      isLoading.value = false;
    }
  }
  /// Rejects a friend request with improved error handling
  Future<void> rejectRequest(int userId) async {
    try {
      isLoading.value = true;
      
      print('🔍 [FriendRequestController] Rejecting request for user ID: $userId');
      
      final success = await _friendService.rejectRequest(userId);
      
      if (success) {
        // ✅ Remove from local list immediately for better UX
        requests.removeWhere((r) => r.id == userId);
        
        print('✅ [FriendRequestController] Successfully rejected request for user ID: $userId');
        
        Get.snackbar(
          'Success', 
          'Friend request rejected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Server returned false for reject request');
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to reject request: ${e.toString()}';
      
      print('❌ [FriendRequestController] Error rejecting request: $e');
      print('❌ [FriendRequestController] Stack trace: $stackTrace');
      
      _showErrorSnackbar(errorMessage);
      
      // ✅ Reload requests to sync with server state
      await loadRequests();
    } finally {
      isLoading.value = false;
    }
  }
  /// Enhanced error display
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4), // ✅ Longer duration for error messages
    );
  }
  /// ✅ Add manual refresh method
  Future<void> refresh() async {
    await loadRequests();
  }
  /// ✅ Add method to check if we have data
  bool get hasData => requests.isNotEmpty;
  
  /// ✅ Add method to check if we have an error
  bool get hasError => error.value.isNotEmpty;
}