import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ashesi_meal_plan/models/user.dart';
import 'package:ashesi_meal_plan/utils/password_utils.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final Rx<User?> _user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? get user => _user.value;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    isLoading.value = true;
    try {
      final userId = await _secureStorage.read(key: 'userId');
      final username = await _secureStorage.read(key: 'username');
      final passwordHash = await _secureStorage.read(key: 'passwordHash');

      if (userId != null && username != null && passwordHash != null) {
        _user.value = User(
          id: userId,
          userId: userId,
          username: username,
          password: passwordHash,
        );
      } else {
        await logout(); // clear invalid session
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user session: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String username, String userId, String password) async {
    isLoading.value = true;
    try {
      final passwordHash = PasswordUtils.hashPassword(password);

      await _secureStorage.write(key: 'userId', value: userId);
      await _secureStorage.write(key: 'username', value: username);
      await _secureStorage.write(key: 'passwordHash', value: passwordHash);

      _user.value = User(
        id: userId,
        userId: userId,
        username: username,
        password: passwordHash,
      );

      Get.offAllNamed(AppRoutes.signIn);
      Get.snackbar('Success', 'Account created successfully!',
          colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Sign Up Error', e.toString(), colorText: Colors.red);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String userId, String password) async {
    isLoading.value = true;
    try {
      final storedUserId = await _secureStorage.read(key: 'userId');
      final storedUsername = await _secureStorage.read(key: 'username');
      final storedPasswordHash = await _secureStorage.read(key: 'passwordHash');

      if (storedUserId == null ||
          storedPasswordHash == null ||
          storedUsername == null) {
        throw 'No account found. Please sign up first.';
      }

      if (storedUserId != userId) {
        throw 'Invalid user ID.';
      }

      if (!PasswordUtils.verifyPassword(password, storedPasswordHash)) {
        throw 'Invalid password.';
      }

      _user.value = User(
        id: storedUserId,
        userId: storedUserId,
        username: storedUsername,
        password: storedPasswordHash,
      );

      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      Get.snackbar('Login Error', e.toString(), colorText: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    _user.value = null;
    Get.offAllNamed(AppRoutes.signIn);
  }
}
