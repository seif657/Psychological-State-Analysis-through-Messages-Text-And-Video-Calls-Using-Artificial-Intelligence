import 'package:feeling_sync_chat/services/api_service.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  int? _currentUserId;

  int? get currentUserId => _currentUserId;

  /// Logs in the user and stores currentUserId
  Future<String?> login(String email, String password) async {
    final response = await _apiService.post('/api/login', {
      'email': email,
      'password': password,
    });

    if (response.data['token'] != null) {
      _currentUserId = response.data['user']['id']; // Adjust according to your API
      return response.data['token'];
    }

    return null;
  }

  /// Signs up the user and stores currentUserId
  Future<bool> signUp(String name, String email, String password) async {
    final response = await _apiService.post('/api/signup', {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response.data['user'] != null) {
      _currentUserId = response.data['user']['id']; // Adjust according to your API
      return true;
    }

    return false;
  }

  /// Save token etc (if needed)
  Future<void> saveToken(String token) async {
    // Implement token storage logic here
  }
}
