import 'dart:convert';
import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../main.dart';
import '../../../shared/models/trips/active_trip_model.dart'
    show ActiveTripResponse, LongestRide;
import '../../../shared/models/trips/trips_model.dart' show EndTripModel, StartTrip, TripsResponse;
import '../../../shared/models/user/user_model.dart';
import '../../../shared/services/dummy_data_service.dart';
import '../../authentication/views/auth_view.dart';

class TripsController extends BaseController {
  final RxList<Trip> trips = <Trip>[].obs;
  final RxList<TripLocation> tripLocations = <TripLocation>[].obs;
  Rx<EndTripModel?> endTripDetails = Rx<EndTripModel?>(null);
  final RxDouble currentSpeed = 0.0.obs;
  final RxDouble totalDistance = 0.0.obs;
  final RxDouble totalDuration = 0.0.obs;
  final RxInt calculatedCalories = 0.obs;
  final RxInt maxElevation = 0.obs;
  final RxString bikeId = ''.obs;
  final RxString tripId = ''.obs;
  final RxBool isLocationUpdated = false.obs;
  final LocalStorage localStorage = Get.find<LocalStorage>();
  final Rx<ActiveTripResponse?> activeTripData = Rx<ActiveTripResponse?>(null);
  
  @override
  void onInit() {
    super.onInit();
    fetchTrips();
  }

Future<bool> startTrip(StartTrip startTripData, {required bool personal}) async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await apiService.post(
      endpoint: ApiConstants.tripsStart,
      body: startTripData.toJson(),
      headers: {
        'Authorization': 'Bearer ${localStorage.getToken()}',
        'X-Karma-App': 'dafjcnalnsjn'
      },
    );

    if (response != null) {
      // If we get "already have active trip" message, fetch and use that trip
      if (response['message']?.toString().contains('already have an active trip') == true) {
        final activeTrip = await fetchActiveTrip();
        if (activeTrip != null) {
          tripId.value = activeTrip.id;
          activeTripData.value = activeTrip;
          return true; // Success - we're continuing existing trip
        }
      }

      // Normal success case
      if (response['success'] == true) {
        tripId.value = response['id']?.toString() ?? 
                       response['data']?['id']?.toString() ?? 
                       response['data']?['trip_id']?.toString() ?? '';
        return true;
      }

      errorMessage.value = response['message'] ?? 'Failed to start trip';
      return false;
    }

    errorMessage.value = 'Failed to start trip';
    return false;
  } catch (e) {
    errorMessage.value = 'Error starting trip: $e';
    return false;
  } finally {
    isLoading.value = false;
  }
}  Future<ActiveTripResponse?> fetchActiveTrip() async {
  try {
    final String? authToken = localStorage.getToken();
    if (authToken == null) {
      print('Authentication token not found');
      return null;
    }

    final response = await apiService.get(
      endpoint: 'trips/active',
      headers: {
        'Authorization': 'Bearer $authToken',
        'X-Karma-App': 'dafjcnalnsjn'
      },
    );

    if (response != null) {
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        
        // Create ActiveTripResponse from the actual response structure
        return ActiveTripResponse(
          id: data['trip_id']?.toString() ?? '', // This is the key fix
          distanceKm: (data['longest_ride']?['distance_km'] ?? 0).toDouble(),
          speedKmh: (data['highest_speed'] ?? 0).toDouble(),
          caloriesTrip: (data['total_calories'] ?? 0).toDouble(),
          maxElevationM: (data['max_elevation_m'] ?? 0).toDouble(),
          totalTimeHours: (data['total_time_hours'] ?? 0).toDouble(),
           carbonFootprintKg: (data['carbon_footprint_kg'] ?? 0).toDouble(),
          highestSpeed: (data['highest_speed'] ?? 0).toDouble(),
          totalCalories: (data['total_calories'] ?? 0).toDouble(),
          totalTrips: (data['total_trips'] ?? 0).toInt(),
          longestRide: LongestRide.fromJson(data['longest_ride'] ?? {})
              
          // Add other fields as needed based on your ActiveTripResponse model
        );
      } else if (response['success'] == false && response['data'] == null) {
        print('No active trips found: ${response['message']}');
        return null;
      }
    }

    return null;
  } catch (e) {
    print('Error fetching active trip: $e');
    return null;
  }
}
  Future<void> refreshTrips() async {
    await fetchTrips();
  }

  Future<bool> dataSend(bool personal) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await useApiOrDummy(
        apiCall: () async {
          final String? authToken = localStorage.getToken();
          if (authToken == null) {
            NavigationService.pushReplacementTo(const AuthView());
            return false;
          }
          final Map<String, dynamic> requestBody = {
            'personal': personal,
          };
          final response = await apiService.post(
            endpoint: 'trips/end/$tripId',
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn'
            },
            body: requestBody
          );

          if (response != null) {
            endTripDetails.value = EndTripModel.fromJson(response);

            Toast.show(
              message: "Trip Ended!",
              type: ToastType.success,
            );

            saveTripsDataToLocalStorage();

            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getEndTripResponse("");

          if (dummyData['success']) {
            endTripDetails.value = EndTripModel.fromJson(dummyData);

            Toast.show(
              message: "Trip Ended!",
              type: ToastType.success,
            );
            saveTripsDataToLocalStorage();

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

  Future<void> fetchTrips() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = localStorage.getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: ApiConstants.tripsMyTrips,
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );

          if (response != null) {
            final tripsResponse = TripsResponse.fromJson(response);
            trips.assignAll(tripsResponse.data);
            saveTripsDataToLocalStorage();
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getTripsResponse();
          final tripsResponse = TripsResponse.fromJson(dummyData);
          trips.assignAll(tripsResponse.data);
          saveTripsDataToLocalStorage();

          return true;
        },
      );
    } catch (e) {
      handleError(e);
      loadTripsDataFromLocalStorage();
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
          final String? authToken = localStorage.getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: 'trips/$tripId/locations',
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );

          if (response != null) {
            final locationsResponse = TripLocationsResponse.fromJson(response);
            tripLocations.assignAll(locationsResponse.data);
            //saveTripLocationsToLocalStorage(tripId);

            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getTripLocationsResponse();
          final locationsResponse = TripLocationsResponse.fromJson(dummyData);
          tripLocations.assignAll(locationsResponse.data);
          //saveTripLocationsToLocalStorage(tripId);

          return true;
        },
      );
    } catch (e) {
      handleError(e);
      // loadTripLocationsFromLocalStorage(tripId);
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
          final String? authToken = localStorage.getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.put(
            endpoint: 'trips/location/$tripId',
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
              'X-Karma-App': 'dafjcnalnsjn'
            },
            body: {
              'lat': lat,
              'long': long,
              'elevation': elevation,
            },
          );

          if (response != null && response['success'] == true) {
            final data = response['data'];
            _updateTripMetrics(data);
            isLocationUpdated.value = true;
            saveTripMetricsToLocalStorage();

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
            saveTripMetricsToLocalStorage();

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

  void saveTripsDataToLocalStorage() {
    try {
      if (trips.isNotEmpty) {
        final List<Map<String, dynamic>> tripsJson =
            trips.map((trip) => trip.toJson()).toList();
        localStorage.setString('trips_data', json.encode(tripsJson));
      }
    } catch (e) {
      print("Error saving trips data to localStorage: $e");
    }
  }

  void loadTripsDataFromLocalStorage() {
    try {
      final String? tripsData = localStorage.getString('trips_data');
      if (tripsData != null && tripsData.isNotEmpty) {
        final List<dynamic> tripsJson = json.decode(tripsData);
        final List<Trip> loadedTrips =
            tripsJson.map((json) => Trip.fromJson(json)).toList();
        trips.assignAll(loadedTrips);
      }
    } catch (e) {
      print("Error loading trips data from localStorage: $e");
    }
  }

  void saveTripMetricsToLocalStorage() {
    try {
      localStorage.setDouble("totalDistance", totalDistance.value);
      localStorage.setDouble("currentSpeed", currentSpeed.value);
      localStorage.setDouble("totalDuration", totalDuration.value);
      localStorage.setInt("calculatedCalories", calculatedCalories.value);
      localStorage.setInt("maxElevation", maxElevation.value);
      localStorage.setString("bikeId", bikeId.value);
      localStorage.setString("tripId", tripId.value);
    } catch (e) {
      print("Error saving trip metrics to localStorage: $e");
    }
  }

  void loadTripMetricsFromLocalStorage() {
    try {
      totalDistance.value = localStorage.getDouble("totalDistance") ?? 0.0;
      currentSpeed.value = localStorage.getDouble("currentSpeed") ?? 0.0;
      totalDuration.value = localStorage.getDouble("totalDuration") ?? 0.0;
      calculatedCalories.value = localStorage.getInt("calculatedCalories") ?? 0;
      maxElevation.value = localStorage.getInt("maxElevation") ?? 0;
      bikeId.value = localStorage.getString("bikeId") ?? '';
      tripId.value = localStorage.getString("tripId") ?? '';
    } catch (e) {
      print("Error loading trip metrics from localStorage: $e");
    }
  }
}