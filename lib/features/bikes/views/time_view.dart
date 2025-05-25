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

class TimeDetailsView extends StatelessWidget {
  final double duration;

  const TimeDetailsView({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    final BikeMetricsController controller = Get.find();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Header(heading: "Time Details"),
            _BikeIdHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _DurationDisplay(controller: controller),
                    SizedBox(height: 20.h),
                    _TimeMetricsRow(controller: controller),
                    SizedBox(height: 20.h),
                    Expanded(child: _CaloriesChart(controller: controller)),
                    SizedBox(height: 20.h),
                    const TripControlPanel(),
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
    final cycleId = localStorage.getString('deviceId');

    return Padding(
      padding: EdgeInsets.only(left: 20.w, bottom: 10.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Cycle ID: ${cycleId ?? 'Unknown'}",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _DurationDisplay extends StatelessWidget {
  final BikeMetricsController controller;

  const _DurationDisplay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Text(
        _formatDuration(controller.totalDuration.value),
        style: TextStyle(
          fontSize: 48.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      );
    });
  }

  String _formatDuration(double seconds) {
    final int hours = (seconds ~/ 3600);
    final int minutes = ((seconds % 3600) ~/ 60);
    final int secs = (seconds % 60).toInt();

    if (hours > 0) {
      return '$hours hr ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}

class _TimeMetricsRow extends StatelessWidget {
  final BikeMetricsController controller;

  const _TimeMetricsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            return MetricInfoCard(
              type: MetricType.calories,
              value: controller.calculatedCalories.value.toInt().toString(),
              unit: "kcal",
            );
          }),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Obx(() {
            return MetricInfoCard(
              type: MetricType.elevation,
              value: controller.maxElevation.value.toInt().toString(),
              unit: "m",
            );
          }),
        ),
      ],
    );
  }
}

class _CaloriesChart extends StatelessWidget {
  final BikeMetricsController controller;

  const _CaloriesChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Calories History",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
              if (controller.calorieHistoryData.isEmpty ||
                  controller.calorieHistoryData
                      .every((element) => element == 0)) {
                return Center(
                  child: Text(
                    "Start your ride to see calorie data",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                );
              }

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(controller.calorieHistoryData),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (groupIndex >=
                            controller.calorieHistoryData.length) {
                          return null;
                        }

                        final calories = controller
                            .calorieHistoryData[groupIndex]
                            .toStringAsFixed(1);
                        final timeLabel = _formatTimeLabel(
                            _getCurrentHourMinus(6 - groupIndex));

                        return BarTooltipItem(
                          '$calories cal\n$timeLabel',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        },
                        reservedSize: 28,
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
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 0.5,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateBarGroups(controller.calorieHistoryData),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY(List<double> data) {
    if (data.isEmpty) return 10.0;

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    return ((maxValue * 1.2) / 10).ceil() * 10.0;
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
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: validData[index],
            color: Colors.orange,
            width: 16.w,
            borderRadius: BorderRadius.circular(8.r),
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.3),
                Colors.orange,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });
  }
}
