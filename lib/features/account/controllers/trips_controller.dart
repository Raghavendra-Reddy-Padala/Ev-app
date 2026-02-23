import 'dart:convert';
import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../main.dart';
import '../../../shared/models/trips/active_trip_model.dart'
    show ActiveTripResponse, LongestRide;
import '../../../shared/models/trips/trips_model.dart'
    show EndTripModel, StartTrip, TripsResponse;
import '../../../shared/models/user/user_model.dart';
import '../../../shared/services/dummy_data_service.dart';
import '../../authentication/views/auth_view.dart';
import '../../bikes/controller/bike_metrics_controller.dart';

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

  Future<bool> startTrip(StartTrip startTripData,
      {required bool personal}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print("🚀 Starting trip...");
      print("   Bike ID: ${startTripData.bikeId}");
      print("   Station ID: ${startTripData.stationId}");
      print("   Personal: $personal");

      final String? authToken = localStorage.getToken();
      if (authToken == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      // Create Dio instance
      final dio = Dio();

      // Configure request
      final response = await dio.post(
        '${ApiConstants.baseUrl}/${ApiConstants.tripsStart}',
        data: startTripData.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'X-Karma-App': 'dafjcnalnsjn',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            // Accept both success and 400 status codes
            return status != null && (status < 300 || status == 400);
          },
        ),
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        // Success - new trip started
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true) {
          tripId.value = responseData['id']?.toString() ??
              responseData['data']?['id']?.toString() ??
              responseData['data']?['trip_id']?.toString() ??
              '';
          print("✅ New trip started successfully. Trip ID: ${tripId.value}");
          return true;
        } else {
          errorMessage.value =
              responseData['message'] ?? 'Failed to start trip';
          return false;
        }
      } else if (response.statusCode == 400) {
        // Handle "already have active trip" scenario
        final responseData = response.data as Map<String, dynamic>;
        final message = responseData['message'] ?? '';

        print("⚠️ Got 400 response: $message");

        if (message.toLowerCase().contains('already have an active trip') ||
            message.toLowerCase().contains('active trip')) {
          print("🔄 Active trip detected, will fetch active trip data...");
          // Return a special indicator that we need to handle active trip
          errorMessage.value = 'ACTIVE_TRIP_EXISTS';
          return false;
        } else {
          errorMessage.value = message;
          return false;
        }
      } else {
        errorMessage.value = 'Unexpected response: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      print("❌ Exception in startTrip: $e");
      
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final responseData = e.response?.data as Map<String, dynamic>?;
          final message = responseData?['message'] ?? '';

          if (message.toLowerCase().contains('already have an active trip') ||
              message.toLowerCase().contains('active trip')) {
            print(
                "🔄 Active trip detected in exception, will fetch active trip data...");
            errorMessage.value = 'ACTIVE_TRIP_EXISTS';
            return false;
          }
        }
        errorMessage.value = 'Network error: ${e.message}';
      } else {
        errorMessage.value = 'Error starting trip: $e';
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<ActiveTripResponse?> fetchActiveTrip() async {
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
              distanceKm:
                  (data['longest_ride']?['distance_km'] ?? 0).toDouble(),
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
              body: requestBody);

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
        // dummyData: () {
        //   final dummyData = DummyDataService.getEndTripResponse("");

        //   if (dummyData['success']) {
        //     endTripDetails.value = EndTripModel.fromJson(dummyData);

        //     Toast.show(
        //       message: "Trip Ended!",
        //       type: ToastType.success,
        //     );
        //     saveTripsDataToLocalStorage();

        //     return true;
        //   }
        //   return false;
        // },
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
        // dummyData: () {
        //   final dummyData = DummyDataService.getTripsResponse();
        //   final tripsResponse = TripsResponse.fromJson(dummyData);
        //   trips.assignAll(tripsResponse.data);
        //   saveTripsDataToLocalStorage();

        //   return true;
        // },
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
        // dummyData: () {
        //   final dummyData = DummyDataService.getTripLocationsResponse();
        //   final locationsResponse = TripLocationsResponse.fromJson(dummyData);
        //   tripLocations.assignAll(locationsResponse.data);
        //   //saveTripLocationsToLocalStorage(tripId);

        //   return true;
        // },
      );
    } catch (e) {
      handleError(e);
      // loadTripLocationsFromLocalStorage(tripId);
    } finally {
      isLoading.value = false;
    }
  }

  // 🔧 UPDATED METHOD WITH PROPER ERROR HANDLING
  Future<bool> updateTripLocation({
    required String tripId,
    required double lat,
    required double long,
    required double elevation,
  }) async {
    try {
      // Don't set isLoading for location updates to avoid UI issues
      errorMessage.value = '';
      isLocationUpdated.value = false;

      final result = await useApiOrDummy(
        apiCall: () async {
          final String? authToken = localStorage.getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.put(
            endpoint: 'trips/$tripId/location',
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
            print('✅ Location updated successfully');
            return true;
          } else {
            print('⚠️ Failed to update location: ${response?['message']}');
            return false;
          }
        },
        // dummyData: () {
        //   final dummyData = DummyDataService.putTripLocationResponse();
        //   if (dummyData['success']) {
        //     final data = dummyData['data'];
        //     _updateTripMetrics(data);
        //     isLocationUpdated.value = true;
        //     tripLocations.add(TripLocation(latitude: lat, longitude: long));
        //     saveTripMetricsToLocalStorage();
        //     print('✅ Location updated successfully (dummy data)');
        //     return true;
        //   }
        //   return false;
        // },
      );

      return result;
    } catch (e) {
      print('❌ Error updating trip location: $e');

      // Handle specific error cases
      if (e.toString().contains('Trip is not active') ||
          e.toString().contains('Cannot update location') ||
          e.toString().contains('400')) {
        print('🛑 Trip is not active, cannot update location');

        // Notify BikeMetricsController to stop tracking
        if (Get.isRegistered<BikeMetricsController>()) {
          try {
            final metricsController = Get.find<BikeMetricsController>();
            print('🛑 Stopping location tracking due to inactive trip');
            metricsController.stopTracking();
          } catch (controllerError) {
            print(
                '⚠️ Could not access BikeMetricsController: $controllerError');
          }
        }

        // Don't treat this as a general error since it's expected when trip ends
        return false;
      } else {
        // For other errors, handle normally
        handleError(e);
        return false;
      }
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
