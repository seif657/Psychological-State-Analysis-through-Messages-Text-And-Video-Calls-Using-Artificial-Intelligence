import 'package:feeling_sync_chat/constant/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

class AuthService extends GetxService {
  int? _currentUserId;

  int? get currentUserId => _currentUserId;

  /// Login and store token + currentUserId
// In your AuthService
  Future<String?> login(String email, String password) async {
    print('Making API call to: ${ApiConstants.baseUrl}/api/login'); // Add this
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('API response: ${response.statusCode} ${response.body}'); // Add this

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUserId = data['user']?['id']; // Check if this matches your API
      return data['token'];
    }
    return null;
  }

  /// Signup and store user ID if possible
  Future<bool> signUp(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/registration'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];

      if (user != null && user['id'] != null) {
        _currentUserId = user['id'];
        await _saveUserId(_currentUserId!);
      }

      return true;
    }

    return false;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
  }

  Future<int?> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  /// Call this on app start to restore userId from storage
  Future<void> loadCurrentUserId() async {
    _currentUserId = await getUserIdFromPrefs();
  }
}
