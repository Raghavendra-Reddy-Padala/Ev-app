import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/bikes/controller/bike_metrics_controller.dart';
import 'package:mjollnir/features/main_page_controller.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../features/bikes/controller/trips_control_service.dart';
import '../buttons/app_button.dart';
import 'ride_summary.dart';

class TripControlPanel extends StatelessWidget {
  const TripControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final TripControlService tripControlService = Get.find();

    return GetBuilder<TripControlService>(
      builder: (controller) {
        return Obx(() {
          if (tripControlService.isEndTripSliderVisible.value) {
            return _EndTripSlider();
          } else {
            return _TripControlButtons();
          }
        });
      },
    );
  }
}

class _TripControlButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RxBool isTrackingPaused = false.obs;
    final TripControlService tripControlService = Get.find();
    final BikeMetricsController bikeController = Get.find();

    return GetBuilder<BikeMetricsController>(
      builder: (controller) {
        return Obx(() {
          return Row(
            children: [
              Expanded(
                child: AppButton(
                  text: isTrackingPaused.value ? "Resume Trip" : "Pause Trip",
                  icon: isTrackingPaused.value ? Icons.play_arrow : Icons.pause,
                  type: isTrackingPaused.value
                      ? ButtonType.secondary
                      : ButtonType.primary,
                  onPressed: () {
                    if (isTrackingPaused.value) {
                      tripControlService.resumeTrip();
                      isTrackingPaused.value = false;
                      _showNotification(
                        'Ride Resumed',
                        'Your ride has been resumed successfully.',
                      );
                    } else {
                      tripControlService.pauseTrip();
                      isTrackingPaused.value = true;
                      _showNotification(
                        'Ride Paused',
                        'Your ride has been paused. You can resume anytime.',
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppButton(
                  text: "End Trip",
                  icon: Icons.stop_circle_outlined,
                  type: ButtonType.danger,
                  onPressed: () {
                    tripControlService.debugTripStatus();
                    tripControlService.showEndTripSlider();
                  },
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _showNotification(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'ride_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}

class _EndTripSlider extends StatefulWidget {
  @override
  _EndTripSliderState createState() => _EndTripSliderState();
}

class _EndTripSliderState extends State<_EndTripSlider>
    with TickerProviderStateMixin {
  double _sliderPosition = 0.0;
  double _containerWidth = 0.0;
  bool _isSliding = false;
  bool _isCompleted = false;
  bool _isEndingTrip = false;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: -10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TripControlService tripControlService = Get.find();

    return LayoutBuilder(
      builder: (context, constraints) {
        _containerWidth = constraints.maxWidth;
        final double maxSlideDistance = _containerWidth - 60.w;

        return AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatingAnimation.value),
              child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: _isCompleted ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: _isCompleted
                          ? Colors.green.withOpacity(0.4)
                          : Colors.red.withOpacity(0.3),
                      blurRadius: _isCompleted ? 15 : 8,
                      spreadRadius: _isCompleted ? 2 : 0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: _isEndingTrip
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "Ending Trip...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _isCompleted
                                    ? "Trip Ending!"
                                    : "Slide to End Trip",
                                key: ValueKey(_isCompleted),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: _isSliding
                          ? Duration.zero
                          : Duration(milliseconds: 200),
                      left: 4.w + _sliderPosition,
                      top: 4.h,
                      bottom: 4.h,
                      child: GestureDetector(
                        onPanStart: (details) {
                          if (!_isCompleted && !_isEndingTrip) {
                            _isSliding = true;
                          }
                        },
                        onPanUpdate: (details) {
                          if (!_isCompleted && !_isEndingTrip) {
                            setState(() {
                              _sliderPosition += details.delta.dx;
                              _sliderPosition =
                                  _sliderPosition.clamp(0.0, maxSlideDistance);
                            });

                            if (_sliderPosition >= maxSlideDistance * 0.85) {
                              _completeSlide(tripControlService);
                            }
                          }
                        },
                        onPanEnd: (details) {
                          _isSliding = false;
                          if (!_isCompleted &&
                              _sliderPosition < maxSlideDistance * 0.85) {
                            setState(() {
                              _sliderPosition = 0.0;
                            });
                          }
                        },
                        child: Container(
                          width: 52.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: _isCompleted ? 8 : 4,
                                spreadRadius: _isCompleted ? 1 : 0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: _isCompleted
                                ? Icon(
                                    Icons.check,
                                    key: ValueKey('check'),
                                    color: Colors.green,
                                    size: 24.w,
                                  )
                                : Icon(
                                    Icons.arrow_forward_ios,
                                    key: ValueKey('arrow'),
                                    color: Colors.red,
                                    size: 24.w,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _completeSlide(TripControlService service) {
    if (_isCompleted) return;

    setState(() {
      _isCompleted = true;
    });

    _floatingController.repeat(reverse: true);

    HapticFeedback.mediumImpact();

    Future.delayed(Duration(milliseconds: 800), () {
      _endTrip(service);
    });
  }

  Future<void> _endTrip(TripControlService service) async {
    setState(() {
      _isEndingTrip = true;
    });

    try {
      final BikeMetricsController bikeMetricsController =
          Get.find<BikeMetricsController>();
      final MainPageController mainPageController =
          Get.find<MainPageController>();

      service.debugTripStatus();
      bikeMetricsController.printTripSummary();

      final success = await service.endTrip();

      if (success) {
        bikeMetricsController.bikeSubscribed.value = false;
        mainPageController.updateSubscriptionStatus(false);

        _floatingController.stop();

        await Future.delayed(Duration(milliseconds: 500));

        try {
          final result = await Get.to(() => RideSummary());

          if (Get.isRegistered<MainPageController>()) {
            final mainController = Get.find<MainPageController>();
            await mainController.refreshSubscriptionStatus();

            if (mainController.selectedIndex.value == 1) {
              mainController.updateSelectedIndex(1);
            }
          }
        } catch (e) {
          Get.offAll(() => RideSummary());
        }
      } else {
        _handleEndTripFailure();
      }
    } catch (e) {
      _handleEndTripFailure();
    }
  }

  void _handleEndTripFailure() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 4,
        channelKey: 'ride_channel',
        title: 'Trip End Failed',
        body: 'Unable to end trip. Please check your connection and try again.',
        notificationLayout: NotificationLayout.Default,
      ),
    );

    setState(() {
      _isCompleted = false;
      _isEndingTrip = false;
      _sliderPosition = 0.0;
    });

    _floatingController.stop();

    Get.dialog(
      AlertDialog(
        title: Text('Trip End Failed'),
        content: Text('Would you like to try ending the trip again?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              final TripControlService tripControlService = Get.find();
              tripControlService.showEndTripSlider();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
