import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';

import '../../../shared/models/user/user_model.dart';
import '../../../shared/services/dummy_data_service.dart';

class TripsController extends BaseController {
  final RxList<Trip> trips = <Trip>[].obs;
  final RxList<TripLocation> tripLocations = <TripLocation>[].obs;

  final RxDouble currentSpeed = 0.0.obs;
  final RxDouble totalDistance = 0.0.obs;
  final RxDouble totalDuration = 0.0.obs;
  final RxInt calculatedCalories = 0.obs;
  final RxInt maxElevation = 0.obs;
  final RxString bikeId = ''.obs;
  final RxBool isLocationUpdated = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: '/v1/trips/mytrips',
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          );

          if (response != null) {
            final tripsResponse = TripsResponse.fromJson(response.data);
            trips.assignAll(tripsResponse.data);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getTripsResponse();
          final tripsResponse = TripsResponse.fromJson(dummyData);
          trips.assignAll(tripsResponse.data);
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTripLocations(String tripId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: '/v1/trips/$tripId/locations',
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response != null) {
            final locationsResponse =
                TripLocationsResponse.fromJson(response.data);
            tripLocations.assignAll(locationsResponse.data);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getTripLocationsResponse();
          final locationsResponse = TripLocationsResponse.fromJson(dummyData);
          tripLocations.assignAll(locationsResponse.data);
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTripLocation(
      {required String tripId,
      required double lat,
      required double long,
      required double elevation}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isLocationUpdated.value = false;

      final result = await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.put(
            endpoint: '/v1/trips/location/$tripId',
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: {
              'lat': lat,
              'long': long,
              'elevation': elevation,
            },
          );

          if (response != null && response.data['success'] == true) {
            final data = response.data['data'];
            _updateTripMetrics(data);
            isLocationUpdated.value = true;
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.putTripLocationResponse();
          if (dummyData['success']) {
            final data = dummyData['data'];
            _updateTripMetrics(data);
            isLocationUpdated.value = true;

            tripLocations.add(TripLocation(latitude: lat, longitude: long));
            return true;
          }
          return false;
        },
      );

      return result;
    } catch (e) {
      handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _updateTripMetrics(Map<String, dynamic> data) {
    currentSpeed.value = data['average_speed']?.toDouble() ?? 0.0;
    totalDistance.value = data['distance']?.toDouble() ?? 0.0;
    totalDuration.value = data['duration']?.toDouble() ?? 0.0;
    calculatedCalories.value = data['kcal']?.toInt() ?? 0;
    maxElevation.value = data['max_elevation']?.toInt() ?? 0;
    bikeId.value = data['bike_id'] ?? '';
  }

  List<LatLng> convertToLatLng(List<List<double>> path) {
    try {
      return path.map((point) {
        if (point.length < 2) {
          return const LatLng(0, 0);
        }
        return LatLng(point[0], point[1]);
      }).toList();
    } catch (e) {
      print("Error in convertToLatLng: $e");
      return [];
    }
  }
}
