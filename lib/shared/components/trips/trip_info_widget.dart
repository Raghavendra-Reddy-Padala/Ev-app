import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';

class TripInfoContainer extends StatelessWidget {
  final String startTime;
  final String distance;
  final String runTime;
  final String? date;

  const TripInfoContainer({
    super.key,
    required this.startTime,
    required this.distance,
    required this.runTime,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.accent1,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      child: Column(
        children: [
          if (date != null) ...[
            Text(
              date!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TripMetricColumn(title: "Start time", value: startTime),
              _VerticalDivider(),
              _TripMetricColumn(title: "Distance", value: distance),
              _VerticalDivider(),
              _TripMetricColumn(title: "Run time", value: runTime),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripMetricColumn extends StatelessWidget {
  final String title;
  final String value;

  const _TripMetricColumn({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width: 1.w,
      color: Colors.grey.withOpacity(0.3),
    );
  }
}
