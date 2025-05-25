import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../shared/components/bike/metrics.dart';
import '../../../../shared/components/bike/trip_control_panel.dart';
import '../../../../shared/components/header/header.dart';
import '../../../../shared/constants/colors.dart';
import '../controller/bike_metrics_controller.dart';

class SpeedDetailsView extends StatelessWidget {
  final int speed;

  const SpeedDetailsView({super.key, required this.speed});

  @override
  Widget build(BuildContext context) {
    final BikeMetricsController controller = Get.find();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Header(heading: "Speed Details"),
            _BikeIdHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _CurrentSpeedDisplay(controller: controller),
                    SizedBox(height: 20.h),
                    _SpeedMetricsRow(controller: controller),
                    SizedBox(height: 20.h),
                    Expanded(child: _SpeedChart(controller: controller)),
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

class _CurrentSpeedDisplay extends StatelessWidget {
  final BikeMetricsController controller;

  const _CurrentSpeedDisplay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Text(
            controller.currentSpeed.value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 72.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Text(
            "km/h",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      );
    });
  }
}

class _SpeedMetricsRow extends StatelessWidget {
  final BikeMetricsController controller;

  const _SpeedMetricsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            return MetricInfoCard(
              type: MetricType.distance,
              value: controller.totalDistance.value.toStringAsFixed(2),
              unit: "km",
            );
          }),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Obx(() {
            return MetricInfoCard(
              type: MetricType.speed,
              value: controller.avgSpeed.value.toStringAsFixed(1),
              unit: "km/h",
            );
          }),
        ),
      ],
    );
  }
}

class _SpeedChart extends StatelessWidget {
  final BikeMetricsController controller;

  const _SpeedChart({required this.controller});

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
            "Speed History",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
              if (controller.speedHistoryData.isEmpty ||
                  controller.speedHistoryData
                      .every((element) => element == 0)) {
                return Center(
                  child: Text(
                    "Start your ride to see speed data",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                );
              }

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(controller.speedHistoryData),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (groupIndex >= controller.speedHistoryData.length) {
                          return null;
                        }

                        String formattedTime = '';
                        if (controller.timePoints.length > groupIndex) {
                          formattedTime = DateFormat('h:mm a')
                              .format(controller.timePoints[groupIndex]);
                        }

                        return BarTooltipItem(
                          '${controller.speedHistoryData[groupIndex].toStringAsFixed(1)} km/h\n$formattedTime',
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
                          if (value.toInt() >= controller.timePoints.length) {
                            return const SizedBox();
                          }

                          final date = controller.timePoints[value.toInt()];
                          final time = DateFormat('h:mm').format(date);

                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              time,
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
                          if (value % 5 != 0) return const SizedBox();
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
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 0.5,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateBarGroups(controller.speedHistoryData),
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
    return ((maxValue * 1.2) / 5).ceil() * 5.0;
  }

  List<BarChartGroupData> _generateBarGroups(List<double> data) {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            color: AppColors.primary,
            width: 16.w,
            borderRadius: BorderRadius.circular(8.r),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primary,
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
