import 'package:feeling_sync_chat/constant/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

class AuthService extends GetxService {
  int? _currentUserId;
  int? get currentUserId {
    print(
        '🔍 DEBUG - AuthService.currentUserId getter called: $_currentUserId');
    return _currentUserId;
  }

  /// Manually set current user ID (useful for ensuring synchronization)
  void setCurrentUserId(int userId) {
    print('🔍 DEBUG - AuthService.setCurrentUserId called with: $userId');
    _currentUserId = userId;
    _saveUserId(userId);
    print('🔍 DEBUG - AuthService: Manually set currentUserId: $userId');
  }

  /// Login and store token + currentUserId
  Future<String?> login(String email, String password) async {
    print('🔍 DEBUG - Login started for email: $email');
    print('Making API call to: ${ApiConstants.baseUrl}/api/login');
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('API response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data['user']?['id'];
      print(
          '🔍 DEBUG - Received userId from API: $userId (type: ${userId.runtimeType})');

      // Handle both int and string user IDs from API
      if (userId != null) {
        _currentUserId = userId is int ? userId : int.parse(userId.toString());
        print('🔍 DEBUG - Set _currentUserId to: $_currentUserId');
        // Save the current user ID to SharedPreferences during login
        await _saveUserId(_currentUserId!);
        print(
            '🔍 DEBUG - Login: Saved currentUserId to SharedPreferences: $_currentUserId');

        // Verify it was saved
        final verified = await getUserIdFromPrefs();
        print('🔍 DEBUG - Verification read from SharedPreferences: $verified');
      } else {
        print('❌ DEBUG - No userId received from API');
      }
      return data['token'];
    }
    print('🔍 DEBUG - Login failed with status: ${response.statusCode}');
    return null;
  }

  /// Signup and store user ID if possible
  Future<bool> signUp(String name, String email, String password) async {
    print('🔍 DEBUG - Signup started for: $name, $email');
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/registration'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      if (user != null && user['id'] != null) {
        final userId = user['id'];
        _currentUserId = userId is int ? userId : int.parse(userId.toString());
        await _saveUserId(_currentUserId!);
        print('🔍 DEBUG - Signup: Saved currentUserId: $_currentUserId');
      }
      return true;
    }
    return false;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('🔍 DEBUG - Token saved to SharedPreferences');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print(
        '🔍 DEBUG - Retrieved token from SharedPreferences: ${token != null ? "EXISTS" : "NULL"}');
    return token;
  }

  Future<void> _saveUserId(int id) async {
    print('🔍 DEBUG - _saveUserId called with: $id');
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setInt('user_id', id);
    print('🔍 DEBUG - SharedPreferences.setInt result: $success');
  }

  Future<int?> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    print('🔍 DEBUG - Retrieved userId from SharedPreferences: $userId');
    return userId;
  }

  /// Call this on app start to restore userId from storage
  Future<void> loadCurrentUserId() async {
    print('🔍 DEBUG - loadCurrentUserId called');
    _currentUserId = await getUserIdFromPrefs();
    print('🔍 DEBUG - Loaded currentUserId from storage: $_currentUserId');

    // If still null, this is a problem
    if (_currentUserId == null) {
      print(
          '❌ DEBUG - WARNING: currentUserId is still null after loading from SharedPreferences');
    }
  }

  /// Emergency fallback method to manually fix the currentUserId
  Future<void> forceLoadUserId() async {
    print('🔍 DEBUG - forceLoadUserId called');
    final storedUserId = await getUserIdFromPrefs();
    if (storedUserId != null) {
      _currentUserId = storedUserId;
      print('🔍 DEBUG - Force loaded currentUserId: $_currentUserId');
    } else {
      print('❌ DEBUG - No stored userId found in SharedPreferences');
    }
  }
}
