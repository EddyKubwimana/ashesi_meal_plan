import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:ashesi_meal_plan/screens/login.dart';
import 'package:ashesi_meal_plan/controllers/auth_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final AuthController _authController = Get.find();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Decorations - Corrected Positioned widgets
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(100),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppTheme.primaryColor),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(Icons.person, 'Email',
                    controller: _usernameController),
                _buildTextField(Icons.badge, 'User ID',
                    controller: _userIdController),
                _buildTextField(
                  Icons.lock,
                  'Password',
                  isPassword: true,
                  controller: _passwordController,
                ),
                _buildTextField(
                  Icons.lock,
                  'Confirm Password',
                  isPassword: true,
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 20),
                Obx(() => Center(
                      child: _authController.isLoading.value
                          ? const CircularProgressIndicator(
                              color: AppTheme.primaryColor)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: _handleSignUp,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                    )),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Get.off(() => SignInScreen()),
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
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

  Future<void> _handleSignUp() async {
    if (_usernameController.text.isEmpty ||
        _userIdController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }

    try {
      await _authController.signUp(
        _usernameController.text.trim(),
        _userIdController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}
