import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:ashesi_meal_plan/controllers/auth_controller.dart';
import 'package:ashesi_meal_plan/routes/app_routes.dart';

class AppRoutes {
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String dashboard = '/dashboard';
}

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final AuthController _authController = Get.find();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 120,
              height: 100,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'Welcome to the Ashesi Food App 🥙!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Discover the nearest meals around campus — fast, fresh, and convenient.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
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
                _buildTextField(
                  icon: Icons.email,
                  hint: 'Email',
                  controller: _emailController,
                ),
                _buildTextField(
                  icon: Icons.person,
                  hint: 'User ID',
                  controller: _userIdController,
                ),
                _buildTextField(
                  icon: Icons.lock,
                  hint: 'Password',
                  isPassword: true,
                  controller: _passwordController,
                ),
                _buildTextField(
                  icon: Icons.lock,
                  hint: 'Confirm Password',
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
                    onTap: () {
      
      Get.offAllNamed('/sign-in'); 
    },
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

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        key: UniqueKey(),
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
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
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty ||
        _userIdController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    if (!_emailController.text.isEmail) {
      Get.snackbar('Error', 'Please enter a valid email');
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
        _emailController.text.trim(),
        _userIdController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}