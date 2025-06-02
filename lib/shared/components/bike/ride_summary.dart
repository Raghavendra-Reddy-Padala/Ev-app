import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import '../../../core/storage/local_storage.dart';
import '../../../features/account/controllers/trips_controller.dart';
import '../../../features/bikes/controller/bike_controller.dart';
import '../../../features/bikes/controller/bike_metrics_controller.dart';
import '../../models/trips/trips_model.dart';
import '../map/path_view.dart';
import '../misc/miscdownloader.dart';
import 'summary_card.dart';

class RideSummary extends StatelessWidget {
  final EndTrip? tripData;

  RideSummary({super.key, this.tripData});

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final BikeMetricsController bikeController =
        Get.find<BikeMetricsController>();
    final LocalStorage localStorage = Get.find();
    final TripsController tripsController = Get.find();
    final BikeController bikeDataController = Get.find();

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Screenshot(
              controller: screenshotController,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        SummaryCard(
                          rideDetails: RideDetails(
                            type: 'Electric Bike',
                            bikeImage: 'assets/images/bike.png',
                            price: 0,
                            rideId: tripData?.bikeId ??
                                tripsController
                                    .endTripDetails.value?.data?.bikeId ??
                                "k2590tnkfx",
                            frameNumber: bikeDataController
                                    .bikeData.value?.frameNumber ??
                                'FN0199dfff',
                            duration: _getDurationText(
                              bikeController.totalDuration.value,
                              localStorage,
                            ),
                            calories: _getCaloriesText(
                              tripsController.endTripDetails.value?.data?.kcal,
                              bikeController.lastTripCalories.value,
                              localStorage,
                            ),
                            status: 'Completed',
                          ),
                          tripDetails: TripDetails(
                            pickupTime: tripData?.startTimestamp != null
                                ? DateFormat('hh:mma')
                                    .format(tripData!.startTimestamp)
                                : DateFormat('hh:mma').format(DateTime.now()),
                            dropTime: tripData?.endTimestamp != null
                                ? DateFormat('hh:mma')
                                    .format(tripData!.endTimestamp)
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
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: double.infinity,
                          height: 170.h,
                          child: PathView(
                            pathPoints: bikeController.pathPoints.isNotEmpty
                                ? bikeController.pathPoints
                                    .map((point) => LatLng(point[0], point[1]))
                                    .toList()
                                : [],
                            isScreenshotMode: false,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Miscellaneous(
                          diffPage: false,
                          screenshotController: screenshotController,
                        ),
                        SizedBox(height: 16.h),

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

  String _getDurationText(double localDuration, LocalStorage localStorage) {
    final time = localStorage.getDouble("lastTripDuration")?.toInt() ?? 0;

    if (time < 60) {
      return "$time sec";
    }

    final totalMinutes = (time / 60).round();
    final hours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;

    if (hours > 0) {
      return "$hours hr $remainingMinutes min";
    } else {
      return "$remainingMinutes min";
    }
  }

  String _getCaloriesText(
    num? backendCalories,
    double controllerCalories,
    LocalStorage localStorage,
  ) {
    final lastTripCal = localStorage.getDouble("lastTripCalories") ?? 0.0;

    if (lastTripCal > 0) {
      return "${lastTripCal.toInt()} Kcal";
    }

    if (controllerCalories > 0) {
      return "${controllerCalories.toInt()} Kcal";
    }

    return "0 Kcal";
  }
}
