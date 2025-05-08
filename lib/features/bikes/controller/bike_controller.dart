import 'package:get/get.dart';

import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';
import '../../../shared/models/bike/bike_model.dart';
import '../../../shared/services/ummy_data_service.dart';

class BikeController extends BaseController {
  final RxList<Bike> bikes = <Bike>[].obs;

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
}
