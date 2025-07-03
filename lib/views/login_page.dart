import 'package:feeling_sync_chat/views/signup_page.dart';
import '../controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.23),
                  Row(
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
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              final email =
                                  controller.emailController.text.trim();
                              final password =
                                  controller.passwordController.text;

                              // Email validation: only letters and numbers before "@emoconnect"
                              RegExp emailRegExp =
                                  RegExp(r'^[a-zA-Z0-9]+@emoconnect.com$');
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

                              // Password validation: must have at least 2 uppercase letters and at least one special symbol
                              RegExp uppercaseRegExp =
                                  RegExp(r'(.*[A-Z].*[A-Z])');
                              RegExp specialCharRegExp =
                                  RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
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

                              // All validations passed; proceed to login
                              controller.login();
                            },
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : Text(
                              'Log In',
                              style: TextStyle(color: Colors.white),
                            ),
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(fontSize: screenWidth * 0.045),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/happy.png',
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Image.asset(
                        'images/sad.png',
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Image.asset(
                        'images/angry.png',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!isKeyboardVisible)
            Padding(
              padding: const EdgeInsets.only(top: 640),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.06),
                  SizedBox(
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.05,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(SignupPage()); // Navigate to Signup
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
