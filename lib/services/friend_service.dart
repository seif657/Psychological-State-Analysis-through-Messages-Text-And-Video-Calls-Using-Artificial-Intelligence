import 'package:feeling_sync_chat/models/friend_request_model.dart';
import 'package:feeling_sync_chat/services/api_service.dart';
import 'package:feeling_sync_chat/models/friend_model.dart';
import 'package:get/get.dart';

class FriendService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<List<Friend>> getFriends() async {
    final response = await _api.get('/api/friends');

    // ✅ FIX: Handle direct array response from Laravel (not wrapped in 'friends' key)
    List<dynamic> friendsData;
    if (response.data is List) {
      friendsData = response.data; // Direct array from your Laravel API
    } else {
      friendsData = response.data['friends'] ?? []; // Fallback if wrapped
    }

    return friendsData.map((json) => Friend.fromJson(json)).toList();
  }

  Future<List<FriendRequest>> getIncomingRequests() async {
    try {
      final response = await _api.get('/api/friends/incoming');
      
      // 🔍 DEBUG: Print the raw response
      print('🔍 DEBUG - Raw API Response: ${response.data}');
      print('🔍 DEBUG - Response type: ${response.data.runtimeType}');

      // ✅ FIX: Handle direct array response from Laravel
      List<dynamic> requestsData;
      if (response.data is List) {
        requestsData = response.data; // Direct array from your Laravel API
      } else {
        requestsData = response.data['requests'] ?? []; // Fallback if wrapped
      }

      print('🔍 DEBUG - Parsed requests data: $requestsData');
      print('🔍 DEBUG - Number of requests: ${requestsData.length}');

      final requests = requestsData.map((json) {
        print('🔍 DEBUG - Processing request: $json');
        return FriendRequest.fromJson(json as Map<String, dynamic>);
      }).toList();

      print('🔍 DEBUG - Final requests list: $requests');
      return requests;
    } catch (e) {
      print('❌ Error in getIncomingRequests: $e');
      rethrow;
    }
  }

  Future<String> searchFriend(String name) async {
    final response = await _api.post('/api/users/search', {'name': name});

    try {
      // Handle when API returns an array of users
      if (response.data is List) {
        final users = response.data as List;
        if (users.isNotEmpty) {
          final firstUser = users.first as Map<String, dynamic>;
          return firstUser['name'] as String? ?? 'User not found';
        } else {
          return 'User not found';
        }
      }

      // Handle when API returns an object with user data
      else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('name')) {
          return data['name'] as String? ?? 'User not found';
        }
      }

      return 'User not found';
    } catch (e) {
      print('Search error: $e');
      return 'User not found';
    }
  }

  Future<String> sendFriendRequest(String name) async {
    final response =
        await _api.post('/api/friends/request', {'friend_name': name});
    return response.data['message'] ?? 'Friend request sent successfully';
  }

  /// Accept friend request using user_id (not request_id) to match Laravel API
  Future<bool> acceptRequest(int userId) async {
    final response =
        await _api.post('/api/friends/accept', {'user_id': userId});
    return response.statusCode == 200;
  }

  /// Reject friend request using user_id (not request_id) to match Laravel API
  Future<bool> rejectRequest(int userId) async {
    final response =
        await _api.post('/api/friends/reject', {'user_id': userId});
    return response.statusCode == 200;
  }

  Future<List<Friend>> getAcceptedFriends() async {
    final response = await _api.get('/api/friends');

    // ✅ FIX: Handle direct array response from Laravel (not wrapped in 'friends' key)
    List<dynamic> friendsData;
    if (response.data is List) {
      friendsData = response.data; // Direct array from your Laravel API
    } else {
      friendsData = response.data['friends'] ?? []; // Fallback if wrapped
    }

    return friendsData.map((json) => Friend.fromJson(json)).toList();
  }

  Future<List<Friend>> searchFriends(String query) async {
    final response = await _api.post('/api/users/search', {'query': query});

    // ✅ FIX: Handle different response structures
    List<dynamic> resultsData;
    if (response.data is List) {
      resultsData = response.data; // Direct array
    } else {
      resultsData = response.data['results'] ?? response.data ?? []; // Fallback
    }

    return resultsData.map((json) => Friend.fromJson(json)).toList();
  }

  Future<void> removeFriend(int friendId) async {
    await _api.delete('/api/friends/$friendId');
  }
}