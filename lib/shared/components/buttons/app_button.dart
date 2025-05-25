import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';

enum ButtonType { primary, secondary, outline, text, error, danger }

enum ButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final IconData? icon; // Added icon parameter
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
    this.prefixIcon,
    this.suffixIcon,
    this.icon, // Added icon parameter
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? (fullWidth ? double.infinity : null),
      height: height ?? _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 24.h,
        width: 24.h,
        child: CircularProgressIndicator(
          color: _getLoadingColor(),
          strokeWidth: 2.5,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Handle icon parameter (takes precedence over prefixIcon)
        if (icon != null) ...[
          Icon(
            icon,
            size: _getIconSize(),
            color: _getTextColor(),
          ),
          SizedBox(width: 8.w),
        ] else if (prefixIcon != null) ...[
          prefixIcon!,
          SizedBox(width: 8.w),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: _getTextSize(),
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
        if (suffixIcon != null) ...[
          SizedBox(width: 8.w),
          suffixIcon!,
        ],
      ],
    );
  }

  ButtonStyle _getButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return type == ButtonType.outline
              ? Colors.transparent
              : AppColors.disabled;
        }
        return _getBackgroundColor();
      }),
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return type == ButtonType.outline
              ? AppColors.disabled
              : AppColors.white;
        }
        return _getTextColor();
      }),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(10.r),
          side: _getBorderSide(),
        ),
      ),
      elevation: MaterialStateProperty.all(type == ButtonType.text ? 0 : 1),
      padding: MaterialStateProperty.all<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 16.w),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.error:
      case ButtonType.danger: // Added danger case
        return AppColors.error;
      case ButtonType.outline:
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.error:
      case ButtonType.danger: // Added danger case
        return Colors.white;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.text:
        return AppColors.primary;
    }
  }

  Color _getLoadingColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.error:
      case ButtonType.danger: // Added danger case
        return Colors.white;
      case ButtonType.outline:
      case ButtonType.text:
        return AppColors.primary;
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36.h;
      case ButtonSize.medium:
        return 48.h;
      case ButtonSize.large:
        return 56.h;
    }
  }

  double _getTextSize() {
    switch (size) {
      case ButtonSize.small:
        return 12.sp;
      case ButtonSize.medium:
        return 14.sp;
      case ButtonSize.large:
        return 16.sp;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.w;
      case ButtonSize.medium:
        return 20.w;
      case ButtonSize.large:
        return 24.w;
    }
  }

  BorderSide _getBorderSide() {
    if (type == ButtonType.outline) {
      return BorderSide(
        color: onPressed == null ? AppColors.disabled : AppColors.primary,
        width: 1.5,
      );
    }
    return BorderSide.none;
  }
}
