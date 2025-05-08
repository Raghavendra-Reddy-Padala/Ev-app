import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';

enum MetricType { speed, time, distance, calories, elevation }

class MetricInfoCard extends StatelessWidget {
  final MetricType type;
  final String value;
  final String? unit;

  const MetricInfoCard({
    super.key,
    required this.type,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: _getFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: 4.w),
                Text(
                  unit!,
                  style: TextStyle(
                    fontSize: _getUnitFontSize(),
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            _getLabel(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  double _getFontSize() {
    switch (type) {
      case MetricType.speed:
        return 34.sp;
      case MetricType.time:
      case MetricType.distance:
        return 28.sp;
      case MetricType.calories:
      case MetricType.elevation:
        return 24.sp;
    }
  }

  double _getUnitFontSize() {
    return _getFontSize() * 0.6;
  }

  String _getLabel() {
    switch (type) {
      case MetricType.speed:
        return 'Speed';
      case MetricType.time:
        return 'Time';
      case MetricType.distance:
        return 'Distance';
      case MetricType.calories:
        return 'Calories';
      case MetricType.elevation:
        return 'Elevation';
    }
  }
}
