import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/misc_models.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme.dart';

class ActivityWidget extends StatelessWidget {
  final Trip? trip;
  final List<LatLng> pathPoints;

  const ActivityWidget(
      {super.key, required this.pathPoints, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ScreenUtil().screenWidth * 0.55,
      decoration: _buildContainerDecoration(),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().screenWidth * 0.02),
        child: Container(
          decoration: _buildInnerContainerDecoration(),
          child: Column(
            children: [
              _buildPathMapSection(),
              SizedBox(height: 5.h),
              _buildMetricsRow(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: EVColors.accent1,
      borderRadius: BorderRadius.circular(ScreenUtil().screenWidth * 0.04),
    );
  }

  BoxDecoration _buildInnerContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(ScreenUtil().screenWidth * 0.02),
    );
  }

  Widget _buildPathMapSection() {
    return SizedBox(
      height: ScreenUtil().screenWidth * 0.35,
      child: PathView(pathPoints: pathPoints),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMetricItem("Time", _formatDuration()),
        _buildMetricItem("Distance", _formatDistance()),
        _buildMetricItem("Calories", _formatCalories()),
        _buildMetricItem("Max Elevation", _formatMaxElevation()),
      ],
    );
  }

  Widget _buildMetricItem(String key, String value) {
    return Column(
      children: [
        Text(
          key,
          style: CustomTextTheme.bodySmallPBold,
        ),
        Text(
          value,
          style: CustomTextTheme.bodyMediumPBold,
        ),
      ],
    );
  }

  String _formatDistance() {
    final distance = (trip?.distance ?? 0.0).toDouble();
    return "${(distance / 1000).toStringAsFixed(1)} Km";
  }

  String _formatDuration() {
    final duration = (trip?.duration ?? 0.0).toDouble();
    int hours = duration.floor();
    int minutes = ((duration - hours) * 60).round();
    if (hours > 0) {
      return "$hours Hrs $minutes Min";
    } else {
      return "$minutes Min";
    }
  }

  String _formatCalories() {
    final calories = (trip?.kcal ?? 0.0).toDouble();
    return "${calories.round()} Kcal";
  }

  String _formatMaxElevation() {
    final elevation = (trip?.maxElevation ?? 0.0).toDouble();
    return "${elevation.round()} Elv";
  }
}
