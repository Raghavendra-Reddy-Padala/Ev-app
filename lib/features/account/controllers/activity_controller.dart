import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../main.dart';
import '../../../shared/models/trips/trips_model.dart';
import '../../../shared/services/dummy_data_service.dart';
import '../../authentication/views/auth_view.dart';

class ActivityController extends BaseController {
  // Observable properties
  var data = <int, double>{}.obs;
  var xLabels = <int, String>{}.obs;
  var selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  ).obs;

  final Rx<TripSummaryModel?> tripSummary = Rx<TripSummaryModel?>(null);
  final LocalStorage localStorage = Get.find<LocalStorage>();

  // Additional metrics
  double? totalDistance;

  @override
  void onInit() {
    super.onInit();
    loadCachedData();
    fetchTripSummary();
  }

  Future<void> fetchTripSummary() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = localStorage.getToken();
          if (authToken == null) {
            NavigationService.pushReplacementTo(const AuthView());
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: 'trips/summary',
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn',
            },
          );

          if (response != null) {
            print("TRIP SUMMARY => ${response}");

            // Check if response is successful
            if (response['success'] == true && response['data'] != null) {
              try {
                tripSummary.value = TripSummaryModel.fromJson(response['data']);
                generateGraphData();
                saveCachedData();
                return true;
              } catch (parseError) {
                print("Error parsing trip summary: $parseError");
                errorMessage.value = 'Failed to parse trip data';
                return false;
              }
            } else {
              // Fix: Access message directly from response, not response.data
              errorMessage.value =
                  response['message'] ?? 'Failed to load trip summary';
              return false;
            }
          } else {
            errorMessage.value =
                'Failed to fetch trip summary. Please try again.';
            return false;
          }
        },
        // dummyData: () {
        //   final dummyData = DummyDataService.getTripSummaryResponse();
        //   if (dummyData != null && dummyData['data'] != null) {
        //     tripSummary.value = TripSummaryModel.fromJson(dummyData['data']);
        //     generateGraphData();
        //     saveCachedData();
        //   }
        //   return true;
        // },
      );
    } catch (e) {
      print("Error in fetchTripSummary: $e");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void generateGraphData() {
    if (tripSummary.value == null) return;

    final Map<int, double> generatedData = {};
    final Map<int, String> generatedXLabels = {};
    final double avgDistance = tripSummary.value!.averages.distanceKm;
    final int days = selectedDateRange.value.end
        .difference(selectedDateRange.value.start)
        .inDays;

    for (int i = 0; i <= days; i++) {
      double dailyValue = avgDistance * (0.7 + (i % 3) * 0.2);
      generatedData[i] = dailyValue;
      DateTime day = selectedDateRange.value.start.add(Duration(days: i));
      generatedXLabels[i] = DateFormat('d MMM').format(day);
    }
    data.value = generatedData;
    xLabels.value = generatedXLabels;
  }

  void setDateRange(DateTimeRange range) {
    selectedDateRange.value = range;
    generateGraphData();
    saveCachedData();
  }

  Future<void> refreshActivity() async {
    await fetchTripSummary();
  }

  void saveCachedData() {
    try {
      if (tripSummary.value != null) {
        localStorage.setString(
            'cached_trip_summary', jsonEncode(tripSummary.value!.toJson()));
        localStorage.setString('cached_date_range_start',
            selectedDateRange.value.start.toIso8601String());
        localStorage.setString('cached_date_range_end',
            selectedDateRange.value.end.toIso8601String());
      }
    } catch (e) {
      print("Error saving cached activity data: $e");
    }
  }

  void loadCachedData() {
    try {
      final String? cachedSummary =
          localStorage.getString('cached_trip_summary');
      final String? cachedStartDate =
          localStorage.getString('cached_date_range_start');
      final String? cachedEndDate =
          localStorage.getString('cached_date_range_end');

      if (cachedSummary != null) {
        try {
          final Map<String, dynamic> summaryJson = jsonDecode(cachedSummary);
          tripSummary.value = TripSummaryModel.fromJson(summaryJson);
        } catch (e) {
          print("Error parsing cached trip summary: $e");
        }
      }

      if (cachedStartDate != null && cachedEndDate != null) {
        selectedDateRange.value = DateTimeRange(
          start: DateTime.parse(cachedStartDate),
          end: DateTime.parse(cachedEndDate),
        );
      }

      if (tripSummary.value != null) {
        generateGraphData();
      }
    } catch (e) {
      print("Error loading cached activity data: $e");
    }
  }

  String formatTime(double hours) {
    final int totalHours = hours.floor();
    final int totalMinutes = ((hours - totalHours) * 60).floor();
    final int totalSeconds =
        ((((hours - totalHours) * 60) - totalMinutes) * 60).floor();
    return "${totalHours.toString().padLeft(2, '0')}:${totalMinutes.toString().padLeft(2, '0')}:${totalSeconds.toString().padLeft(2, '0')}";
  }
}
