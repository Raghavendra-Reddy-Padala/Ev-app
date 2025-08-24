import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../shared/components/bike/metrics.dart';
import '../../../../shared/components/bike/trip_control_panel.dart';
import '../../../../shared/components/header/header.dart';
import '../../../../shared/constants/colors.dart';
import '../controller/bike_metrics_controller.dart';

class TimeDetailsView extends StatefulWidget {
  final double duration;

  const TimeDetailsView({super.key, required this.duration});

  @override
  State<TimeDetailsView> createState() => _TimeDetailsViewState();
}

class _TimeDetailsViewState extends State<TimeDetailsView> {
  late BikeMetricsController controller;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BikeMetricsController>();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && controller.isTracking.value) {
        setState(() {});
        controller.update(['time_display', 'metrics_row', 'calorie_chart']);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.update();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Column(
          children: [
            const Header(heading: "Time Details"),
            _BikeIdHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: [
                    _DurationDisplay(controller: controller),
                    SizedBox(height: 16.h),
                    _TimeMetricsRow(controller: controller),
                    SizedBox(height: 16.h),
                    _CaloriesChart(controller: controller),
                    SizedBox(height: 16.h),
                    const TripControlPanel(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BikeIdHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LocalStorage localStorage = Get.find();

    return GetBuilder<BikeMetricsController>(
      builder: (controller) {
        final cycleId =
            localStorage.getString('deviceId') ?? controller.bikeID.value;
        final isValidCycleId =
            cycleId.isNotEmpty && cycleId != "null" && cycleId != "0";

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_bike,
                size: 14.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                "ID: ${isValidCycleId ? cycleId : 'Demo'}",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DurationDisplay extends StatelessWidget {
  final BikeMetricsController controller;

  const _DurationDisplay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BikeMetricsController>(
      id: 'time_display',
      builder: (controller) {
        return Obx(() {
          final duration = controller.totalDuration.value;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "TRIP DURATION",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF1E293B),
                    height: 1.0,
                  ),
                ),
                if (controller.isTracking.value) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "ACTIVE",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        });
      },
    );
  }

  String _formatDuration(double seconds) {
    final int hours = (seconds ~/ 3600);
    final int minutes = ((seconds % 3600) ~/ 60);
    final int secs = (seconds % 60).toInt();

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '${minutes}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '0:${secs.toString().padLeft(2, '0')}';
    }
  }
}

class _TimeMetricsRow extends StatelessWidget {
  final BikeMetricsController controller;

  const _TimeMetricsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BikeMetricsController>(
      id: 'metrics_row',
      builder: (controller) {
        return Obx(() {
          return Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: "CALORIES",
                  value: controller.calculatedCalories.value.toInt().toString(),
                  unit: "kcal",
                  icon: Icons.local_fire_department_outlined,
                  color: const Color(0xFFEF4444),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _MetricCard(
                  title: "ELEVATION",
                  value: controller.maxElevation.value.toInt().toString(),
                  unit: "m",
                  icon: Icons.terrain_outlined,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: color,
              ),
              SizedBox(width: 4.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1E293B),
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: " $unit",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaloriesChart extends StatelessWidget {
  final BikeMetricsController controller;

  const _CaloriesChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Calories History",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              GetBuilder<BikeMetricsController>(
                builder: (controller) {
                  return Obx(() {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "${controller.calculatedCalories.value.toStringAsFixed(1)} kcal",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: GetBuilder<BikeMetricsController>(
              id: 'calorie_chart',
              builder: (controller) {
                return Obx(() {
                  if (controller.calorieHistoryData.isEmpty) {
                    return _buildEmptyState("No data available");
                  }

                  if (controller.calorieHistoryData.every((element) => element == 0)) {
                    return _buildEmptyState("Start your ride to see data");
                  }

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _calculateMaxY(controller.calorieHistoryData),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (groupIndex >= controller.calorieHistoryData.length) {
                              return null;
                            }

                            final calories = controller.calorieHistoryData[groupIndex].toStringAsFixed(1);
                            final timeLabel = _formatTimeLabel(_getCurrentHourMinus(6 - groupIndex));

                            return BarTooltipItem(
                              '$calories cal\n$timeLabel',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 11.sp,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final hour = _getCurrentHourMinus(6 - value.toInt());
                              return Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  _formatTimeLabel(hour),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              );
                            },
                            reservedSize: 24.h,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value % 10 != 0) return const SizedBox();
                              return Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                            reservedSize: 24.w,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 0.5,
                        ),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _generateBarGroups(controller.calorieHistoryData),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 32.w,
            color: Colors.grey[300],
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _calculateMaxY(List<double> data) {
    if (data.isEmpty) return 10.0;
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final calculatedMax = ((maxValue * 1.2) / 10).ceil() * 10.0;
    return calculatedMax < 10 ? 10.0 : calculatedMax;
  }

  String _formatTimeLabel(int hour) {
    final amPm = hour < 12 ? 'am' : 'pm';
    final displayHour = hour == 0 ? 12 : (hour <= 12 ? hour : hour - 12);
    return '$displayHour$amPm';
  }

  int _getCurrentHourMinus(int hoursToSubtract) {
    final now = DateTime.now();
    return (now.hour - hoursToSubtract) % 24;
  }

  List<BarChartGroupData> _generateBarGroups(List<double> data) {
    final validData = data.length >= 7
        ? data.sublist(0, 7)
        : [...data, ...List.filled(7 - data.length, 0.0)];

    return List.generate(validData.length, (index) {
      final value = validData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: _getBarColor(value),
            width: 12.w,
            borderRadius: BorderRadius.circular(3.r),
            gradient: LinearGradient(
              colors: [
                _getBarColor(value).withOpacity(0.6),
                _getBarColor(value),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });
  }

  Color _getBarColor(double calories) {
    if (calories < 10) return Colors.grey.shade300;
    if (calories < 30) return const Color(0xFFF59E0B);
    if (calories < 50) return const Color(0xFFEF4444);
    return const Color(0xFFDC2626);
  }
}