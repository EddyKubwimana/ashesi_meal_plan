/// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ashesi_meal_plan/models/user.dart';
import 'package:ashesi_meal_plan/utils/password_utils.dart';

class AuthController extends GetxController {
  final Rx<User?> _user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? get user => _user.value;

  @override
  void onInit() {
    _loadUser();
    super.onInit();
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
          username: username,
          userId: userId,
          password: passwordHash,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String username, String userId, String password) async {
    isLoading.value = true;
    try {
      if (username.isEmpty || userId.isEmpty || password.isEmpty) {
        throw 'All fields are required';
      }

      if (password.length < 8) {
        throw 'Password must be at least 8 characters';
      }

      final passwordHash = PasswordUtils.hashPassword(password);

      await _secureStorage.write(key: 'userId', value: userId);
      await _secureStorage.write(key: 'username', value: username);
      await _secureStorage.write(key: 'passwordHash', value: passwordHash);

      _user.value = User(
        username: username,
        userId: userId,
        password: passwordHash,
      );

      Get.offAllNamed('/home');
      Get.snackbar('Success', 'Account created successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String userId, String password) async {
    try {
      final storedUserId = await _secureStorage.read(key: 'userId');
      final storedUsername = await _secureStorage.read(key: 'username');
      final storedPasswordHash = await _secureStorage.read(key: 'passwordHash');

      if (storedUserId == null || storedPasswordHash == null) {
        throw 'User not found';
      }

      if (storedUserId != userId) {
        throw 'Invalid user ID';
      }

      if (!PasswordUtils.verifyPassword(password, storedPasswordHash)) {
        throw 'Invalid password';
      }

      _user.value = User(
        id: storedUserId,
        username: storedUsername ?? '',
        userId: storedUserId,
        password: storedPasswordHash,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    _user.value = null;
    Get.offAllNamed('/login');
  }
}
