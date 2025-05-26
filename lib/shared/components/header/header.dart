import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/navigation/navigation_service.dart';
import 'package:mjollnir/core/theme/app_theme.dart';
import 'package:mjollnir/shared/components/header/arrow.dart';
import 'package:mjollnir/shared/constants/colors.dart';

class Header extends StatelessWidget {
  final String heading;
  final double? size;
  final Color? color;
  const Header(
      {super.key,
      required this.heading,
      this.size = 40,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Arrow(left: true, color: color, size: size),
            ),
            const SizedBox(width: 5),
            Text(
              heading,
              style: AppTheme.lightTheme().textTheme.headlineSmall?.copyWith(
                  color: (Theme.of(context).brightness == Brightness.light
                      ? AppColors.titletext
                      : Colors.white),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
