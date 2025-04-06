import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:ashesi_meal_plan/screens/register.dart';
import 'package:ashesi_meal_plan/controllers/auth_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthController _authController = Get.find();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text;

    try {
      await _authController.login(userId, password);
    } catch (e) {
      Get.snackbar('Error', 'Login failed. Please check your credentials');
    }
  }

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
            child: _buildCircle(),
          ),
          // Bottom Left Circle
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildCircle(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      hintText: "Enter your user ID",
                      icon: Icons.person,
                      controller: _userIdController,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      hintText: "Enter your password",
                      icon: Icons.lock,
                      controller: _passwordController,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      togglePasswordVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Forgot Password
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: AppTheme.primaryColor, fontSize: 14),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle() {
    return Container(
      height: 200,
      width: 200,
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final TextEditingController controller;
  final VoidCallback? togglePasswordVisibility;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.togglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.primaryColor,
                ),
                onPressed: togglePasswordVisibility,
              )
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
