import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final double? width;
  final double height;
  // Added parameters for more customization
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BoxBorder? border;
  final Color? splashColor;
  final bool isDisabled;
  final TextStyle? customTextStyle;
  final double? elevation;
  final MainAxisAlignment iconAlignment;
  final double? iconSpacing;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height = 45,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.border,
    this.splashColor,
    this.isDisabled = false,
    this.customTextStyle,
    this.elevation,
    this.iconAlignment = MainAxisAlignment.center,
    this.iconSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? ScreenUtil().screenWidth - 20.w,
      height: height.h,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: splashColor,
          elevation: elevation,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius?.r ?? 10.r),
            side: border != null ? const BorderSide() : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(textColor ?? Colors.white),
                ),
              )
            : _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    // Build content based on whether icons are provided
    if (prefixIcon == null && suffixIcon == null) {
      return Text(
        label,
        style: customTextStyle ??
            TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: fontWeight ?? FontWeight.bold,
              fontSize: fontSize?.sp ?? 16.sp,
            ),
      );
    }

    return Row(
      mainAxisAlignment: iconAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          prefixIcon!,
          SizedBox(width: iconSpacing?.w),
        ],
        Text(
          label,
          style: customTextStyle ??
              TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: fontWeight ?? FontWeight.bold,
                fontSize: fontSize?.sp ?? 16.sp,
              ),
        ),
        if (suffixIcon != null) ...[
          SizedBox(width: iconSpacing?.w),
          suffixIcon!,
        ],
      ],
    );
  }
}
