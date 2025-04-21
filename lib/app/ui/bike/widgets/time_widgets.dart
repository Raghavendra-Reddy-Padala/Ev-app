import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimePageWidgets {
  static Widget buildInfoCard(String value, String label) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0.w),
        boxShadow: [
          BoxShadow(color: EVColors.shadowColor),
          BoxShadow(
            color: EVColors.offwhite,
            spreadRadius: 0.0,
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: CustomTextTheme.bodyMediumPBold.copyWith(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 5.w),
              _buildUnitText(label),
            ],
          ),
          Text(
            textAlign: TextAlign.start,
            label,
            style: CustomTextTheme.bodyMediumP.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildUnitText(String label) {
    return Column(
      children: [
        SizedBox(height: 5.h),
        Text(
          label == "Calories" ? "kcal" : "m",
          style: CustomTextTheme.bodySmallP.copyWith(fontSize: 20.sp),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
