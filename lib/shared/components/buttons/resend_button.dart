import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ResendOtpText extends StatelessWidget {
  final RxInt resendTimer;
  final Function onResend;

  const ResendOtpText({
    Key? key,
    required this.resendTimer,
    required this.onResend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (resendTimer.value > 0) {
        return Text(
          "Resend OTP in ${resendTimer.value} seconds",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        );
      } else {
        return GestureDetector(
          onTap: () => onResend(),
          child: Text(
            "Resend OTP",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    });
  }
}
