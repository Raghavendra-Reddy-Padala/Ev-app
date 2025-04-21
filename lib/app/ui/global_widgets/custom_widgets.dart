import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Arrow extends StatelessWidget {
  final bool left;

  const Arrow({super.key, required this.left});

  @override
  Widget build(BuildContext context) {
    return Icon(
      left ? Icons.arrow_circle_left : Icons.arrow_circle_right,
      size: left ? 30.w : 40.w,
      color: left ? EVColors.primary : Colors.white,
    );
  }
}
