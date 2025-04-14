import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:ashesi_meal_plan/controllers/auth_controller.dart';
import 'package:ashesi_meal_plan/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthController _authController = Get.find();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _obscurePassword = true;
  late SharedPreferences userInfo;
  bool _showBiometricButton = false;
  bool _biometricAuthInProgress = false;

  @override
  void initState() {
    super.initState();
    _initBiometricAuth();
  }

  Future<void> _initBiometricAuth() async {
    userInfo = await SharedPreferences.getInstance();
    final storedUserId = userInfo.getString("userId");

    if (storedUserId != null) {
      _userIdController.text = storedUserId;
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        setState(() {
          _showBiometricButton = true;
        });
        // Automatically trigger biometric auth
        _authenticateWithBiometrics();
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _biometricAuthInProgress = true;
    });

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'login to Ashesi Meal App',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      Get.snackbar('Error', 'Biometric authentication failed: ${e.toString()}');
    } finally {
      setState(() {
        _biometricAuthInProgress = false;
      });
    }
  }

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
      await userInfo.setString("userId", userId);
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
                    const SizedBox(height: 20),
                    const Text(
                      'Ashesi Meal App',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Column(
                      children: [
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
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
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: AppTheme.primaryColor, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_showBiometricButton && !_biometricAuthInProgress)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side:
                                const BorderSide(color: AppTheme.primaryColor),
                          ),
                          onPressed: _authenticateWithBiometrics,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.fingerprint,
                                  color: AppTheme.primaryColor),
                              SizedBox(width: 8),
                              Text(
                                "Use Fingerprint/Face ID",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_showBiometricButton && !_biometricAuthInProgress)
                      const SizedBox(height: 10),
                    if (_biometricAuthInProgress)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryColor),
                      ),
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
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.offAllNamed(AppRoutes.signUp);
                        },
                        child: const Text(
                          'Sign Up',
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
