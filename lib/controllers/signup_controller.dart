import 'package:feeling_sync_chat/views/bottom_navigation_bar.dart';
import 'package:feeling_sync_chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  // Dependencies
  final AuthService _authService;

  // Form Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Reactive State
  final RxBool isLoading = false.obs;
  final RxString formError = ''.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  SignupController({AuthService? authService})
      : _authService = authService ?? Get.find<AuthService>();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Handles the signup process
  Future<void> signUp(String text, String email, String password) async {
    // Validate inputs
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;
      formError.value = '';

      // Perform registration
      final success = await _authService.signUp(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      if (success) {
        _navigateToHome();
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        formError.value = 'Registration failed. Please try again.';
      }
    } catch (e) {
      formError.value = 'Signup error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Validates all form inputs
  bool _validateInputs() {
    // Name validation
    if (nameController.text.trim().isEmpty) {
      formError.value = 'Please enter your name';
      return false;
    }

    // Email validation
    if (!emailController.text.trim().endsWith('@emoconnect.com')) {
      formError.value = 'Please use your @emoconnect.com email';
      return false;
    }

    // Password validation
    final hasTwoUppercase = RegExp(r'[A-Z].*[A-Z]').hasMatch(passwordController.text);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(passwordController.text);

    if (!hasTwoUppercase || !hasSpecialChar) {
      formError.value = 'Password must contain:\n- 2 uppercase letters\n- 1 special character';
      return false;
    }

    // Password confirmation
    if (passwordController.text != confirmPasswordController.text) {
      formError.value = 'Passwords do not match';
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

  /// Toggles confirm password visibility
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }
}