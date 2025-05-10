import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';
import '../../../shared/models/trips/trips_model.dart';
import '../../../shared/services/dummy_data_service.dart';

class ActivityController extends GetxController {
  var data = <int, double>{}.obs;
  var xLabels = <int, String>{}.obs;
  var selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  ).obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  double? totalDistance;
  final Rx<TripSummaryModel?> tripSummary = Rx<TripSummaryModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchTripSummary();
  }

  Future<void> fetchTripSummary() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.post(
            endpoint: '',
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          );

          if (response.statusCode == 200) {
            print("TRIP SUMMARY => ${response.data}");
            if (response.data['success'] == true &&
                response.data['data'] != null) {
              tripSummary.value =
                  TripSummaryModel.fromJson(response.data['data']);
              generateGraphData();
              return true;
            } else {
              errorMessage.value =
                  response.data['message'] ?? 'Failed to load trip summary';
              return false;
            }
          } else if (response.statusCode == 401) {
            return false;
          } else {
            errorMessage.value =
                'Failed to fetch trip summary. Please try again.';
            return false;
          }
        },
        dummyData: () {
          final dummyData = DummyDataService.getTripSummaryResponse();
          if (dummyData != null && dummyData['data'] != null) {
            tripSummary.value = TripSummaryModel.fromJson(dummyData['data']);
            generateGraphData();
          }
          return true;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      print(e);
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
  }

  Future<String?> getToken() async {
    // Implement your token retrieval logic here
    // For example:
    // return await StorageService.getAuthToken();
    return null; // Replace with actual implementation
  }
}
