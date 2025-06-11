import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../shared/components/bike/trip_control_panel.dart';
import '../../../../shared/constants/colors.dart';
import '../controller/bike_metrics_controller.dart';
import 'speed_view.dart';
import 'time_view.dart';

class BikeDetailsView extends StatefulWidget {
  const BikeDetailsView({super.key});

  @override
  State<BikeDetailsView> createState() => _BikeDetailsViewState();
}

class _BikeDetailsViewState extends State<BikeDetailsView>
    with WidgetsBindingObserver {
  final LocalStorage _localStorage = Get.find<LocalStorage>();
  final BikeMetricsController _bikeController =
      Get.find<BikeMetricsController>();

  Timer? _uiRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startUIRefreshTimer();

    // Force initial update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bikeController.update();
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uiRefreshTimer?.cancel();
    super.dispose();
  }

  void _startUIRefreshTimer() {
    _uiRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _bikeController.isTracking.value) {
        setState(() {});
        _bikeController.update();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              _BikeHeader(),
              SizedBox(height: 16.h),
              _BikeImage(),
              SizedBox(height: 20.h),
              Expanded(child: _BikeMetrics()),
              SizedBox(height: 16.h),
              const TripControlPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BikeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LocalStorage localStorage = Get.find();

    return GetBuilder<BikeMetricsController>(
      builder: (controller) {
        final cycleId =
            localStorage.getString('deviceId') ?? controller.bikeID.value;
        final isValidCycleId = cycleId != null &&
            cycleId != "null" &&
            cycleId.trim().isNotEmpty &&
            cycleId != "0";

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Bike",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (isValidCycleId) ...[
                    SizedBox(height: 2.h),
                    Text(
                      "ID: $cycleId",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Obx(() {
              if (controller.isTracking.value) {
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "LIVE",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),
          ],
        );
      },
    );
  }
}

class _BikeImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BikeMetricsController>(
      builder: (controller) {
        return Container(
          height: 280.h,
          width: ScreenUtil().screenWidth,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 260.h,
                child: Image.asset('assets/images/bike.png'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BikeMetrics extends StatelessWidget {
  Widget _buildTrackingStatus() {
    return GetBuilder<BikeMetricsController>(
      builder: (controller) {
        return Obx(() {
          if (controller.bikeSubscribed.value && !controller.isTracking.value) {
            // Bike is subscribed but tracking is paused - show resume button
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.pause_circle_outline,
                    color: Colors.orange,
                    size: 32.w,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Trip Paused",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.startTracking();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "Resume Tracking",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BikeMetricsController>(
      builder: (controller) {
        return Column(
          children: [
            // Speed Display - Main metric
            GetBuilder<BikeMetricsController>(
              builder: (controller) {
                return Obx(() {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getSpeedColor(controller.currentSpeed.value)
                              .withOpacity(0.1),
                          _getSpeedColor(controller.currentSpeed.value)
                              .withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: _getSpeedColor(controller.currentSpeed.value)
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildTrackingStatus(),
                        Icon(
                          Icons.speed,
                          color: _getSpeedColor(controller.currentSpeed.value),
                          size: 18.w,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "${controller.currentSpeed.value.toStringAsFixed(1)}",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color:
                                _getSpeedColor(controller.currentSpeed.value),
                          ),
                        ),
                        Text(
                          "km/h",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (controller.isTracking.value &&
                            controller.currentSpeed.value > 0) ...[
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              "MOVING",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                });
              },
            ),

            SizedBox(height: 16.h),

            // Metrics Grid - 2x2
            Row(
              children: [
                Expanded(
                  child: GetBuilder<BikeMetricsController>(
                    builder: (controller) {
                      return Obx(() {
                        return _CompactMetricCard(
                          title: "Time",
                          value:
                              _formatDuration(controller.totalDuration.value),
                          icon: Icons.access_time,
                          iconColor: Colors.blue,
                          onTap: () => Get.to(() => TimeDetailsView(
                                duration: controller.totalDuration.value,
                              )),
                        );
                      });
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GetBuilder<BikeMetricsController>(
                    builder: (controller) {
                      return Obx(() {
                        return _CompactMetricCard(
                          title: "Distance",
                          value:
                              "${controller.totalDistance.value.toStringAsFixed(2)} km",
                          icon: Icons.route,
                          iconColor: Colors.green,
                          onTap: () => Get.to(() => SpeedDetailsView(
                                speed: controller.currentSpeed.value.toInt(),
                              )),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: GetBuilder<BikeMetricsController>(
                    builder: (controller) {
                      return Obx(() {
                        return _CompactBatteryCard(
                          batteryPercentage: controller.batteryPercentage.value,
                        );
                      });
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GetBuilder<BikeMetricsController>(
                    builder: (controller) {
                      return Obx(() {
                        return _CompactMetricCard(
                          title: "Calories",
                          value:
                              "${controller.calculatedCalories.value.toStringAsFixed(0)} kcal",
                          icon: Icons.local_fire_department,
                          iconColor: Colors.orange,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Color _getSpeedColor(double speed) {
    if (speed < 5) return Colors.grey;
    if (speed < 15) return Colors.blue;
    if (speed < 25) return AppColors.primary;
    return Colors.red;
  }

  String _formatDuration(double seconds) {
    final int hours = (seconds ~/ 3600);
    final int minutes = ((seconds % 3600) ~/ 60);
    final int secs = (seconds % 60).toInt();

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}h';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}

class _CompactMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CompactMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
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
                  size: 16.w,
                  color: iconColor,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactBatteryCard extends StatelessWidget {
  final String batteryPercentage;

  const _CompactBatteryCard({
    required this.batteryPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final numericValue = RegExp(r'\d+').stringMatch(batteryPercentage) ?? "0";
    final batteryLevel = int.tryParse(numericValue) ?? 0;

    Color getBatteryColor() {
      if (batteryLevel > 50) return Colors.green;
      if (batteryLevel > 20) return Colors.orange;
      return Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
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
                Icons.battery_full,
                size: 16.w,
                color: getBatteryColor(),
              ),
              SizedBox(width: 4.w),
              Text(
                "Battery",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            batteryPercentage,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
