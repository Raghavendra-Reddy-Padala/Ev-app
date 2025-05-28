import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'dart:convert';
import '../../../core/api/base/base_controller.dart';
import '../../../core/storage/local_storage.dart';
import '../../../main.dart';
import '../../../shared/models/bike/bike_model.dart';
import '../../../shared/services/dummy_data_service.dart';

class BikeController extends BaseController {
  final RxList<Bike> bikes = <Bike>[].obs;
  final Rx<Bike?> bikeData = Rx<Bike?>(null);
  final LocalStorage localStorage = Get.find<LocalStorage>();
  Future<void> fetchBikesByStationId(String stationId) async {
    String? authToken = localStorage.getToken();
    if (authToken == null) {
      print('Auth token is null');
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      try {
        final response = await apiService.get(
          endpoint: '${ApiConstants.bikesByStation}/$stationId',
          headers: {
            'Authorization': 'Bearer $authToken',
            'X-Karma-App': 'dafjcnalnsjn',
          },
        );

        print('Raw response: $response');
        print('Response type: ${response.runtimeType}');

        Map<String, dynamic> responseData;

        if (response is Map<String, dynamic>) {
          responseData = response;
        } else if (response.runtimeType.toString().contains('Response')) {
          if (response.statusCode == 200) {
            responseData = response.data is Map<String, dynamic>
                ? response.data
                : response.data;
          } else {
            errorMessage.value = 'HTTP Error: ${response.statusCode}';
            bikes.value = [];
            return;
          }
        } else {
          throw Exception('Unknown response type: ${response.runtimeType}');
        }

        print('Processing response data: $responseData');

        final BikeResponseModel bikeResponse =
            BikeResponseModel.fromMap(responseData);

        if (bikeResponse.success) {
          bikes.value = bikeResponse.data;
          print('Successfully loaded ${bikes.value.length} bikes');

          if (bikes.value.isNotEmpty) {
            final firstBike = bikes.value.first;
            print('First bike: ${firstBike.name} - ${firstBike.id}');
          }
        } else {
          errorMessage.value = bikeResponse.message.isNotEmpty
              ? bikeResponse.message
              : 'Failed to fetch bikes';
          bikes.value = [];
          print(
              'API returned success: false, message: ${bikeResponse.message}');
        }
      } catch (dioError) {
        if (dioError.toString().contains('404')) {
          print('404 - No bikes found at station');
          bikes.value = [];
          errorMessage.value = '';

          try {
            if (dioError != null) {
              final errorData = dioError;
              if (errorData is Map<String, dynamic>) {
                final message = errorData['message'] ?? '';
                if (message.toLowerCase().contains('bike not found') ||
                    message.toLowerCase().contains('no bikes')) {
                  print('Confirmed: No bikes available at this station');
                  return;
                }
              }
            }
          } catch (parseError) {
            print('Could not parse 404 response: $parseError');
          }
        } else {
          throw dioError;
        }
      }
    } catch (e) {
      AppLogger.e('Error fetching bikes: $e');
      print('Stack trace: ${StackTrace.current}');
      errorMessage.value = 'Error fetching bikes: $e';
      bikes.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBikesData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final response = await apiService.get(
            endpoint: '${ApiConstants.getBikes}?page=1&limit=10',
            headers: {
              'Authorization':
                  'Bearer ${localStorage.getString("authToken") ?? ""}',
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );
          if (response != null) {
            final BikeResponseModel bikeResponse =
                BikeResponseModel.fromMap(response.data);
            bikes.assignAll(bikeResponse.data);
            await saveToLocalStorage(bikeResponse.data);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getBikesResponse('123');
          final bikeResponse = BikeResponseModel.fromMap(dummyData);
          bikes.assignAll(bikeResponse.data);
          saveToLocalStorage(bikeResponse.data);
          return true;
        },
      );
    } catch (e) {
      print('Error fetching bikes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBikeData(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final response = await apiService.get(
            endpoint: '${ApiConstants.bikesById}/$id',
            headers: {
              'Authorization': 'Bearer ${localStorage.getToken()}',
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );
          if (response != null) {
            final bike = Bike.fromJson(response.data['data']);
            bikeData.value = bike;
            await saveToLocalStorage(bike);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getBikeData(id);
          final bike = Bike.fromJson(dummyData['data']);
          bikeData.value = bike;
          saveToLocalStorage(bike);
          return true;
        },
      );
    } catch (e) {
      print('Error fetching bike data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveToLocalStorage(dynamic bikeData) async {
    try {
      if (bikeData is List<Bike>) {
        final List<Map<String, dynamic>> bikesList =
            bikeData.map((bike) => bike.toJson()).toList();
        localStorage.setString('bikesData', json.encode(bikesList));
      } else if (bikeData is Bike) {
        localStorage.setString('bikeData', json.encode(bikeData.toJson()));
      }
    } catch (e) {
      print('Error saving to localStorage: $e');
    }
  }

  Future<void> loadBikeData() async {
    try {
      final bikeDataString = localStorage.getString('bikeData');
      if (bikeDataString != null && bikeDataString.isNotEmpty) {
        final bikeJson = json.decode(bikeDataString);
        bikeData.value = Bike.fromJson(bikeJson);
      }
    } catch (e) {
      print('Error loading bike data: $e');
    }
  }

  Future<void> loadBikesData() async {
    try {
      final bikesDataString = localStorage.getString('bikesData');
      if (bikesDataString != null && bikesDataString.isNotEmpty) {
        final List<dynamic> bikesJson = json.decode(bikesDataString);
        final List<Bike> loadedBikes =
            bikesJson.map((json) => Bike.fromJson(json)).toList();
        bikes.assignAll(loadedBikes);
      }
    } catch (e) {
      print('Error loading bikes data: $e');
    }
  }
}
