import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/constants/colors.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350.w,
      height: 50.w,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(10.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.r),
          ),
          prefixIcon: SizedBox(
            width: 50.w,
            child: Center(
              child: Text(
                "+91",
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          ),
          hintText: "9999999999",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          contentPadding: EdgeInsets.symmetric(horizontal: 30.w),
        ),
      ),
    );
  }
}
