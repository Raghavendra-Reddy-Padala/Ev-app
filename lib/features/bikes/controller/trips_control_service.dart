import 'package:get/get.dart';
import '../../../../core/api/base/base_controller.dart';
import '../../../../core/storage/local_storage.dart';

import '../../../shared/models/trips/trips_model.dart';
import '../../account/controllers/trips_controller.dart';
import 'bike_metrics_controller.dart';

class TripControlService extends BaseController {
  final BikeMetricsController bikeMetricsController = Get.find();
  final TripsController tripsController = Get.find();
  final LocalStorage localStorage = Get.find();

  final RxString currentTripId = ''.obs;
  final RxBool isEndTripSliderVisible = false.obs;

  Future<bool> startTrip(StartTrip startTripData) async {
    try {
      isLoading.value = true;

      final response = await tripsController.startTrip(startTripData);

      if (response != null && response.success) {
        currentTripId.value = response.data?.id ?? '';
        await bikeMetricsController.startTracking();

        // Update bike subscription status
        bikeMetricsController.bikeSubscribed.value = true;
        bikeMetricsController.bikeID.value = startTripData.bikeId;

        await localStorage.setBikeSubscribed(true);
        await localStorage.setString('bikeCode', startTripData.bikeId);

        return true;
      }

      return false;
    } catch (e) {
      handleError('Failed to start trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> endTrip() async {
    try {
      isLoading.value = true;

      if (currentTripId.value.isEmpty) {
        handleError('No active trip found');
        return false;
      }
      final endTripData = _prepareEndTripData();

      final response =
          await tripsController.endTrip(endTripData, currentTripId.value);

      if (response != null && response.success) {
        await _cleanupAfterTripEnd();
        return true;
      }

      return false;
    } catch (e) {
      handleError('Failed to end trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  EndTrip _prepareEndTripData() {
    final metrics = bikeMetricsController.getCurrentMetrics();
    final locations = localStorage.getLocationList();
    final duration = Duration(seconds: metrics.duration.toInt());

    return EndTrip(
      id: currentTripId.value,
      bikeId: bikeMetricsController.bikeID.value,
      stationId: "0",
      startTimestamp: DateTime.now().subtract(duration),
      endTimestamp: DateTime.now(),
      distance: metrics.distance,
      duration: metrics.duration,
      averageSpeed: metrics.speed,
      path: locations,
    );
  }

  Future<void> _cleanupAfterTripEnd() async {
    // Stop tracking
    bikeMetricsController.stopTracking();

    // Save trip summary
    bikeMetricsController.saveTripSummary();

    // Update bike subscription status
    bikeMetricsController.bikeSubscribed.value = false;
    bikeMetricsController.bikeID.value = "";

    // Clear local storage
    await localStorage.remove('locations');
    await localStorage.setBikeSubscribed(false);
    await localStorage.setString('bikeCode', "");
    await localStorage.setString('encodedId', '');
    await localStorage.setString('deviceId', "");
    await localStorage.setTime(0);

    // Reset trip data
    bikeMetricsController.resetTripData();

    // Clear current trip
    currentTripId.value = '';
    isEndTripSliderVisible.value = false;
  }

  void pauseTrip() {
    bikeMetricsController.pauseTracking();
  }

  void resumeTrip() {
    bikeMetricsController.resumeTracking();
  }

  void showEndTripSlider() {
    isEndTripSliderVisible.value = true;
  }

  void hideEndTripSlider() {
    isEndTripSliderVisible.value = false;
  }
}
