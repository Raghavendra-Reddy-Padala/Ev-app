import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';
import '../../../shared/models/stations/station.dart';
import '../../../shared/services/dummy_data_service.dart';

class StationController extends BaseController {
  final RxList<Station> stations = <Station>[].obs;
  final RxList<Station> filteredStations = <Station>[].obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final Rxn<LatLng> userLocation = Rxn<LatLng>();

  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    fetchUserLocation();
    fetchAllStations();
  }

  Future<void> fetchUserLocation() async {
    try {
      final loc.Location location = loc.Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          errorMessage.value = "Location services are disabled";
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          errorMessage.value = "Location permissions are denied";
          return;
        }
      }

      final locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        userLocation.value =
            LatLng(locationData.latitude!, locationData.longitude!);
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> fetchAllStations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final response = await apiService.get(
            endpoint: '/v1/stations/get',
            headers: {
              'X-Karma-Admin-Auth': 'ajbkbakweiuy387yeuqqwfahdjhsabd',
            },
          );

          if (response != null) {
            final stationResponse = StationResponse.fromJson(response.data);
            stations.assignAll(stationResponse.stations);
            filteredStations.assignAll(stationResponse.stations);
            _updateMarkers();
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getStationsResponse();
          final stationResponse = StationResponse.fromJson(dummyData);
          stations.assignAll(stationResponse.stations);
          filteredStations.assignAll(stationResponse.stations);
          _updateMarkers();
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNearbyStations(double lat, double lon) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final response = await apiService.get(
            endpoint: '/v1/stations/get_nearby?lat=$lat&lon=$lon&limit=6',
            headers: {
              'X-Karma-Admin-Auth': 'ajbkbakweiuy387yeuqqwfahdjhsabd',
            },
          );

          if (response != null) {
            final stationResponse = StationResponse.fromJson(response.data);
            stations.assignAll(stationResponse.stations);
            filteredStations.assignAll(stationResponse.stations);
            _updateMarkers();
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getStationsResponse();
          final stationResponse = StationResponse.fromJson(dummyData);
          stations.assignAll(stationResponse.stations);
          filteredStations.assignAll(stationResponse.stations);
          _updateMarkers();
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _updateMarkers() {
    final newMarkers = stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(
          double.parse(station.locationLatitude),
          double.parse(station.locationLongitude),
        ),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: 'Capacity: ${station.currentCapacity}/${station.capacity}',
        ),
      );
    }).toSet();

    markers.value = newMarkers;
  }

  void filterStations(String query) {
    if (query.isEmpty) {
      filteredStations.assignAll(stations);
    } else {
      filteredStations.assignAll(stations.where((station) =>
          station.name.toLowerCase().contains(query.toLowerCase())));
    }
  }

  Future<void> goToLocation(LatLng target) async {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(target));
    }
  }

  Future<void> goToUserLocation() async {
    try {
      if (userLocation.value != null && mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: userLocation.value!,
              zoom: 15.0,
            ),
          ),
        );
      } else {
        await fetchUserLocation();
        if (userLocation.value != null && mapController != null) {
          await mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: userLocation.value!,
                zoom: 15.0,
              ),
            ),
          );
        }
      }
    } catch (e) {
      handleError(e);
    }
  }
}
