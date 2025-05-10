import 'package:get/get.dart';
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

  Future<void> fetchBikesByStationId(String stationId, String authToken) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bikes.clear();
      await useApiOrDummy(
        apiCall: () async {
          final response = await apiService.get(
            endpoint: '/v1/bikes/get/station/$stationId',
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          );
          if (response != null) {
            final bikeResponse = BikesResponseModel.fromMap(response.data);
            bikes.assignAll(bikeResponse.data);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getBikesResponse(stationId);
          final bikeResponse = BikesResponseModel.fromMap(dummyData);
          bikes.assignAll(bikeResponse.data);
          return true;
        },
      );
    } catch (e) {
      print('Error fetching bikes: $e');
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
            endpoint: '/v1/bikes/get',
            headers: {
              'Authorization':
                  'Bearer ${localStorage.getString("authToken") ?? ""}',
            },
          );
          if (response != null) {
            final bikeResponse = BikesResponseModel.fromMap(response.data);
            bikes.assignAll(bikeResponse.data);
            await saveToLocalStorage(bikeResponse.data);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getBikesResponse('123');
          final bikeResponse = BikesResponseModel.fromMap(dummyData);
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
            endpoint: '/v1/bikes/get/$id',
            headers: {
              'Authorization':
                  'Bearer ${localStorage.getString("authToken") ?? ""}',
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
