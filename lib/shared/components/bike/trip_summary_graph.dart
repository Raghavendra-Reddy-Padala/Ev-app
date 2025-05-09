import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/constants/colors.dart';

class TripSummaryGraph extends StatelessWidget {
  final DateTimeRange selectedDateRange;
  final Future<void> Function(BuildContext context) pickDateRange;

  const TripSummaryGraph({
    super.key,
    required this.selectedDateRange,
    required this.pickDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final ActivityController activityController =
        Get.find<ActivityController>();

    return Column(
      children: [
        _buildGraphCard(context, activityController),
        SizedBox(height: 5.h),
      ],
    );
  }

  String _getFormattedDateRange() {
    final DateFormat formatter = DateFormat('d MMM');
    final String start = formatter.format(selectedDateRange.start);
    final String end = formatter.format(selectedDateRange.end);
    return '$start - $end';
  }

  Widget _buildGraphCard(
      BuildContext context, ActivityController activityController) {
    return Card(
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.accent1,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(context),
              _buildDistanceHeader(activityController),
              SizedBox(height: 10.h),
              _buildGraphContent(activityController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleDateSelectorTap(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.bar_chart,
              color: Colors.black,
            ),
            Text(
              _getFormattedDateRange(),
              style: TextStyle(color: Colors.black54),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDateSelectorTap(BuildContext context) async {
    try {
      await pickDateRange(context);
      Get.find<ActivityController>().setDateRange(selectedDateRange);
    } catch (e) {
      debugPrint('Error picking date range: $e');
    }
  }

  Widget _buildDistanceHeader(ActivityController activityController) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Distance Travelled",
            style: TextStyle(color: Colors.black),
          ),
          Obx(() => _buildDistanceValue(activityController)),
        ],
      ),
    );
  }

  Widget _buildDistanceValue(ActivityController activityController) {
    if (activityController.isLoading.value) {
      return const CircularProgressIndicator();
    }

    final double totalDistance = _calculateTotalDistance(activityController);

    return Text(
      "${totalDistance.toStringAsFixed(2)} Km",
      style: CustomTextTheme.bodySmallPBold.copyWith(color: Colors.black),
    );
  }

  double _calculateTotalDistance(ActivityController controller) {
    if (controller.tripSummary.value == null) {
      return controller.totalDistance ?? _generateRandomTotal();
    } else {
      return controller.data.values.fold(0.0, (sum, value) => sum + value);
    }
  }

  double _generateRandomTotal() {
    final Map<int, double> randomData = {};
    final random = Random();
    for (int i = 0; i < 7; i++) {
      randomData[i] = 1.0 + random.nextDouble() * 9.0;
    }
    return randomData.values.fold(0.0, (sum, value) => sum + value);
  }

  Widget _buildGraphContent(ActivityController activityController) {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: 200.w,
      child: Obx(() {
        if (activityController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (activityController.tripSummary.value == null) {
          return _buildRandomGraph();
        } else {
          return GraphView(
            data: activityController.data,
            xLabels: activityController.xLabels,
            showYAxisLabels: true,
            showHorizontalLines: true,
            showLogo: false,
          );
        }
      }),
    );
  }

  Widget _buildRandomGraph() {
    // Generate random data for demonstration
    final Map<int, double> randomData = {};
    final Map<int, String> xLabels = {};

    final int days =
        selectedDateRange.end.difference(selectedDateRange.start).inDays + 1;
    final int daysToShow = days > 7 ? 7 : days;

    final random = Random();
    for (int i = 0; i < daysToShow; i++) {
      final date = selectedDateRange.start.add(Duration(days: i));
      final String dayLabel = DateFormat('dd/MM').format(date);
      xLabels[i] = dayLabel;
      randomData[i] = 1.0 + random.nextDouble() * 9.0;
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 5.h),
        ),
        Expanded(
          child: GraphView(
            data: randomData,
            xLabels: xLabels,
            showYAxisLabels: true,
            showHorizontalLines: true,
            showLogo: false,
          ),
        ),
      ],
    );
  }
}
