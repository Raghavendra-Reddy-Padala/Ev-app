import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../buttons/app_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final String? assetImage;
  final double? imageSize;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final EdgeInsets padding;

  const EmptyState({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.assetImage,
    this.imageSize,
    this.buttonText,
    this.onButtonPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildImage(),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black87
                  : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (buttonText != null && onButtonPressed != null) ...[
            SizedBox(height: 24.h),
            AppButton(
              text: buttonText!,
              onPressed: onButtonPressed,
              type: ButtonType.primary,
              size: ButtonSize.medium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage() {
    final double size = imageSize ?? 120.w;

    if (icon != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      );
    } else if (assetImage != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetImage!,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.search_off_rounded,
          size: size * 0.5,
          color: Colors.grey,
        ),
      );
    }
  }
}
