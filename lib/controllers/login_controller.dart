import 'package:feeling_sync_chat/views/bottom_navigation_bar.dart';
import 'package:feeling_sync_chat/services/auth_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // Services
  final AuthService _authService;

  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive State
  final RxBool isLoading = false.obs;
  final RxString formError = ''.obs;
  final RxBool obscurePassword = true.obs;

  LoginController({AuthService? authService})
      : _authService = authService ?? Get.find<AuthService>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Validates and submits login form
  Future<void> login() async {
    print('Login button pressed'); // Add this
    if (!_validateInputs()) {
      print('Validation failed: ${formError.value}'); // Add this
      return;
    }

    try {
      isLoading.value = true;
      formError.value = '';
      print('Attempting login with: ${emailController.text}'); // Add this

      final token = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      print(
          'Login response: ${token != null ? "Success" : "Failed"}'); // Add this

      if (token != null) {
        await _authService.saveToken(token);
        print('Navigation to home'); // Add this
        _navigateToHome();
      } else {
        formError.value = 'Invalid credentials';
      }
    } catch (e) {
      print('Login error: $e'); // Add this
      formError.value = 'Login failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Validates email and password formats
  bool _validateInputs() {
    // Email validation (must end with @emoconnect.com)
    if (!emailController.text.trim().endsWith('@emoconnect.com')) {
      formError.value = 'Please use your @emoconnect.com email';
      return false;
    }

    // Password validation (2 uppercase + 1 special char)
    final hasTwoUppercase =
        RegExp(r'[A-Z].*[A-Z]').hasMatch(passwordController.text);
    final hasSpecialChar =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(passwordController.text);

    if (!hasTwoUppercase || !hasSpecialChar) {
      formError.value =
          'Password must contain:\n- 2 uppercase letters\n- 1 special character';
      return false;
    }

    return true;
  }

  void _navigateToHome() {
    Get.offAll(() => BottomNavigationBarr());
  }

  /// Toggles password visibility
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }
}
