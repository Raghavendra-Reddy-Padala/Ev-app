import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/constants/constants.dart';
import '../../../shared/components/buttons/login_button.dart';
import '../../../shared/components/inputs/phone_field.dart';
import '../../../shared/components/texts/tac.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController controller;

  const LoginScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(Constants.currentLogo),
              SizedBox(height: 90.h),
              Text(
                "Login",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              PhoneField(controller: controller.phoneController),
              SizedBox(height: 15.h),
              LoginButton(
                onTap: controller.handleLogin,
                isLoading: controller.isLoading,
              ),
              SizedBox(height: 20.h),
              // const DividerWithText(text: "or continue with"),
              SizedBox(height: 20.h),
              // SocialLoginButton(
              //   onTap: controller.handleGoogleLogin,
              // ),
              // SizedBox(height: 20.h),
              const TermsText(),
            ],
          ),
        ),
      ),
    );
  }
}
