import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/features/authentication/controller/loc_controller.dart';
import 'package:mjollnir/features/home/controller/station_controller.dart';
import 'package:mjollnir/features/home/views/stationbikesview.dart';
import 'package:mjollnir/shared/components/stations/station_card.dart';

class StationsList extends StatelessWidget {
  const StationsList({super.key});

  double _safeParse(String? value, {double defaultValue = 0.0}) {
    if (value == null || value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.find();
    locationController.fetchUserLocation();
    final userLocation = locationController.initialLocation;

    final StationController nearbyStationsController =
        Get.find<StationController>();
    nearbyStationsController.fetchAllStations();

    return Obx(() {
      if (nearbyStationsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (nearbyStationsController.nearbyStations.isEmpty) {
        return const Center(child: Text("No nearby stations found."));
      }

      return DraggableScrollableSheet(
        initialChildSize: 0.2,
        minChildSize: 0.2,
        maxChildSize: 0.39,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(16),
              itemCount: nearbyStationsController.nearbyStations.length,
              itemBuilder: (context, index) {
                final station = nearbyStationsController.nearbyStations[index];
                final stationLocation = LatLng(
                  _safeParse(station.locationLatitude),
                  _safeParse(station.locationLongitude),
                );

                final LocationController lc = Get.find();
                lc.locations.add(stationLocation);
                final distance =
                    _calculateDistance(userLocation.value, stationLocation);

                return StationCard(
                  station: station,
                  distance: distance,
                  onTap: () {
                    Get.to(() => StationBikesView(station: station));
                  },
                );
              },
            ),
          );
        },
      );
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;
    final double dLat = _degreesToRadians(end.latitude - start.latitude);
    final double dLon = _degreesToRadians(end.longitude - start.longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
