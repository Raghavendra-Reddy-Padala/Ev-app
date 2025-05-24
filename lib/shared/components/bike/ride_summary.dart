import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mjollnir/features/bikes/controller/bike_controller.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/components/misc/miscdownloader.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/navigation/navigation_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../features/account/controllers/trips_controller.dart';
import '../../../features/bikes/controller/bike_metrics_controller.dart';
import '../../models/trips/trips_model.dart';
import '../map/path_view.dart';
import 'summary_card.dart';

class RideSummary extends StatelessWidget {
  final EndTrip? tripData;

  RideSummary({super.key, this.tripData});

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final BikeMetricsController bikeController =
        Get.find<BikeMetricsController>();

    final LocalStorage sharedPreferencesService = Get.find();
    bool takingScreenshot = false;

    final TripsController endTripController = Get.find();
    final BikeController bikeDataController = Get.find();

    print(bikeDataController.bikeData.value?.frameNumber);
    final effectiveTripData = tripData;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Screenshot(
              controller: screenshotController,
              child: Column(
                children: [
                  const Header(heading: "Ride Summary"),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20.w, right: 20.w, top: 5.w, bottom: 5.w),
                    child: Column(
                      children: [
                        SummaryCard(
                          rideDetails: RideDetails(
                            type: 'Electirc Bike',
                            bikeImage: 'assets/images/bike.png',
                            price: 0,
                            rideId: effectiveTripData?.bikeId ??
                                endTripController
                                    .endTripDetails.value?.data?.bikeId
                                    .toString() ??
                                "k2590tnkfx",
                            frameNumber: bikeDataController
                                    .bikeData.value?.frameNumber ??
                                'FN0199dfff',
                            duration: _getDurationText(
                              bikeController.totalDuration.value,
                              sharedPreferencesService,
                            ),
                            calories: _getCaloriesText(
                              endTripController
                                  .endTripDetails.value?.data?.kcal,
                              bikeController.lastTripCalories.value,
                              sharedPreferencesService,
                            ),
                            status: 'Completed',
                          ),
                          tripDetails: TripDetails(
                            pickupTime: effectiveTripData?.startTimestamp !=
                                    null
                                ? DateFormat('hh:mma').format(effectiveTripData
                                        ?.startTimestamp is DateTime
                                    ? effectiveTripData!.startTimestamp
                                    : DateTime.parse(effectiveTripData!
                                        .startTimestamp
                                        .toString()))
                                : DateFormat('hh:mma').format(DateTime.now()),
                            dropTime: effectiveTripData?.endTimestamp != null
                                ? DateFormat('hh:mma').format(
                                    effectiveTripData?.endTimestamp is DateTime
                                        ? effectiveTripData!.endTimestamp
                                        : DateTime.parse(effectiveTripData!
                                            .endTimestamp
                                            .toString()))
                                : "N/A",
                            pickupLocation: bikeController
                                    .startLocationName.value.isNotEmpty
                                ? bikeController.startLocationName.value
                                : "Unknown Location",
                            dropLocation:
                                bikeController.endLocationName.value.isNotEmpty
                                    ? bikeController.endLocationName.value
                                    : "Unknown Location",
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: ScreenUtil().screenWidth,
                          height: 170.h,
                          child: PathView(
                            pathPoints: bikeController.pathPoints.isNotEmpty
                                ? bikeController.pathPoints
                                    .map((point) => LatLng(point[0], point[1]))
                                    .toList()
                                : [],
                            isScreenshotMode: takingScreenshot,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: double.infinity,
                          height: 60.h,
                          child: Miscellaneous(
                            diffPage: false,
                            screenshotController: ScreenshotController(),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 60.h,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: ScreenUtil().screenHeight * 0.02),
                            child: ElevatedButton(
                              onPressed: () {
                                NavigationService.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDurationText(
      double localDuration, LocalStorage sharedPreferencesService) {
    int time =
        sharedPreferencesService.getDouble("lastTripDuration")?.toInt() ?? 0;
    if (time < 60) {
      return "$time sec";
    }
    int totalMinutes = (time / 60).round();
    int hours = totalMinutes ~/ 60;
    int remainingMinutes = totalMinutes % 60;

    if (hours > 0) {
      return "$hours hr $remainingMinutes min";
    } else {
      return "$remainingMinutes min";
    }
  }

  String _getCaloriesText(num? backendCalories, double bikeController,
      LocalStorage sharedPreferencesService) {
    print("Backend calories: ${backendCalories}");
    print("Current bikeController calories: ${bikeController}");

    double lastTripCal =
        sharedPreferencesService.getDouble("lastTripCalories") ?? 0.0;
    print("lastTripCalories from SharedPrefs: ${lastTripCal}");

    if (lastTripCal > 0) {
      return "${lastTripCal.toInt()} Kcal";
    }

    if (bikeController > 0) {
      return "${bikeController.toInt()} Kcal";
    }

    return "0 Kcal";
  }
}
