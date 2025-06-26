import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../shared/components/bike/metrics.dart';
import '../../../../shared/components/header/header.dart';
import '../../../../shared/constants/colors.dart';
import '../controller/bike_metrics_controller.dart';

class SpeedDetailsView extends StatefulWidget {
  final int speed;

  const SpeedDetailsView({super.key, required this.speed});

  @override
  State<SpeedDetailsView> createState() => _SpeedDetailsViewState();
}

class _SpeedDetailsViewState extends State<SpeedDetailsView> {
  late BikeMetricsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BikeMetricsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.update();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Column(
          children: [
            const Header(heading: "Speed Details"),
            _BikeIdHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: [
                    _CurrentSpeedDisplay(controller: controller),
                    SizedBox(height: 16.h),
                    _SpeedMetricsRow(controller: controller),
                    SizedBox(height: 16.h),
                    _SpeedChart(controller: controller),
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
                Icons.speed,
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

class _CurrentSpeedDisplay extends StatelessWidget {
  final BikeMetricsController controller;

  const _CurrentSpeedDisplay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BikeMetricsController>(
      builder: (controller) {
        return Obx(() {
          final speed = controller.currentSpeed.value;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200, width: 0.5),
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
                  "CURRENT SPEED",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 8.h),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: speed.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w300,
                          color: _getSpeedColor(speed),
                          height: 1.0,
                        ),
                      ),
                      TextSpan(
                        text: " km/h",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.isTracking.value) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: speed > 0
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: speed > 0
                            ? const Color(0xFF10B981).withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: speed > 0
                                ? const Color(0xFF10B981)
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          speed > 0 ? "MOVING" : "STATIONARY",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: speed > 0
                                ? const Color(0xFF10B981)
                                : Colors.grey,
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

  Color _getSpeedColor(double speed) {
    if (speed < 5) return Colors.green[400]!;
    if (speed < 15) return const Color(0xFF3B82F6);
    if (speed < 25) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class _SpeedMetricsRow extends StatelessWidget {
  final BikeMetricsController controller;

  const _SpeedMetricsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BikeMetricsController>(
      builder: (controller) {
        return Obx(() {
          return Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: "DISTANCE",
                  value: controller.totalDistance.value.toStringAsFixed(2),
                  unit: "km",
                  icon: Icons.straighten,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _MetricCard(
                  title: "AVG SPEED",
                  value: controller.avgSpeed.value.toStringAsFixed(1),
                  unit: "km/h",
                  icon: Icons.speed,
                  color: const Color(0xFF10B981),
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

class _SpeedChart extends StatelessWidget {
  final BikeMetricsController controller;

  const _SpeedChart({required this.controller});

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
                "Speed History",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Obx(() {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "${controller.currentSpeed.value.toStringAsFixed(1)} km/h",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
             
              if (controller.speedHistoryData.isEmpty) {
                return _buildEmptyState("No data available");
              }

              if (controller.speedHistoryData
                  .every((element) => element == 0)) {
                return _buildEmptyState("Start your ride to see data");
              }

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(controller.speedHistoryData),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 6.r,
                      tooltipPadding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (groupIndex >= controller.speedHistoryData.length) {
                          return null;
                        }

                        final speed = controller.speedHistoryData[groupIndex]
                            .toStringAsFixed(1);
                        final timeLabel = _formatTimeLabel(
                            _getCurrentHourMinus(6 - groupIndex));

                        return BarTooltipItem(
                          '$speed km/h\n$timeLabel',
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
                          if (value % 5 != 0) return const SizedBox();
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
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.speed,
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
    final calculatedMax = ((maxValue * 1.2) / 5).ceil() * 5.0;
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

  Color _getBarColor(double speed) {
    if (speed < 5) return Colors.grey.shade300;
    if (speed < 15) return const Color(0xFF3B82F6);
    if (speed < 25) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
