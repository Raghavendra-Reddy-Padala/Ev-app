import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/features/authentication/controller/loc_controller.dart';
import 'package:mjollnir/features/home/controller/station_controller.dart';
import 'package:mjollnir/features/home/views/stationbikesview.dart';
import 'package:mjollnir/shared/components/stations/station_card.dart';

class StationsList extends StatefulWidget {
  const StationsList({super.key});

  @override
  State<StationsList> createState() => _StationsListState();
}

class _StationsListState extends State<StationsList> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      final LocationController locationController = Get.find<LocationController>();
      final StationController stationController = Get.find<StationController>();
      
      print('Starting data initialization...');
      
      await Future.wait([
        locationController.fetchUserLocation(),
        stationController.fetchAllStations(),
      ]);
      
      print('Data initialization completed');
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  double _safeParse(String? value, {double defaultValue = 0.0}) {
    if (value == null || value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.find<LocationController>();
    final StationController nearbyStationsController = Get.find<StationController>();

    return Obx(() {
      if (nearbyStationsController.isLoading.value || 
          locationController.initialLocation.value == null) {
        return  Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (nearbyStationsController.errorMessage.value.isNotEmpty) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: const Text('Get Nearby Stations'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Show no stations message
      if (nearbyStationsController.nearbyStations.isEmpty) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(child: Text("No nearby stations found.")),
          ),
        );
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
              padding: const EdgeInsets.all(16),
              itemCount: nearbyStationsController.nearbyStations.length,
              itemBuilder: (context, index) {
                final station = nearbyStationsController.nearbyStations[index];
                final stationLocation = LatLng(
                  _safeParse(station.locationLatitude),
                  _safeParse(station.locationLongitude),
                );

                final LocationController lc = Get.find();
                if (!lc.locations.contains(stationLocation)) {
                  lc.locations.add(stationLocation);
                }
                
                final userLocation = locationController.initialLocation.value;
                final distance = userLocation != null 
                    ? _calculateDistance(userLocation, stationLocation)
                    : 0.0;

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