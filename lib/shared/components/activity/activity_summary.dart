import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';
import '../map/path_view.dart';

class ActivitySummaryCard extends StatelessWidget {
  final List<LatLng> pathPoints;
  final String duration;
  final double distance;
  final int calories;
  final double maxElevation;
  final bool isScreenshotMode;

  const ActivitySummaryCard({
    super.key,
    required this.pathPoints,
    required this.duration,
    required this.distance,
    required this.calories,
    required this.maxElevation,
    this.isScreenshotMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(12.w),
      backgroundColor: AppColors.accent1,
      child: Column(
        children: [
          PathView(
            pathPoints: pathPoints,
            isScreenshotMode: isScreenshotMode,
            height: 180,
          ),
          SizedBox(height: 16.h),
          _buildMetricsRow(),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MetricItem(label: "Time", value: formatDuration()),
        _MetricItem(
            label: "Distance",
            value: "${(distance / 1000).toStringAsFixed(1)} km"),
        _MetricItem(label: "Calories", value: "$calories kcal"),
        _MetricItem(label: "Elevation", value: "${maxElevation.round()} m"),
      ],
    );
  }

  String formatDuration() {
    final int hours = duration.toInt();
    final int minutes = ((duration - hours) * 60).round();

    if (hours > 0) {
      return "$hours h $minutes min";
    } else {
      return "$minutes min";
    }
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
