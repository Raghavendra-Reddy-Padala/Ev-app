import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:slider_button/slider_button.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/logger.dart';
import '../../../features/account/controllers/trips_controller.dart';
import '../../../features/bikes/controller/bike_metrics_controller.dart';
import '../../../features/main_page_controller.dart';
import '../../constants/colors.dart';
import '../../models/trips/trips_model.dart';
import 'ride_summary.dart';

class TripControlPanel extends StatelessWidget {
  final RxBool isEndTripSliderVisible;
  final VoidCallback onShowEndTripSlider;
  final VoidCallback onHideEndTripSlider;

  const TripControlPanel({
    super.key,
    required this.isEndTripSliderVisible,
    required this.onShowEndTripSlider,
    required this.onHideEndTripSlider,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isEndTripSliderVisible.value) {
        return _EndTripSlider(onHideSlider: onHideEndTripSlider);
      } else {
        return _TripControlButtons(onShowEndTripSlider: onShowEndTripSlider);
      }
    });
  }
}

class _TripControlButtons extends StatelessWidget {
  final VoidCallback onShowEndTripSlider;

  const _TripControlButtons({
    required this.onShowEndTripSlider,
  });

  @override
  Widget build(BuildContext context) {
    final RxBool isTrackingPaused = false.obs;
    final BikeMetricsController bikeManager = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Obx(() {
            return ElevatedButton.icon(
              onPressed: () {
                if (isTrackingPaused.value) {
                  bikeManager.startTracking();
                  isTrackingPaused.value = false;
                  AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: 2,
                      channelKey: 'ride_channel',
                      title: 'Ride Resumed',
                      body: 'Your ride has been resumed successfully.',
                      notificationLayout: NotificationLayout.Default,
                    ),
                  );
                } else {
                  bikeManager.pauseTracking();
                  isTrackingPaused.value = true;
                  AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: 1,
                      channelKey: 'ride_channel',
                      title: 'Ride Paused',
                      body:
                          'Your ride has been paused. You can resume anytime.',
                      notificationLayout: NotificationLayout.Default,
                    ),
                  );
                }
              },
              icon: Icon(
                isTrackingPaused.value ? Icons.play_arrow : Icons.pause,
                color:
                    isTrackingPaused.value ? AppColors.primary : Colors.white,
              ),
              label: Text(
                isTrackingPaused.value ? "Resume Trip" : "Pause Trip",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      isTrackingPaused.value ? AppColors.primary : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isTrackingPaused.value
                    ? Colors.transparent
                    : AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
            );
          }),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onShowEndTripSlider,
            icon: Icon(
              Icons.stop_circle_outlined,
              color: Colors.white,
              size: 20.w,
            ),
            label: Text(
              "End Trip",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EndTripSlider extends StatelessWidget {
  final VoidCallback onHideSlider;

  const _EndTripSlider({
    required this.onHideSlider,
  });

  @override
  Widget build(BuildContext context) {
    final BikeMetricsController bikeManager = Get.find<BikeMetricsController>();
    final TripsController endTripController = Get.find<TripsController>();
    final localStorage = Get.find<LocalStorage>();
    final isLoading = false.obs;

    return Obx(() {
      if (isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      }

      return SliderButton(
        shimmer: false,
        width: Get.width,
        height: 60.h,
        buttonSize: 50.h,
        backgroundColor: Colors.red,
        baseColor: Colors.white,
        buttonColor: Colors.white,
        highlightedColor: Colors.red.shade700,
        vibrationFlag: true,
        action: () async {
          try {
            isLoading.value = true;

            final BikeMetricsController bikeMetricsController = Get.find();

            if (bikeMetricsController.endPosition != null) {
              await bikeMetricsController.getLocationName(
                bikeMetricsController.endPosition!.latitude,
                bikeMetricsController.endPosition!.longitude,
                false,
              );
            }

            bikeMetricsController.saveTripSummary();
            bikeMetricsController.stopTracking();

            final locations = localStorage.getLocationList();
            AppLogger.i("Locations => $locations");

            final startTripController = Get.find();
            final id = startTripController.tripId.value;
            final durationObject = Duration(
              seconds: bikeMetricsController.totalDuration.value.toInt(),
            );

            final EndTrip endTripData = EndTrip(
              id: id,
              bikeId: bikeManager.bikeID.value,
              stationId: "0",
              startTimestamp: DateTime.now().subtract(durationObject),
              endTimestamp: DateTime.now(),
              distance: bikeMetricsController.totalDistance.value,
              duration: bikeMetricsController.totalDuration.value,
              averageSpeed: bikeMetricsController.currentSpeed.value,
              path: locations,
            );

            await endTripController.dataSend(endTripData, id);

            await localStorage.remove('locations');
            await localStorage.setBikeSubscribed(false);
            await localStorage.setBikeCode("");
            await localStorage.setEncodedID('');
            await localStorage.setDeviceID("");
            await localStorage.setInt('time', 0);

            bikeManager.bikeSubscribed.value = false;
            bikeManager.bikeID.value = "";
            bikeManager.totalDuration.value = 0;

            final MainPageController mainPageController = Get.find();
            mainPageController.isBikeSubscribed.value = false;

            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 3,
                channelKey: 'ride_channel',
                title: 'Trip Ended',
                body: 'Your trip has successfully ended. Thanks for riding!',
                notificationLayout: NotificationLayout.Default,
              ),
            );

            NavigationService.pushToWithCallback(
              RideSummary(tripData: endTripData),
              () {
                localStorage.setBikeSubscribed(false);
                Get.find<BikeMetricsController>().bikeSubscribed.value = false;
              },
            );

            bikeMetricsController.resetTripData();

            onHideSlider();
          } catch (e) {
            AppLogger.e('Error ending trip', error: e);
            isLoading.value = false;
          }
          return true;
        },
        alignLabel: Alignment.center,
        label: Text(
          "SLIDE TO END TRIP",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: Icon(
          Icons.arrow_forward,
          color: Colors.red,
          size: 24.w,
        ),
      );
    });
  }
}
