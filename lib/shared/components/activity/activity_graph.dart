import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mjollnir/shared/components/map/graph_view.dart';
import 'package:mjollnir/shared/constants/colors.dart';

import '../../../features/account/controllers/profile_controller.dart';
import '../../models/activity/activity_data_model.dart';
import '../../models/trips/trips_model.dart';

class ActivityGraphWidget extends StatelessWidget {
  final TripSummaryModel? tripSummary;
  final Function(DateTimeRange)? onDateRangeChanged;

  const ActivityGraphWidget({
    super.key,
    this.tripSummary,
    this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Container(
        decoration: BoxDecoration(
          color: AppColors.accent1,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(controller),
              SizedBox(height: 16.h),
              _buildMetricSelector(controller),
              SizedBox(height: 16.h),
              _buildStatsRow(controller),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: _buildGraph(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ProfileController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Activity Overview',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: () => _showDateRangePicker(controller),
          child: Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.date_range,
                      color: AppColors.primary,
                      size: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDateRange(controller.selectedDateRange.value),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                      size: 16.w,
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  Widget _buildMetricSelector(ProfileController controller) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.availableMetrics.map((metric) {
              final isSelected = controller.selectedMetric.value == metric;
              return GestureDetector(
                onTap: () => controller.onMetricChanged(metric),
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    _getMetricDisplayName(metric),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildStatsRow(ProfileController controller) {
    return Obx(() {
      final graphData = controller.activityGraphData.value;
      final summary = tripSummary;

      if (graphData != null) {
        return _buildStatsFromGraphData(graphData);
      } else if (summary != null) {
        return _buildStatsFromSummary(summary);
      } else {
        return _buildPlaceholderStats();
      }
    });
  }

  Widget _buildStatsFromGraphData(ActivityGraphData graphData) {
    final metric = graphData.metric;
    final totalValue = graphData.totalValue;
    final unit = graphData.unit;

    final avgValue = graphData.data.isNotEmpty
        ? totalValue / graphData.data.length
        : 0.0;
    final peakValue = graphData.data.isNotEmpty
        ? graphData.data.values.reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          _getMetricDisplayName(metric),
          '${totalValue.toStringAsFixed(metric == 'trips' ? 0 : 1)} $unit',
        ),
        _buildStatItem(
          'Average',
          '${avgValue.toStringAsFixed(1)} $unit',
        ),
        _buildStatItem(
          'Peak',
          '${peakValue.toStringAsFixed(1)} $unit',
        ),
      ],
    );
  }

  Widget _buildStatsFromSummary(TripSummaryModel summary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Total Trips', '${summary.totalTrips}'),
        _buildStatItem('Calories', '${summary.totalCalories}'),
        _buildStatItem(
            'Best Speed', '${summary.highestSpeed.toStringAsFixed(1)} km/h'),
      ],
    );
  }

  Widget _buildPlaceholderStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Total', '0'),
        _buildStatItem('Average', '0'),
        _buildStatItem('Peak', '0'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGraph(ProfileController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final graphData = controller.activityGraphData.value;

      if (graphData == null) {
        return _buildEmptyGraph();
      }

      return GraphView(
        data: graphData.data,
        xLabels: graphData.xLabels,
        showYAxisLabels: false,
        showHorizontalLines: true,
        showLogo: false,
        useParentColor: false,
      );
    });
  }

  Widget _buildEmptyGraph() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8.h),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(ProfileController controller) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: controller.selectedDateRange.value,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
            ).copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != controller.selectedDateRange.value) {
      controller.onDateRangeChanged(picked);
      if (onDateRangeChanged != null) {
        onDateRangeChanged!(picked);
      }
    }
  }

  String _formatDateRange(DateTimeRange range) {
    final formatter = DateFormat('MMM d');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  String _getMetricDisplayName(String metric) {
    switch (metric) {
      case 'distance':
        return 'Distance';
      case 'time':
        return 'Time';
      case 'calories':
        return 'Calories';
      case 'trips':
        return 'Trips';
      default:
        return metric.capitalize ?? metric;
    }
  }
}
