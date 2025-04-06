import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "../authentication/controllers/splash_screen_controller.dart";
import '../constants/image_strings.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final SplashScreenController splashController = Get.put(
    SplashScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    splashController.startAnimation();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Obx(
              () => AnimatedPositioned(
                duration: const Duration(milliseconds: 1000),
                top: splashController.animate.value
                    ? MediaQuery.of(context).size.height / 2 - 150
                    : MediaQuery.of(context).size.height,
                left: MediaQuery.of(context).size.width / 2 - 150,
                child: Image.asset(tSplashImage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
