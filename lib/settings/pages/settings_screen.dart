import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:settings/authentication/controllers/biometric_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  final BiometricController biometricController =
      Get.find<BiometricController>();

  SettingsScreen({Key? key}) : super(key: key);

  Future<void> _setPin(BuildContext context) async {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pinController,
                  decoration: const InputDecoration(
                    labelText: 'Enter PIN (4 digits)',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
                TextField(
                  controller: confirmPinController,
                  decoration: const InputDecoration(labelText: 'Confirm PIN'),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (pinController.text == confirmPinController.text &&
                      pinController.text.length == 4) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('app_pin', pinController.text);
                    Get.back();
                    Get.snackbar('Success', 'PIN set successfully');
                  } else {
                    Get.snackbar(
                      'Error',
                      'PINs do not match or invalid length',
                    );
                  }
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _setPassword(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Password',
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (passwordController.text ==
                          confirmPasswordController.text &&
                      passwordController.text.isNotEmpty) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      'app_password',
                      passwordController.text,
                    );
                    Get.back();
                    Get.snackbar('Success', 'Password set successfully');
                  } else {
                    Get.snackbar('Error', 'Passwords do not match or empty');
                  }
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _setBiometric(BuildContext context, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('app_pin');
    final password = prefs.getString('app_password');

    if (pin == null && password == null) {
      Get.snackbar('Error', 'Please set a PIN or Password first');
      return;
    }

    final availableBiometrics =
        await biometricController.getAvailableBiometrics();
    if (type == 'fingerprint' &&
        !availableBiometrics.contains(BiometricType.fingerprint)) {
      Get.snackbar('Error', 'Fingerprint not supported on this device');
      return;
    }
    if (type == 'face' && !availableBiometrics.contains(BiometricType.face)) {
      Get.snackbar('Error', 'Facial ID not supported on this device');
      return;
    }

    await prefs.setBool('use_$type', true);
    Get.snackbar('Success', '$type authentication enabled');
  }

  Future<void> _useDeviceSecurity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_device_security', true);
    await prefs.remove('app_pin');
    await prefs.remove('app_password');
    await prefs.remove('use_fingerprint');
    await prefs.remove('use_face');
    Get.snackbar('Success', 'App will now use device security');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _setPin(context),
              child: const Text('Set Up PIN'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _setPassword(context),
              child: const Text('Set Up Password'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _setBiometric(context, 'fingerprint'),
              child: const Text('Set Up Fingerprint'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _setBiometric(context, 'face'),
              child: const Text('Set Up Facial ID'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _useDeviceSecurity,
              child: const Text('Use Device Security'),
            ),
          ],
        ),
      ),
    );
  }
}
