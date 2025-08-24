import 'dart:convert';
import 'package:get/get.dart';
import 'package:mjollnir/main.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';

class IndividualUserTripsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Trip> userTrips = <Trip>[].obs;
  final RxString errorMessage = ''.obs;
  final LocalStorage localStorage = Get.find<LocalStorage>();

  Future<void> fetchUserTrips(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      userTrips.clear();

      final response = await apiService.get(
        endpoint: 'trips/user/$userId',
        headers: {
          'Authorization': 'Bearer ${localStorage.getToken()}',
          'X-Karma-App': 'dafjcnalnsjn'
        },
      );

      print('Trips Response: $response');

      Map<String, dynamic> responseData;
      if (response is Map) {
        responseData = Map<String, dynamic>.from(response);
      } else if (response is String) {
        responseData = jsonDecode(response);
      } else {
        throw Exception('Invalid response format');
      }

      if (responseData['success'] == true) {
        if (responseData['data'] != null && responseData['data'] is List) {
          final List<dynamic> tripsData = responseData['data'];
          userTrips.value = tripsData.map((tripJson) => _parseTrip(tripJson)).toList();
        } else {
          // Data is null - no trips found
          userTrips.clear();
        }
      } else {
        errorMessage.value = responseData['message'] ?? 'Failed to fetch trips';
      }
    } catch (e) {
      print('Error fetching user trips: $e');
      errorMessage.value = 'Failed to load trips. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Trip _parseTrip(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      bikeId: json['bike_id'] ?? '',
      stationId: json['station_id'] ?? '',
      startTimestamp: _parseDateTime(json['start_timestamp']),
      endTimestamp: _parseDateTime(json['end_timestamp']),
      distance: _parseDouble(json['distance']),
      duration: _parseDouble(json['duration']),
      averageSpeed: _parseDouble(json['average_speed']),
      maxElevation: _parseInt(json['max_elevation']),
      kcal: _parseDouble(json['kcal']),
      path: _parsePathPoints(json['path']),
    );
  }

  List<PathPoint> _parsePathPoints(dynamic pathData) {
    if (pathData == null || pathData is! List) return [];
    
    return pathData.map((pointJson) {
      return PathPoint(
        lat: _parseDouble(pointJson['lat']),
        long: _parseDouble(pointJson['long']),
        timestamp: _parseDateTime(pointJson['timestamp']),
        elevation: _parseDouble(pointJson['elevation']),
      );
    }).toList();
  }

  DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null || dateTime == "0001-01-01T00:00:00Z") return null;
    try {
      return DateTime.parse(dateTime.toString());
    } catch (e) {
      return null;
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  void refreshTrips(String userId) {
    fetchUserTrips(userId);
  }

  bool get hasTrips => userTrips.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;
}