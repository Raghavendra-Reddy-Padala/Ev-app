import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controllers/location_controller.dart';

class MapsView extends StatefulWidget {
  const MapsView({super.key});

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  final LocationController locationController = Get.find();
  final GetNearbyStationsController _nearbyStationsController =
      Get.find<GetNearbyStationsController>();

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await locationController.fetchUserLocation();
    await _fetchStations();

    ever(_nearbyStationsController.nearbyStations, (stations) {
      if (mounted) {
        setState(() {
          _updateMarkers(stations);
        });
      }
    });
  }

  Future<void> _fetchStations() async {
    await _nearbyStationsController.fetchNearbyStations(
      locationController.initialLocation.value.latitude,
      locationController.initialLocation.value.longitude,
    );
  }

  void _updateMarkers(List<Station> stations) {
    if (!mounted) return;

    final locations = stations
        .map((station) => LatLng(
              double.parse(station.locationLatitude),
              double.parse(station.locationLongitude),
            ))
        .toList();

    locationController.markLocations(locations);
  }

  String _getMapStyle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? MapStyles.customDark
        : MapStyles.customLight;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!locationController.isLocationReady.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return _buildMap(context);
    });
  }

  Widget _buildMap(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: locationController.initialLocation.value,
        zoom: 7,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: locationController.markers.toSet(),
      onMapCreated: (GoogleMapController controller) {
        _onMapCreated(controller, context);
      },
    );
  }

  void _onMapCreated(GoogleMapController controller, BuildContext context) {
    locationController.mapController.value = controller;
    controller.setMapStyle(_getMapStyle(context));

    _nearbyStationsController.nearbyStations.listen((stations) {
      final stationLocations = stations
          .map((station) => LatLng(
                double.parse(station.locationLatitude),
                double.parse(station.locationLongitude),
              ))
          .toList();

      locationController.markLocations(stationLocations);
    });
  }
}
