import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/constants.dart';

class SocialLoginButton extends StatelessWidget {
  final Function onTap;

  const SocialLoginButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350.w,
      height: 50.w,
      child: ElevatedButton.icon(
        icon: SizedBox(height: 20.h, child: Image.asset(Constants.google)),
        label: const Text(
          "Google",
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () => onTap(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
        ),
      ),
    );
  }
}
