import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsText extends StatelessWidget {
  const TermsText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "By continuing, you agree to our Terms of Service and Privacy Policy",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12.sp,
      ),
    );
  }
}
