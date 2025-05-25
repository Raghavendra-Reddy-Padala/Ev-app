import 'package:get/get.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/storage/local_storage.dart';
import '../../../shared/models/trips/trips_model.dart';
import '../../account/controllers/trips_controller.dart';
import '../controller/bike_metrics_controller.dart';

class TripControlService extends BaseController {
  final BikeMetricsController bikeMetricsController = Get.find();
  final TripsController tripsController = Get.find();
  final LocalStorage localStorage = Get.find();

  final RxString currentTripId = ''.obs;
  final RxBool isEndTripSliderVisible = false.obs;

  Future<bool> startTrip(StartTrip startTripData) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final success = await tripsController.startTrip(startTripData);

      if (success) {
        currentTripId.value = tripsController.tripId.value;

        await bikeMetricsController.startTracking();

        bikeMetricsController.bikeSubscribed.value = true;
        bikeMetricsController.bikeID.value = startTripData.bikeId;

        await localStorage.setBool('bikeSubscribed', true);
        await localStorage.setString('bikeCode', startTripData.bikeId);
        await localStorage.setString('tripId', currentTripId.value);

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
      errorMessage.value = '';

      if (currentTripId.value.isEmpty) {
        currentTripId.value = tripsController.tripId.value;

        if (currentTripId.value.isEmpty) {
          handleError('No active trip found');
          return false;
        }
      }

      final endTripData = _prepareEndTripData();
      final success =
          await tripsController.dataSend(endTripData, currentTripId.value);

      if (success) {
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
    bikeMetricsController.stopTracking();

    bikeMetricsController.saveTripSummary();
    bikeMetricsController.bikeSubscribed.value = false;
    bikeMetricsController.bikeID.value = "";

    await localStorage.remove('locations');
    await localStorage.setBool('bikeSubscribed', false);
    await localStorage.setString('bikeCode', "");
    await localStorage.setString('encodedId', '');
    await localStorage.setString('deviceId', "");
    await localStorage.setInt('time', 0);
    await localStorage.setString('tripId', '');

    bikeMetricsController.resetTripData();

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

  void initializeFromStorage() {
    final storedTripId = localStorage.getString('tripId');
    if (storedTripId != null && storedTripId.isNotEmpty) {
      currentTripId.value = storedTripId;
    }
  }

  bool get hasActiveTrip => currentTripId.value.isNotEmpty;
}
