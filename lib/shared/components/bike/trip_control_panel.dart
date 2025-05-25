import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../features/bikes/controller/trips_control_service.dart';
import '../buttons/app_button.dart';
import 'ride_summary.dart';

class TripControlPanel extends StatelessWidget {
  const TripControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final TripControlService tripControlService = Get.find();

    return Obx(() {
      if (tripControlService.isEndTripSliderVisible.value) {
        return _EndTripSlider();
      } else {
        return _TripControlButtons();
      }
    });
  }
}

class _TripControlButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RxBool isTrackingPaused = false.obs;
    final TripControlService tripControlService = Get.find();

    return Row(
      children: [
        Expanded(
          child: Obx(() {
            return AppButton(
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
            );
          }),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: AppButton(
            text: "End Trip",
            icon: Icons.stop_circle_outlined,
            type: ButtonType.danger,
            onPressed: () => tripControlService.showEndTripSlider(),
          ),
        ),
      ],
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

class _EndTripSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TripControlService tripControlService = Get.find();

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              "Slide to End Trip",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 4.w,
            top: 4.h,
            bottom: 4.h,
            child: GestureDetector(
              onPanUpdate: (details) =>
                  _handleSlide(details, tripControlService),
              child: Container(
                width: 52.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26.r),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red,
                  size: 24.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSlide(DragUpdateDetails details, TripControlService service) {
    if (details.delta.dx > 5) {
      _endTrip(service);
    }
  }

  Future<void> _endTrip(TripControlService service) async {
    try {
      final success = await service.endTrip();

      if (success) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 3,
            channelKey: 'ride_channel',
            title: 'Trip Ended',
            body: 'Your trip has successfully ended. Thanks for riding!',
            notificationLayout: NotificationLayout.Default,
          ),
        );

        NavigationService.pushTo(RideSummary());
      }
    } catch (e) {
      print('Error ending trip: $e');
    }
  }
}
