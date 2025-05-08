import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';

enum BadgeType { primary, success, warning, error, info, neutral }

enum BadgeSize { small, medium, large }

class TextBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final BadgeSize size;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Widget? icon;

  const TextBadge({
    Key? key,
    required this.text,
    this.type = BadgeType.primary,
    this.size = BadgeSize.medium,
    this.padding,
    this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget badge = Container(
      padding: padding ?? _getPadding(),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: badge,
      );
    }

    return badge;
  }

  Color _getBackgroundColor() {
    switch (type) {
      case BadgeType.primary:
        return AppColors.primary.withOpacity(0.15);
      case BadgeType.success:
        return AppColors.green.withOpacity(0.15);
      case BadgeType.warning:
        return const Color(0xFFFFA726).withOpacity(0.15);
      case BadgeType.error:
        return AppColors.error.withOpacity(0.15);
      case BadgeType.info:
        return const Color(0xFF2196F3).withOpacity(0.15);
      case BadgeType.neutral:
        return Colors.grey.withOpacity(0.15);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case BadgeType.primary:
        return AppColors.primary;
      case BadgeType.success:
        return AppColors.green;
      case BadgeType.warning:
        return const Color(0xFFE65100);
      case BadgeType.error:
        return AppColors.error;
      case BadgeType.info:
        return const Color(0xFF0D47A1);
      case BadgeType.neutral:
        return Colors.grey.shade800;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case BadgeSize.small:
        return 10.r;
      case BadgeSize.medium:
        return 12.r;
      case BadgeSize.large:
        return 14.r;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case BadgeSize.small:
        return EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h);
      case BadgeSize.medium:
        return EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h);
      case BadgeSize.large:
        return EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h);
    }
  }

  double _getFontSize() {
    switch (size) {
      case BadgeSize.small:
        return 10.sp;
      case BadgeSize.medium:
        return 12.sp;
      case BadgeSize.large:
        return 14.sp;
    }
  }
}
