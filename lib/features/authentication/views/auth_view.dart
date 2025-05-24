import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'otp_view.dart';
import '../controller/auth_controller.dart';
import 'login_view.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: AuthContent()),
    );
  }
}

class AuthContent extends StatelessWidget {
  AuthContent({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: controller.authState.value == AuthState.login
            ? LoginScreen(controller: controller)
            : OtpScreen(controller: controller),
      ),
    );
  }
}
