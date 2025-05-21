import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../shared/constants/colors.dart';

class OtpField extends StatelessWidget {
  final RxBool isOtpVerified;
  final RxBool isOtpFailed;
  final Function(String) onCompleted;

  const OtpField({
    Key? key,
    required this.isOtpVerified,
    required this.isOtpFailed,
    required this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Pinput(
        length: 6,
        onCompleted: onCompleted,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter OTP';
          }
          if (value.length != 6) {
            return 'Enter a valid 6-digit OTP';
          }
          return null;
        },
        defaultPinTheme: PinTheme(
          textStyle: TextStyle(
            color: isOtpVerified.value ? Colors.green : Colors.white,
            fontWeight: FontWeight.bold,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: (isOtpVerified.value)
                  ? AppColors.primary
                  : (isOtpFailed.value ? Colors.red : Colors.grey),
              width: 2,
            ),
          ),
          padding: EdgeInsets.all(20.w),
        ),
        focusedPinTheme: PinTheme(
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
          ),
          padding: EdgeInsets.all(20.w),
        ),
        submittedPinTheme: PinTheme(
          textStyle: TextStyle(
            color: isOtpVerified.value ? Colors.green : Colors.white,
            fontWeight: FontWeight.bold,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: (isOtpVerified.value)
                  ? AppColors.primary
                  : (isOtpFailed.value ? Colors.red : Colors.grey),
              width: 2,
            ),
          ),
          padding: EdgeInsets.all(20.w),
        ),
      );
    });
  }
}
