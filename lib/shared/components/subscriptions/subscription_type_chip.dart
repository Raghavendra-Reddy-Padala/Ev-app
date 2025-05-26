import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionTypeChip extends StatelessWidget {
  final String type;

  const SubscriptionTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        type.toUpperCase(),
        style: AppTextThemes.bodySmall().copyWith(
          color: Colors.orange.shade700,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}
