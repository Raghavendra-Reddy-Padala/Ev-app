import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../buttons/app_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool automaticallyImplyLeading;
  final double? elevation;
  final double? titleSpacing;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
    this.elevation,
    this.titleSpacing,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: foregroundColor ??
              (Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white),
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
      leading: _buildLeading(context),
      backgroundColor: backgroundColor ??
          (Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.grey.shade900),
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading && showBackButton,
      elevation: elevation ?? 0.5,
      titleSpacing: titleSpacing,
      foregroundColor: foregroundColor ??
          (Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton &&
        (Navigator.of(context).canPop() || onBackPressed != null)) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.w,
          color: foregroundColor ??
              (Theme.of(context).brightness == Brightness.light
                  ? AppColors.primary
                  : Colors.white),
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    return null;
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
