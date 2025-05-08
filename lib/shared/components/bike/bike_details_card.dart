import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';

class BikeDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isBattery;
  final String? batteryPercentage;

  const BikeDetailCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.isBattery = false,
    this.batteryPercentage,
  });

  @override
  Widget build(BuildContext context) {
    if (isBattery && batteryPercentage != null) {
      return _buildBatteryCard();
    }

    return _buildInfoCard();
  }

  Widget _buildInfoCard() {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: iconColor?.withOpacity(0.1) ??
                  AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28.w,
                color: iconColor ?? AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildBatteryCard() {
    final double batteryValue = _parseBatteryPercentage(batteryPercentage!);

    return AppCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: _getBatteryColor(batteryValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    _getBatteryIcon(batteryValue),
                    size: 28.w,
                    color: _getBatteryColor(batteryValue),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      batteryPercentage!,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          LinearPercentIndicator(
            lineHeight: 12.h,
            percent: batteryValue,
            barRadius: Radius.circular(10.r),
            backgroundColor: Colors.grey.shade200,
            progressColor: _getBatteryColor(batteryValue),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1000,
          ),
        ],
      ),
    );
  }

  double _parseBatteryPercentage(String percentage) {
    try {
      final String numericValue = percentage.replaceAll('%', '').trim();
      final double value = double.parse(numericValue) / 100;
      return value.clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  Color _getBatteryColor(double value) {
    if (value > 0.7) return Colors.green;
    if (value > 0.3) return Colors.orange;
    return Colors.red;
  }

  IconData _getBatteryIcon(double value) {
    if (value > 0.8) return Icons.battery_full;
    if (value > 0.6) return Icons.battery_6_bar;
    if (value > 0.4) return Icons.battery_4_bar;
    if (value > 0.2) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }
}
