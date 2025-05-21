import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/auth_controller.dart';
import '../../../shared/components/buttons/back_button.dart';
import '../../../shared/components/buttons/resend_button.dart';
import '../../../shared/components/otp/otp_field.dart';

class OtpScreen extends StatelessWidget {
  final AuthController controller;

  const OtpScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Enter OTP",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "A verification code has been sent to",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          Text(
            "+91 ${controller.phoneController.text}",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30.h),
          OtpField(
            isOtpVerified: controller.isOtpVerified,
            isOtpFailed: controller.isOtpFailed,
            onCompleted: controller.handleOtpVerification,
          ),
          SizedBox(height: 30.h),
          ResendOtpText(
            resendTimer: controller.resendTimer,
            onResend: controller.resendOtp,
          ),
          SizedBox(height: 20.h),
          BackToLoginButton(
            onTap: controller.goBackToLogin,
          ),
        ],
      ),
    );
  }
}
