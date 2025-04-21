import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Arrow extends StatelessWidget {
  final bool left;

  const Arrow({super.key, required this.left});

  @override
  Widget build(BuildContext context) {
    return Icon(
      left ? Icons.arrow_circle_left : Icons.arrow_circle_right,
      size: left ? 30.w : 40.w,
      color: left ? EVColors.primary : Colors.white,
    );
  }
}

class NotFoundWidget extends StatelessWidget {
  final String message;
  final String imagePath;
  final double imageSize;

  const NotFoundWidget({
    super.key,
    this.message = 'No data found!',
    this.imagePath = 'assets/images/no-data.png',
    this.imageSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: imageSize.w,
            height: imageSize.h,
            child: Image.asset(imagePath),
          ),
          Text(
            message,
            style: CustomTextTheme.bodySmallPBold.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

Widget notFound() {
  return const NotFoundWidget();
}

class LoaderWidget extends StatelessWidget {
  final RxBool isLoading;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const LoaderWidget({
    super.key,
    required this.isLoading,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return _buildLoader();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildLoader() {
    return Center(
      child: Container(
        width: 90.w,
        height: 90.h,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.all(20.r),
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(indicatorColor ?? Colors.white),
        ),
      ),
    );
  }
}

// Convenience function for easy loader usage
Widget loader({required RxBool isLoading}) {
  return LoaderWidget(isLoading: isLoading);
}

class Header extends StatelessWidget {
  final String heading;
  final double? size;
  final Color? color;
  final VoidCallback? onBackPressed;

  const Header({
    super.key,
    required this.heading,
    this.size = 40,
    this.color = Colors.white,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBackButton(),
          const SizedBox(width: 5),
          _buildHeadingText(context),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: onBackPressed ?? () => NavigationService.pop(),
      child: Arrow(left: true, color: color, size: size),
    );
  }

  Widget _buildHeadingText(BuildContext context) {
    final Color textColor = Theme.of(context).brightness == Brightness.light
        ? EVColors.titletext
        : Colors.white;

    return Text(
      heading,
      style: CustomTextTheme.headlineSmallPBold.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
