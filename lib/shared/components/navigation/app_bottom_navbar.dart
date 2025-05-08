import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  NavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

class AppBottomNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final double height;
  final bool showLabels;

  const AppBottomNavBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.height = 80,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.grey.shade900);

    final selectedColor = selectedItemColor ?? AppColors.primary;
    final unselectedColor = unselectedItemColor ??
        (Theme.of(context).brightness == Brightness.light
            ? Colors.grey.shade700
            : Colors.grey.shade400);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation! * 3,
                  offset: Offset(0, -elevation!),
                ),
              ]
            : null,
      ),
      height: height.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final bool isSelected = currentIndex == index;
          return _NavBarItem(
            label: showLabels ? items[index].label : null,
            icon: isSelected && items[index].activeIcon != null
                ? items[index].activeIcon!
                : items[index].icon,
            isSelected: isSelected,
            onTap: () => onTap(index),
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          );
        }),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String? label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _NavBarItem({
    Key? key,
    this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
              isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24.w,
            ),
            if (label != null) ...[
              SizedBox(height: 4.h),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
