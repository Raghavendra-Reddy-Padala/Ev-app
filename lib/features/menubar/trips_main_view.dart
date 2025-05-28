import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:mjollnir/shared/components/activity/activity_widget.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/components/trips/individual_tripscreen.dart';


class MyTrips extends StatelessWidget {
  const MyTrips({super.key});

  @override
  Widget build(BuildContext context) {
    final TripsController tripsController = Get.find();
    tripsController.fetchTrips();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: 10.h,
          bottom: 10.h,
          left: 10.h,
          right: 10.h,
        ),
        child: const SafeArea(
          child: _UI(),
        ),
      ),
    );
  }
}

class _UI extends StatelessWidget {
  const _UI();

  @override
  Widget build(BuildContext context) {
    final TripsController tripController = Get.find<TripsController>();

    return Column(
      children: [
        Header(heading: "My Trips"),
        SizedBox(height: 5.h),
        Obx(() {
          if (tripController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (tripController.errorMessage.value.isNotEmpty) {
            return Center(child: Text(tripController.errorMessage.value));
          }

          return (tripController.trips.isEmpty)
              ? Padding(
                  padding: EdgeInsets.only(
                      top: (ScreenUtil().screenHeight - 300.h) / 2),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 100.w,
                          height: 100.h,
                          child: Image.asset('assets/images/no-data.png'),
                        ),
                        Text(
                          'No trips found!',
                          style: AppTextThemes.bodyMedium()
                              .copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: tripController.trips.length,
                    itemBuilder: (context, index) {
                      final trip = tripController.trips[index];
                     final pathPoints = tripController.convertToLatLng(
  trip.path.map((point) => [point.lat, point.long]).toList()
);

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              
                                Get.to(()=>  IndividualTripScreen(trip: trip));
                            },
                            child: ActivityWidget(
                              pathPoints: pathPoints,
                              trip: trip,
                            ),
                          ),
                          if (index < tripController.trips.length - 1)
                            SizedBox(height: 10.h),
                        ],
                      );
                    },
                  ),
                );
        }),
      ],
    );
  }
}
