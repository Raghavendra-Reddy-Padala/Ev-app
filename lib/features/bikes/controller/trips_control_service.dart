import 'package:get/get.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/storage/local_storage.dart';
import '../../../shared/components/bike/ride_summary.dart';
import '../../../shared/models/trips/active_trip_model.dart';
import '../../../shared/models/trips/trips_model.dart';
import '../../account/controllers/trips_controller.dart';
import '../../main_page_controller.dart';
import '../controller/bike_metrics_controller.dart';

class TripControlService extends BaseController {
  final BikeMetricsController bikeMetricsController = Get.find();
  final TripsController tripsController = Get.find();
  final LocalStorage localStorage = Get.find();

  final RxString currentTripId = ''.obs;
  final RxBool isEndTripSliderVisible = false.obs;

  Future<bool> startTrip(StartTrip startTripData,
      {required bool personal}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print("🚀 TripControlService: Starting trip...");
      print("   Bike ID: ${startTripData.bikeId}");
      print("   Station ID: ${startTripData.stationId}");
      print("   Personal: $personal");

      // First check if there's already an active trip
      print("🔍 Checking for existing active trip...");
      final activeTrip = await tripsController.fetchActiveTrip();

      if (activeTrip != null) {
        print("✅ Found existing active trip: ${activeTrip.id}");
        // User already has an active trip - continue it
        tripsController.tripId.value = activeTrip.id;
        tripsController.activeTripData.value = activeTrip;
        currentTripId.value = activeTrip.id;

        await _continueExistingTrip(activeTrip);

        // Set bike subscription status
        bikeMetricsController.bikeSubscribed.value = true;
        bikeMetricsController.bikeID.value = startTripData.bikeId;

        await localStorage.setBool('bikeSubscribed', true);
        await localStorage.setString('bikeCode', startTripData.bikeId);
        await localStorage.setString('tripId', currentTripId.value);

        return true;
      } else {
        print("🆕 No existing trip found, starting fresh trip...");

        // Reset all metrics before starting new trip
        await _resetMetricsForNewTrip();

        // Start new trip
        final success =
            await tripsController.startTrip(startTripData, personal: personal);

        if (success) {
          currentTripId.value = tripsController.tripId.value;
          print(
              "✅ New trip started successfully. Trip ID: ${currentTripId.value}");

          // Set bike subscription status
          bikeMetricsController.bikeSubscribed.value = true;
          bikeMetricsController.bikeID.value = startTripData.bikeId;

          // Persist trip data
          await localStorage.setBool('bikeSubscribed', true);
          await localStorage.setString('bikeCode', startTripData.bikeId);
          await localStorage.setString('tripId', currentTripId.value);

          // Start fresh tracking
          await bikeMetricsController.startTracking();

          return true;
        } else {
          print(
              "❌ Failed to start trip: ${tripsController.errorMessage.value}");
          errorMessage.value = tripsController.errorMessage.value;
          return false;
        }
      }
    } catch (e) {
      print("❌ Exception in startTrip: $e");
      handleError('Failed to start trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _resetMetricsForNewTrip() async {
    print("🔄 Resetting metrics for new trip...");

    // Reset all bike metrics
    bikeMetricsController.totalDistance.value = 0.0;
    bikeMetricsController.totalDuration.value = 0.0;
    bikeMetricsController.currentSpeed.value = 0.0;
    bikeMetricsController.calculatedCalories.value = 0.0;
    bikeMetricsController.maxElevation.value = 0.0;
    bikeMetricsController.lastTripCalories.value = 0.0;

    // Clear path data
    bikeMetricsController.pathPoints.clear();
    bikeMetricsController.startLocationName.value = '';
    bikeMetricsController.endLocationName.value = '';

    // Reset storage
    await localStorage.setDouble("totalDistance", 0.0);
    await localStorage.setDouble("currentSpeed", 0.0);
    await localStorage.setDouble("calories", 0.0);
    await localStorage.setDouble("maxElevation", 0.0);
    await localStorage.setTime(0);
    await localStorage.saveLocationList([]);
    await localStorage.savePathPoints([]);

    print("✅ Metrics reset completed");
  }

  Future<void> _continueExistingTrip(ActiveTripResponse activeTrip) async {
    print("📊 Loading existing trip metrics:");
    print("   Distance: ${activeTrip.distanceKm} km");
    print("   Speed: ${activeTrip.speedKmh} km/h");
    print("   Calories: ${activeTrip.caloriesTrip} kcal");
    print("   Duration: ${activeTrip.totalTimeHours} hours");
    print("   Max Elevation: ${activeTrip.maxElevationM} m");
    bikeMetricsController.totalDistance.value = activeTrip.distanceKm;
    bikeMetricsController.currentSpeed.value = activeTrip.speedKmh;
    bikeMetricsController.calculatedCalories.value = activeTrip.caloriesTrip;
    bikeMetricsController.maxElevation.value = activeTrip.maxElevationM;
    bikeMetricsController.totalDuration.value =
        activeTrip.totalTimeHours * 3600;

    // Save to local storage
    localStorage.setDouble("totalDistance", activeTrip.distanceKm);
    localStorage.setDouble("currentSpeed", activeTrip.speedKmh);
    localStorage.setDouble("calories", activeTrip.caloriesTrip);
    localStorage.setDouble("maxElevation", activeTrip.maxElevationM);
    localStorage.setTime((activeTrip.totalTimeHours * 3600).toInt());
    bikeMetricsController.totalDistance.refresh();
    bikeMetricsController.currentSpeed.refresh();
    bikeMetricsController.calculatedCalories.refresh();
    bikeMetricsController.maxElevation.refresh();
    bikeMetricsController.totalDuration.refresh();
    await bikeMetricsController.startTracking();

    print("✅ Successfully loaded existing trip data");
  }

  Future<bool> endTrip() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('🏁 ========== ENDING TRIP ==========');
      bikeMetricsController.printTripSummary();
      String? workingTripId = _getWorkingTripId();

      if (workingTripId == null || workingTripId.isEmpty) {
        Get.to(() => RideSummary());
        print('❌ CRITICAL ERROR - No trip ID found!');
        handleError('No active trip found');
        return false;
      }
      print('🎯 Final working trip ID: "$workingTripId"');
      bikeMetricsController.saveTripSummary();
      final endTripData = _prepareEndTripData();

      print('📡 Calling tripsController.dataSend(true)...');
      final success = await tripsController.dataSend(true);
      print('📊 dataSend result: $success');

      if (success) {
        print('✅ Trip ended successfully via API');
        //await _tryStopDevice();
        await _showTripSummaryAndCleanup(endTripData);

        return true;
      } else {
        print('❌ dataSend returned false');
        handleError(
            'Trip end API call failed: ${tripsController.errorMessage.value}');
        return false;
      }
    } catch (e) {
      print('❌ Exception in endTrip: $e');
      handleError('Failed to end trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String? _getWorkingTripId() {
    if (currentTripId.value.isNotEmpty) {
      return currentTripId.value;
    } else if (tripsController.tripId.value.isNotEmpty) {
      return tripsController.tripId.value;
    } else {
      final storedTripId = localStorage.getString('tripId');
      if (storedTripId != null && storedTripId.isNotEmpty) {
        return storedTripId;
      }
    }
    return null;
  }

  EndTrip _prepareEndTripData() {
    final pathPoints = localStorage.getPathPoints();
    final locationList = localStorage.getLocationList();

    // Get all metrics from SharedPreferences and controller
    final totalDistance = localStorage.getDouble("totalDistance") ??
        bikeMetricsController.totalDistance.value;
    final totalDuration = localStorage.getTime().toDouble();
    final currentSpeed = localStorage.getDouble("currentSpeed") ??
        bikeMetricsController.currentSpeed.value;
    final calories = localStorage.getDouble("calories") ??
        bikeMetricsController.calculatedCalories.value;
    final maxElevation = localStorage.getDouble("maxElevation") ??
        bikeMetricsController.maxElevation.value;
    final bikeId = localStorage.getString("bikeCode") ??
        bikeMetricsController.bikeID.value;
    final tripId = localStorage.getString("tripId") ?? currentTripId.value;

    final endTimestamp = DateTime.now();
    final startTimestamp =
        endTimestamp.subtract(Duration(seconds: totalDuration.toInt()));
    final startLocationName = bikeMetricsController.startLocationName.value;
    final endLocationName = bikeMetricsController.endLocationName.value;

    return EndTrip(
      path: pathPoints,
      stationId: '',
      id: tripId,
      bikeId: bikeId,
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp,
      distance: totalDistance,
      duration: totalDuration,
      averageSpeed: bikeMetricsController.avgSpeed.value,
      // maxSpeed: currentSpeed,
      // totalCalories: calories,
      // maxElevation: maxElevation,
      // pathPoints: pathPoints,
      // locationList: locationList,
      // startLocationName: startLocationName,
      // endLocationName: endLocationName,
      // speedHistory: localStorage.getDoubleList("speedHistory"),
      // durationHistory: localStorage.getDoubleList("durationHistory"),
      // calorieHistory: localStorage.getDoubleList("calorieHistory"),
    );
  }

  Future<void> _showTripSummaryAndCleanup(EndTrip endTripData) async {
    try {
      print('🎯 Showing trip summary...');
      await Future.delayed(Duration(milliseconds: 500));
      await Get.to(
        () => RideSummary(tripData: endTripData),
        transition: Transition.rightToLeft,
        duration: Duration(milliseconds: 300),
      );
      await _cleanupAfterTripEnd();
    } catch (e) {
      print('❌ Error showing trip summary: $e');
      await _cleanupAfterTripEnd();
    }
  }

  Future<void> _cleanupAfterTripEnd() async {
    print('🧹 Starting trip cleanup...');
    bikeMetricsController.stopTracking();
    bikeMetricsController.saveTripSummary();
    bikeMetricsController.bikeSubscribed.value = false;
    bikeMetricsController.bikeID.value = "";

    await localStorage.remove('locations');
    await localStorage.setBool('bikeSubscribed', false);
    await localStorage.setBool('bike_subscribed', false);
    await localStorage.setString('bikeCode', "");
    await localStorage.setString('encodedId', '');
    await localStorage.setString('deviceId', "");
    await localStorage.setInt('time', 0);
    await localStorage.setString('tripId', '');

    bikeMetricsController.resetTripData();
    currentTripId.value = '';
    isEndTripSliderVisible.value = false;
    try {
      final MainPageController mainPageController =
          Get.find<MainPageController>();
      await mainPageController.handleTripEnded();
      print('✅ MainPageController updated after trip end');
    } catch (e) {
      print('⚠️ Could not update MainPageController: $e');
    }

    print('✅ Cleanup completed successfully');
  }

  void pauseTrip() {
    print('⏸️ Pausing trip...');
    bikeMetricsController.pauseTracking();
  }

  void resumeTrip() {
    print('▶️ Resuming trip...');
    bikeMetricsController.resumeTracking();
  }

  void showEndTripSlider() {
    print('🛑 Showing end trip slider...');
    isEndTripSliderVisible.value = true;
  }

  void hideEndTripSlider() {
    print('❌ Hiding end trip slider...');
    isEndTripSliderVisible.value = false;
  }

  void initializeFromStorage() {
    final storedTripId = localStorage.getString('tripId');
    if (storedTripId != null && storedTripId.isNotEmpty) {
      currentTripId.value = storedTripId;
      print('📱 Initialized trip ID from storage: $storedTripId');
    }
  }

  void debugTripStatus() {
    print('🔍 ========== TRIP STATUS DEBUG ==========');
    print('   TripControlService.currentTripId: "${currentTripId.value}"');
    print('   TripControlService.hasActiveTrip: $hasActiveTrip');
    print('   TripsController.tripId: "${tripsController.tripId.value}"');
    print(
        '   BikeMetricsController.bikeID: "${bikeMetricsController.bikeID.value}"');
    print(
        '   BikeMetricsController.bikeSubscribed: ${bikeMetricsController.bikeSubscribed.value}');
    print(
        '   BikeMetricsController.isTracking: ${bikeMetricsController.isTracking.value}');

    final storedTripId = localStorage.getString('tripId');
    final storedBikeCode = localStorage.getString('bikeCode');
    final bikeSubscribed = localStorage.getBool('bikeSubscribed');

    print('   localStorage.tripId: "$storedTripId"');
    print('   localStorage.bikeCode: "$storedBikeCode"');
    print('   localStorage.bikeSubscribed: $bikeSubscribed');
    print('=========================================');
  }

  bool get hasActiveTrip => currentTripId.value.isNotEmpty;
}
