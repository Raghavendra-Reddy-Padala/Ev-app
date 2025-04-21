import 'package:flutter/material.dart';

class TripSummaryContainer extends StatelessWidget {
  final String startTime;
  final String distance;
  final String runTime;

  const TripSummaryContainer({
    super.key,
    required this.startTime,
    required this.distance,
    required this.runTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight * 0.1,
      decoration: _buildContainerDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMetricColumn("Start time", startTime),
          _buildMetricColumn("Distance", distance),
          _buildMetricColumn("Run time", runTime),
        ],
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
      color: EVColors.accent1,
      borderRadius: BorderRadius.circular(10.h),
    );
  }

  Widget _buildMetricColumn(String title, String value) {
    return MetricColumn(title: title, value: value);
  }
}

class MetricColumn extends StatelessWidget {
  final String title;
  final String value;

  const MetricColumn({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: CustomTextTheme.bodySmallI.copyWith(color: Colors.grey),
        ),
        SizedBox(height: ScreenUtil().screenWidth * 0.01),
        Text(
          value,
          style: CustomTextTheme.bodyMediumPBold.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
