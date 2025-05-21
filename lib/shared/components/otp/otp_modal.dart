import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../features/authentication/controller/auth_controller.dart';
import '../../../shared/components/otp/otp_field.dart';
import '../../../shared/constants/colors.dart';

class OtpBottomSheet {
  static Future<void> show(BuildContext context, AuthController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.w),
        ),
      ),
      builder: (context) {
        final padding = MediaQuery.of(context).viewInsets;

        return Padding(
          padding: EdgeInsets.only(bottom: padding.bottom),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 400.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        "Phone Verification",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "A verification code has been sent to",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "phone",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            " +91 ${controller.phoneController.text}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OtpField(
                    isOtpVerified: controller.isOtpVerified,
                    isOtpFailed: controller.isOtpFailed,
                    onCompleted: controller.handleOtpVerification,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: ScreenUtil().screenWidth - 60.w,
                        height: 60.h,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive OTP? ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          _buildResendText(controller),
                        ],
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildResendText(AuthController controller) {
    return Obx(() {
      if (controller.resendTimer.value > 0) {
        return Text(
          "Resend in ${controller.resendTimer}s",
          style: TextStyle(color: Colors.grey),
        );
      }

      return GestureDetector(
        onTap: controller.resendOtp,
        child: Text(
          "Resend",
          style: TextStyle(
            color: AppColors.primary,
          ),
        ),
      );
    });
  }
}
