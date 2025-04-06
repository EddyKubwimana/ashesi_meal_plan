import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:ashesi_meal_plan/screens/register.dart';
import 'package:ashesi_meal_plan/screens/main.dart';
import 'package:ashesi_meal_plan/controllers/auth_controller.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final AuthController _authController = Get.find();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Right Circle
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom Left Circle
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: "Enter your user ID",
                  icon: Icons.person,
                  controller: _userIdController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  hintText: "Enter your password",
                  icon: Icons.lock,
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password functionality
                    },
                    child: const Text(
                      "Forgot Password?",
                      style:
                          TextStyle(color: AppTheme.primaryColor, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _authController.isLoading.value
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _handleSignIn,
                              child: const Text(
                                "Sign in",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                    )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Get.off(() => SignUpScreen()),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (_userIdController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Both fields are required');
      return;
    }

    try {
      await _authController.login(
        _userIdController.text.trim(),
        _passwordController.text,
      );
      Get.offAll(() => DashboardScreen());
    } catch (e) {
      Get.snackbar('Error', 'Login failed. Please check your credentials');
    }
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility, color: AppTheme.primaryColor)
            : null,
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.primaryColor),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
