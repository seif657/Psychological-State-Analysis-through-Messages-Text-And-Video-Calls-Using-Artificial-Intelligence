import '../controllers/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupPage extends StatelessWidget {
  final SignupController controller = Get.put(SignupController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.1),
                _buildHeader(screenWidth),
                SizedBox(height: screenHeight * 0.03),
                _buildTextFields(),
                SizedBox(height: screenHeight * 0.03),
                _buildSignupButton(screenWidth),
                SizedBox(height: screenHeight * 0.04),
                _buildOrDivider(screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _buildSocialButtons(screenWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'images/happy.png',
        ),
        SizedBox(width: screenWidth * 0.03),
        Text(
          'EmoConnect',
          style: TextStyle(
            fontSize: screenWidth * 0.07,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Re-enter Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton(double screenWidth) {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () {
                final email = emailController.text.trim();
                final password = passwordController.text;
                final confirmPassword = confirmPasswordController.text;

                // Email validation: only letters and numbers before "@emoconnect"
                RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9]+@emoconnect.com$');
                if (!emailRegExp.hasMatch(email)) {
                  Get.snackbar(
                    'Error',
                    'Email must contain only letters and numbers followed by @emoconnect',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Password validation: must have at least 2 uppercase letters
                // and at least one special symbol (e.g., !, @)
                RegExp uppercaseRegExp = RegExp(r'(.*[A-Z].*[A-Z])');
                RegExp specialCharRegExp = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
                if (!uppercaseRegExp.hasMatch(password) ||
                    !specialCharRegExp.hasMatch(password)) {
                  Get.snackbar(
                    'Error',
                    'Password must contain at least 2 uppercase letters and at least one special symbol (e.g., !, @)',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Re-enter Password validation
                if (password != confirmPassword) {
                  Get.snackbar(
                    'Error',
                    'Passwords do not match',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                // All validations passed, proceed with signup
                controller.signUp(nameController.text, email, password);
              },
        child: controller.isLoading.value
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              )
            : Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.white,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
      ),
    );
  }

  Widget _buildOrDivider(double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: Colors.black),
        ),
        Expanded(
          child: Container(height: 1, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildSocialButtons(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'images/happy.png',
        ),
        SizedBox(width: screenWidth * 0.04),
        Image.asset(
          'images/sad.png',
        ),
        SizedBox(width: screenWidth * 0.04),
        Image.asset('images/angry.png'),
      ],
    );
  }
}
