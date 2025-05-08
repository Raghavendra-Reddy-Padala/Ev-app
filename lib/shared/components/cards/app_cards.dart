import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CardElevation { none, low, medium, high }

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final CardElevation elevation;
  final Border? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AppCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius,
    this.elevation = CardElevation.low,
    this.border,
    this.onTap,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.grey.shade800),
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        border: border,
        boxShadow: _getElevation(context),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        child: cardContent,
      );
    }

    return cardContent;
  }

  List<BoxShadow> _getElevation(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    switch (elevation) {
      case CardElevation.none:
        return [];
      case CardElevation.low:
        return [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case CardElevation.medium:
        return [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      case CardElevation.high:
        return [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ];
    }
  }
}
