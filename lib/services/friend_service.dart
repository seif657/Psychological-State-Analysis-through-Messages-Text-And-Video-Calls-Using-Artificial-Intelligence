import 'package:feeling_sync_chat/models/friend_model.dart';
import 'package:feeling_sync_chat/models/friend_request_model.dart';
import 'package:feeling_sync_chat/services/api_service.dart';
import 'package:get/get.dart';

class FriendService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<List<Friend>> getFriends() async {
    final response = await _api.get('/api/friends');
    return (response.data['friends'] as List)
        .map((json) => Friend.fromJson(json))
        .toList();
  }

  Future<List<FriendRequest>> getIncomingRequests() async {
    final response = await _api.get('/api/friends/incoming-requests');
    return (response.data['requests'] as List)
        .map((json) => FriendRequest.fromJson(json))
        .toList();
  }

  Future<String> searchFriend(String name) async {
    final response = await _api.post('/api/users/search', {'name': name});
    return response.data['name'];
  }

  Future<String> sendFriendRequest(String name) async {
    final response =
        await _api.post('/api/friends/request', {'friend_name': name});
    return response.data['message'] ?? 'Friend request sent successfully';
  }

  Future<bool> acceptRequest(int requestId) async {
    final response = await _api
        .post('/api/friends/accept-request', {'request_id': requestId});
    return response.statusCode == 200;
  }

  Future<bool> rejectRequest(int requestId) async {
    final response = await _api
        .post('/api/friends/reject-request', {'request_id': requestId});
    return response.statusCode == 200;
  }

  Future<List<Friend>> getAcceptedFriends() async {
    final response = await _api.get('/api/friends/accepted');
    return (response.data['friends'] as List)
        .map((json) => Friend.fromJson(json))
        .toList();
  }

  Future<List<Friend>> searchFriends(String query) async {
    final response = await _api.post('/api/friends/search', {'query': query});
    return (response.data['results'] as List)
        .map((json) => Friend.fromJson(json))
        .toList();
  }

  Future<void> removeFriend(int friendId) async {
    await _api.delete('/api/friends/$friendId');
  }
  
}
