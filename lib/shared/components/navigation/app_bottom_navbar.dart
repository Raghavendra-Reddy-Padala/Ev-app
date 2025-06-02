import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color primaryColor;
  final List<IconData> navIcons;
  final Duration animationDuration;
  final Curve animationCurve;
  final double itemSize;
  final double verticalPadding;
  final double navHeight;

  const Navbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.primaryColor,
    this.navIcons = const [
      Icons.home_outlined,
      Icons.directions_bike_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.people_alt_outlined,
            Icons.person_outline,

    ],
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.itemSize = 40,
    this.verticalPadding = 5,
    this.navHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    // Get the bottom padding to account for system navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      width: double.infinity,
      height: navHeight.w + bottomPadding,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(
          top: verticalPadding.w,
          bottom: verticalPadding.w + bottomPadding, // Add system nav bar height
          left: 0,
          right: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            navIcons.length,
            (index) => _NavItem(
              icon: navIcons[index],
              index: index,
              isSelected: currentIndex == index,
              primaryColor: primaryColor,
              onTap: onTap,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
              itemSize: itemSize.w,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool isSelected;
  final Color primaryColor;
  final ValueChanged<int> onTap;
  final Duration animationDuration;
  final Curve animationCurve;
  final double itemSize;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
    required this.animationDuration,
    required this.animationCurve,
    required this.itemSize,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: AnimatedContainer(
          duration: animationDuration,
          curve: animationCurve,
          width: itemSize,
          height: itemSize,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : unselectedColor,
            size: itemSize * 0.6,
          ),
        ),
      ),
    );
  }
}