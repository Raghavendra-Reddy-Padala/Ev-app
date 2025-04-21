import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripSliderController extends GetxController {
  final RxBool isEndTripSliderVisible = false.obs;

  void showEndTripSlider() => isEndTripSliderVisible.value = true;
  void hideEndTripSlider() => isEndTripSliderVisible.value = false;
}

class TripControls {
  static Widget buildResumeAndEndButtons() {
    final TripSliderController endTripSliderController =
        Get.find<TripSliderController>();
    final RxBool isTrackingPaused = false.obs;
    final BikeMetricsController bikeManager = Get.find();

    return Obx(() {
      if (endTripSliderController.isEndTripSliderVisible.value) {
        return const SizedBox.shrink();
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pauseResumeButton(isTrackingPaused, bikeManager),
            _endTripButton(endTripSliderController),
          ],
        );
      }
    });
  }

  static Widget _pauseResumeButton(
      RxBool isTrackingPaused, BikeMetricsController bikeManager) {
    return SizedBox(
      width: 152.w,
      child: ElevatedButton(
        onPressed: () => _handlePauseResumePress(isTrackingPaused, bikeManager),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isTrackingPaused.value ? Colors.transparent : EVColors.primary,
          side: BorderSide(color: EVColors.primary),
          fixedSize: Size(152.w, 50.h),
          elevation: 0,
        ),
        child: Text(
          isTrackingPaused.value ? "Resume Trip" : "Pause Trip",
          style: CustomTextTheme.bodyMediumPBold.copyWith(
            color: isTrackingPaused.value ? EVColors.primary : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static void _handlePauseResumePress(
      RxBool isTrackingPaused, BikeMetricsController bikeManager) {
    if (isTrackingPaused.value) {
      bikeManager.startTracking();
      isTrackingPaused.value = false;
      _showNotification(
          2, 'Ride Resumed', 'Your ride has been resumed successfully.');
    } else {
      bikeManager.pauseTracking();
      isTrackingPaused.value = true;
      _showNotification(1, 'Ride Paused',
          'Your ride has been paused. You can resume anytime.');
    }
  }

  static void _showNotification(int id, String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'ride_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Widget _endTripButton(TripSliderController endTripSliderController) {
    return SizedBox(
      width: 152.w,
      child: ElevatedButton(
        onPressed: () {
          if (!endTripSliderController.isEndTripSliderVisible.value) {
            endTripSliderController.showEndTripSlider();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          fixedSize: Size(152.w, 50.h),
        ),
        child: Text(
          "End Trip",
          style: CustomTextTheme.bodyMediumPBold.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static Widget buildEndTripSlider() {
    final BikeMetricsController bikeManager = Get.find<BikeMetricsController>();
    final EndTripController endTripController = Get.find<EndTripController>();
    final SharedPreferencesService sharedPreferencesService =
        Get.find<SharedPreferencesService>();

    final isLoading = false.obs;

    return Obx(() => Column(
          children: [
            if (isLoading.value)
              Center(
                child: CircularProgressIndicator(
                  color: EVColors.primary,
                ),
              )
            else
              SliderButton(
                shimmer: false,
                width: Get.width,
                boxShadow: BoxShadow(
                  color: EVColors.offwhite,
                  spreadRadius: 1.0,
                  blurRadius: 3.0,
                ),
                buttonColor: EVColors.white,
                backgroundColor: Colors.red,
                action: () async => await _handleEndTrip(bikeManager,
                    endTripController, sharedPreferencesService, isLoading),
                alignLabel: Alignment.center,
                label: Text(
                  "END TRIP",
                  style: CustomTextTheme.bodyMediumPBold.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                ),
              ),
          ],
        ));
  }

  static Future<bool> _handleEndTrip(
      BikeMetricsController bikeManager,
      EndTripController endTripController,
      SharedPreferencesService sharedPreferencesService,
      RxBool isLoading) async {
    try {
      isLoading.value = true;
      SpeedCalculatorController speedCalculatorController = Get.find();

      BikeMetricsController bikeMetricsController = Get.find();

      if (bikeMetricsController.endPosition != null) {
        await bikeMetricsController.getLocationName(
            bikeMetricsController.endPosition!.latitude,
            bikeMetricsController.endPosition!.longitude,
            false);
      }

      bikeMetricsController.saveTripSummary();
      bikeMetricsController.stopTracking();

      List<List<double>> locations = sharedPreferencesService.getLocationList();
      logger.i("Locations => \$locations");

      final StartTripController startTripController = Get.find();
      final id = startTripController.tripId.value;

      Duration durationObject =
          Duration(seconds: bikeMetricsController.totalDuration.value.toInt());

      EndTrip endTripData = EndTrip(
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

      await _resetBikeData(sharedPreferencesService, bikeManager);

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
          SharedPreferencesService sharedPreferencesService =
              Get.find<SharedPreferencesService>();
          sharedPreferencesService.setBikeSubscribed(false);
          Get.find<BikeMetricsController>().bikeSubscribed.value = false;
        },
      );

      bikeMetricsController.resetTripData();
      speedCalculatorController.resetTripData();

      return true;
    } catch (e) {
      logger.e(e);
      Get.snackbar(
        'Error',
        'Failed to end trip. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoading.value = false;
      return false;
    }
  }

  static Future<void> _resetBikeData(
      SharedPreferencesService sharedPreferencesService,
      BikeMetricsController bikeManager) async {
    await sharedPreferencesService.remove('locations');
    await sharedPreferencesService.setBikeSubscribed(false);
    await sharedPreferencesService.setBikeCode("");
    await sharedPreferencesService.setEncodedID('');
    await sharedPreferencesService.setDeviceID("");
    await sharedPreferencesService.setTime(0);

    bikeManager.bikeSubscribed.value = false;
    bikeManager.bikeID.value = "";
    bikeManager.totalDuration.value = 0;

    MainPageController mainPageController = Get.find<MainPageController>();
    mainPageController.isBikeSubscribed.value = false;
  }
}
