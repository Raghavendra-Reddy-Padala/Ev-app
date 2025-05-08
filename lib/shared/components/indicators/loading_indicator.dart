import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';

enum LoadingType { circular, linear, lottie }

enum LoadingSize { small, medium, large }

class LoadingIndicator extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final Color? color;
  final String? message;
  final String? lottieAsset;
  final double? value;

  const LoadingIndicator({
    Key? key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.color,
    this.message,
    this.lottieAsset,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(context),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    final indicatorColor = color ?? AppColors.primary;

    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: _getSize(),
          height: _getSize(),
          child: CircularProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: _getStrokeWidth(),
          ),
        );
      case LoadingType.linear:
        return SizedBox(
          width: 200.w,
          child: LinearProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            backgroundColor: indicatorColor.withOpacity(0.2),
            minHeight: _getStrokeWidth() / 2,
          ),
        );
      case LoadingType.lottie:
        return SizedBox(
          width: _getSize() * 1.5,
          height: _getSize() * 1.5,
          child: Lottie.asset(
            lottieAsset ?? 'assets/animations/loading.json',
            fit: BoxFit.contain,
          ),
        );
    }
  }

  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 24.w;
      case LoadingSize.medium:
        return 40.w;
      case LoadingSize.large:
        return 64.w;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2.5;
      case LoadingSize.medium:
        return 3.5;
      case LoadingSize.large:
        return 4.5;
    }
  }
}
