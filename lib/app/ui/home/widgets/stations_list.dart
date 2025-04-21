import 'dart:math';

import 'package:flutter/material.dart';

class StationsList extends StatelessWidget {
  const StationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.find();
    locationController.fetchUserLocation();

    final userLocation = locationController.initialLocation;
    final GetStationsController nearbyStationsController =
        Get.find<GetStationsController>();

    nearbyStationsController.fetchStations();

    return Obx(() {
      if (nearbyStationsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (nearbyStationsController.nearbyStations.isEmpty) {
        return const Center(child: Text("No nearby stations found."));
      }

      return _buildDraggableStationList(
          context, nearbyStationsController, userLocation);
    });
  }

  Widget _buildDraggableStationList(BuildContext context,
      GetStationsController stationsController, Rx<LatLng> userLocation) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: _buildStationListView(
              stationsController, userLocation, scrollController),
        );
      },
    );
  }

  Widget _buildStationListView(GetStationsController stationsController,
      Rx<LatLng> userLocation, ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      itemCount: stationsController.nearbyStations.length,
      itemBuilder: (context, index) {
        final station = stationsController.nearbyStations[index];
        final stationLocation = LatLng(
          _safeParse(station.locationLatitude),
          _safeParse(station.locationLongitude),
        );
        Get.find<LocationController>().locations.add(stationLocation);
        final distance =
            _calculateDistance(userLocation.value, stationLocation);

        return GestureDetector(
          onTap: () => _onStationTap(stationLocation),
          child: StationsWidget(
            station: station,
            distance: distance,
          ),
        );
      },
    );
  }

  void _onStationTap(LatLng stationLocation) {
    Get.find<LocationController>().goToCustomLocation(stationLocation);
  }

  double _safeParse(String? value, {double defaultValue = 0.0}) {
    if (value == null || value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
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
