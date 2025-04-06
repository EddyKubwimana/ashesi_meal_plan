import 'package:get/get.dart';
import '../controllers/biometric_controller.dart';
import "../../pages/welcome_screen.dart";
import "../../pages/settings_screen.dart";

class SplashScreenController extends GetxController {
  static SplashScreenController get find => Get.find();

  final RxBool animate = false.obs;
  final RxBool showAuthOptions = false.obs;
  final BiometricController _biometricController = Get.put(
    BiometricController(),
  );

  Future<void> startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    animate.value = true;
    await Future.delayed(const Duration(milliseconds: 5000));
    await _checkAppSecurity();
  }

  Future<void> _checkAppSecurity() async {
    final bool isAuthenticated = await _biometricController.checkAppSecurity();
    if (isAuthenticated) {
      Get.off(() => const WelcomeScreen());
    } else {
      Get.off(() => SettingsScreen());
    }
  }
}
