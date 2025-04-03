import 'package:flutter/material.dart'; // Added this import for TextEditingController
import 'package:get/get.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:settings/pages/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricController extends GetxController {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final RxBool _isAuthenticating = false.obs;
  final RxString _authError = ''.obs;
  final RxInt _attempts = 0.obs;
  final int maxAttempts = 3;

  bool get isAuthenticating => _isAuthenticating.value;
  String get authError => _authError.value;
  int get attempts => _attempts.value;

  Future<bool> checkDeviceLock() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> checkAppSecurity() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('app_pin');
    final password = prefs.getString('app_password');
    final useFingerprint = prefs.getBool('use_fingerprint') ?? false;
    final useFace = prefs.getBool('use_face') ?? false;
    final useDeviceSecurity = prefs.getBool('use_device_security') ?? false;

    if (useDeviceSecurity) {
      return await authenticateWithDevice();
    } else if (pin != null || password != null) {
      if (useFingerprint || useFace) {
        return await authenticateWithBiometrics();
      } else {
        return await _promptAppPinOrPassword(pin, password);
      }
    }
    return true; // No security set, proceed
  }

  Future<bool> _promptAppPinOrPassword(String? pin, String? password) async {
    final TextEditingController controller = TextEditingController();
    bool isAuthenticated = false;

    await Get.dialog(
      AlertDialog(
        title: Text(pin != null ? 'Enter PIN' : 'Enter Password'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: pin != null ? 'PIN' : 'Password',
          ),
          keyboardType: pin != null ? TextInputType.number : TextInputType.text,
          obscureText: password != null,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if ((pin != null && controller.text == pin) ||
                  (password != null && controller.text == password)) {
                isAuthenticated = true;
                Get.back();
              } else {
                Get.snackbar('Error', 'Incorrect PIN/Password');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    return isAuthenticated;
  }

  Future<bool> authenticateWithBiometrics() async {
    if (_attempts.value >= maxAttempts) {
      _authError.value = 'Maximum attempts reached. Please try again later.';
      return false;
    }

    _isAuthenticating.value = true;
    _authError.value = '';

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate using your biometric to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!didAuthenticate) {
        _attempts.value++;
        _authError.value =
            'Authentication failed. Attempt ${_attempts.value}/$maxAttempts';
      } else {
        _attempts.value = 0;
        Get.off(() => const WelcomeScreen());
      }

      return didAuthenticate;
    } catch (e) {
      _attempts.value++;
      if (e == auth_error.lockedOut || e == auth_error.permanentlyLockedOut) {
        _authError.value = 'Too many attempts. Try again later.';
      } else {
        _authError.value = 'Error during authentication: ${e.toString()}';
      }
      return false;
    } finally {
      _isAuthenticating.value = false;
    }
  }

  Future<bool> authenticateWithDevice() async {
    if (_attempts.value >= maxAttempts) {
      _authError.value = 'Maximum attempts reached. Please try again later.';
      return false;
    }

    _isAuthenticating.value = true;
    _authError.value = '';

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Authenticate using your device PIN/password to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (!didAuthenticate) {
        _attempts.value++;
        _authError.value =
            'Authentication failed. Attempt ${_attempts.value}/$maxAttempts';
      } else {
        _attempts.value = 0;
        Get.off(() => const WelcomeScreen());
      }

      return didAuthenticate;
    } catch (e) {
      _attempts.value++;
      if (e == auth_error.lockedOut || e == auth_error.permanentlyLockedOut) {
        _authError.value = 'Too many attempts. Try again later.';
      } else {
        _authError.value = 'Error during authentication: ${e.toString()}';
      }
      return false;
    } finally {
      _isAuthenticating.value = false;
    }
  }

  void resetAttempts() {
    _attempts.value = 0;
    _authError.value = '';
  }
}
