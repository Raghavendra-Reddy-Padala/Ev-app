import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/routes/app_routes.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/components/indicators/loading_indicator.dart';
import 'package:mjollnir/shared/components/states/empty_state.dart';

import '../../shared/components/activity/activity_widget.dart';
import '../../shared/models/user/user_model.dart';
import '../account/controllers/trips_controller.dart';

class TripsMainView extends StatelessWidget {
  const TripsMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40.h),
        child: Header(heading: 'Trips'),
      ),
      body: GetBuilder<TripsController>(
        init: TripsController(),
        builder: (controller) => SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshTrips,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _TripsContent(controller: controller),
            ),
          ),
        ),
      ),
    );
  }
}

class _TripsContent extends StatelessWidget {
  final TripsController controller;

  const _TripsContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.trips.isEmpty) {
        return SizedBox(
          height: 0.8.sh,
          child: const LoadingIndicator(
            type: LoadingType.circular,
            message: 'Loading trips...',
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty && controller.trips.isEmpty) {
        return SizedBox(
          height: 0.8.sh,
          child: EmptyState(
            title: 'Failed to load trips',
            subtitle: controller.errorMessage.value,
            icon: Icon(Icons.error_outline, size: 64.w, color: Colors.red),
            buttonText: 'Retry',
            onButtonPressed: controller.refreshTrips,
          ),
        );
      }

      if (controller.trips.isEmpty) {
        return SizedBox(
          height: 0.8.sh,
          child: EmptyState(
            title: 'No trips found!',
            subtitle: 'Start your first trip to see it here',
            icon: Icon(Icons.directions_bike, size: 64.w, color: Colors.grey),
            buttonText: 'Start Trip',
            onButtonPressed: () => Get.toNamed(Routes.BIKE),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildTripsList(),
            SizedBox(height: 32.h),
          ],
        ),
      );
    });
  }

  Widget _buildTripsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.trips.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final trip = controller.trips[index];
        final pathPoints = controller.convertToLatLng(
          trip.path.map((point) => [point.lat, point.long]).toList(),
        );

        return GestureDetector(
          onTap: () => _navigateToTripDetails(trip),
          child: ActivityWidget(
            pathPoints: pathPoints,
            trip: trip,
          ),
        );
      },
    );
  }

  void _navigateToTripDetails(Trip trip) {
    // NavigationService.pushTo(
    //   IndividualTripView(trip: trip),
    // );
  }
}
