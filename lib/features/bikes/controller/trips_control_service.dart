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
      }

      // No active trip found, start new one
      final success =
          await tripsController.startTrip(startTripData, personal: personal);

      if (success) {
        currentTripId.value = tripsController.tripId.value;
        print("✅ Trip started successfully. Trip ID: ${currentTripId.value}");

        // Set bike subscription status
        bikeMetricsController.bikeSubscribed.value = true;
        bikeMetricsController.bikeID.value = startTripData.bikeId;

        // Persist trip data
        await localStorage.setBool('bikeSubscribed', true);
        await localStorage.setString('bikeCode', startTripData.bikeId);
        await localStorage.setString('tripId', currentTripId.value);

        // Start tracking
        await bikeMetricsController.startTracking();

        return true;
      } else {
        // Check if the error is "ACTIVE_TRIP_EXISTS"
        if (tripsController.errorMessage.value == 'ACTIVE_TRIP_EXISTS') {
          print(
              "🔄 Active trip detected from API, handling existing active trip...");
          return await _handleExistingActiveTrip(startTripData);
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

  Future<bool> startFreshTrip(StartTrip startTripData,
      {required bool personal}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print("🚀 TripControlService: Starting FRESH trip...");
      print("   Bike ID: ${startTripData.bikeId}");
      print("   Station ID: ${startTripData.stationId}");
      print("   Personal: $personal");

      // Reset all metrics before starting new trip
      await _resetMetricsForNewTrip();

      // Start new trip (now uses Dio internally)
      final success =
          await tripsController.startTrip(startTripData, personal: personal);

      if (success) {
        currentTripId.value = tripsController.tripId.value;
        print(
            "✅ Fresh trip started successfully. Trip ID: ${currentTripId.value}");

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
        // Check if the error is "ACTIVE_TRIP_EXISTS"
        if (tripsController.errorMessage.value == 'ACTIVE_TRIP_EXISTS') {
          print("🔄 Active trip detected, handling existing active trip...");
          return await _handleExistingActiveTrip(startTripData);
        } else {
          print(
              "❌ Failed to start fresh trip: ${tripsController.errorMessage.value}");
          errorMessage.value = tripsController.errorMessage.value;
          return false;
        }
      }
    } catch (e) {
      print("❌ Exception in startFreshTrip: $e");
      handleError('Failed to start fresh trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _handleExistingActiveTrip(StartTrip startTripData) async {
    try {
      print("🔍 Fetching existing active trip...");

      // Fetch the active trip data
      final activeTrip = await tripsController.fetchActiveTrip();

      if (activeTrip != null) {
        print("✅ Found existing active trip: ${activeTrip.id}");

        // Use existing trip data
        tripsController.tripId.value = activeTrip.id;
        tripsController.activeTripData.value = activeTrip;
        currentTripId.value = activeTrip.id;

        // Load existing metrics from active trip
        await _loadExistingTripMetrics(activeTrip, startTripData.bikeId);

        // Set bike subscription status with the requested bike ID
        bikeMetricsController.bikeSubscribed.value = true;
        bikeMetricsController.bikeID.value = startTripData.bikeId;

        // Persist trip data
        await localStorage.setBool('bikeSubscribed', true);
        await localStorage.setString('bikeCode', startTripData.bikeId);
        await localStorage.setString('tripId', currentTripId.value);

        // Start/resume tracking
        if (!bikeMetricsController.isTracking.value) {
          await bikeMetricsController.startTracking();
        }

        // Update main page controller
        if (Get.isRegistered<MainPageController>()) {
          final mainController = Get.find<MainPageController>();
          mainController.isBikeSubscribed.value = true;
        }

        print("✅ Successfully resumed existing active trip");
        return true;
      } else {
        print("❌ No active trip found despite error message");
        errorMessage.value = 'Unable to fetch active trip details';
        return false;
      }
    } catch (e) {
      print("❌ Error handling existing active trip: $e");
      errorMessage.value = 'Failed to load active trip: $e';
      return false;
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

  Future<void> _cleanupAfterTripEnd() async {
    print('🧹 Starting comprehensive trip cleanup...');

    // Stop tracking first
    bikeMetricsController.stopTracking();
    bikeMetricsController.saveTripSummary();

    // Reset bike subscription
    bikeMetricsController.bikeSubscribed.value = false;
    bikeMetricsController.bikeID.value = "";

    // Clear all trip-related storage
    await localStorage.remove('locations');
    await localStorage.remove('pathPoints');
    await localStorage.remove('tripId');
    await localStorage.setBool('bikeSubscribed', false);
    await localStorage.setBool('bike_subscribed', false);
    await localStorage.setString('bikeCode', "");
    await localStorage.setString('encodedId', '');
    await localStorage.setString('deviceId', "");
    await localStorage.setString('bike_code', "");
    await localStorage.setString('encoded_id', "");
    await localStorage.setString('device_id', "");
    await localStorage.setInt('time', 0);
    await localStorage.setInt('total_duration', 0);

    // Reset trip metrics to zero
    await localStorage.setDouble('totalDistance', 0.0);
    await localStorage.setDouble('totalDuration', 0.0);
    await localStorage.setDouble('currentSpeed', 0.0);
    await localStorage.setDouble('calories', 0.0);
    await localStorage.setDouble('maxElevation', 0.0);

    // Reset controller state
    bikeMetricsController.resetTripData();

    // Clear trip IDs
    currentTripId.value = '';
    tripsController.tripId.value = '';
    tripsController.activeTripData.value = null;

    // Hide end trip slider
    isEndTripSliderVisible.value = false;

    try {
      final MainPageController mainPageController =
          Get.find<MainPageController>();
      await mainPageController.handleTripEnded();
      mainPageController.isBikeSubscribed.value = false;
      print('✅ MainPageController updated after trip end');
    } catch (e) {
      print('⚠️ Could not update MainPageController: $e');
    }

    print('✅ Comprehensive cleanup completed successfully');
  }

  Future<bool> endTrip() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('🏁 ========== ENDING TRIP ==========');
      bikeMetricsController.printTripSummary();
      String? workingTripId = _getWorkingTripId();

      if (workingTripId == null || workingTripId.isEmpty) {
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

  Future<void> _loadExistingTripMetrics(
      dynamic activeTrip, String bikeId) async {
    print("📊 Loading existing trip metrics:");

    // Extract metrics from active trip response
    double distance = 0.0;
    double speed = 0.0;
    double calories = 0.0;
    double elevation = 0.0;
    double duration = 0.0;

    try {
      // Handle different possible response structures
      if (activeTrip.distanceKm != null) {
        distance = activeTrip.distanceKm.toDouble();
      }
      if (activeTrip.speedKmh != null) {
        speed = activeTrip.speedKmh.toDouble();
      }
      if (activeTrip.caloriesTrip != null) {
        calories = activeTrip.caloriesTrip.toDouble();
      }
      if (activeTrip.maxElevationM != null) {
        elevation = activeTrip.maxElevationM.toDouble();
      }
      if (activeTrip.totalTimeHours != null) {
        duration = activeTrip.totalTimeHours.toDouble() *
            3600; // Convert hours to seconds
      }

      print("   Distance: $distance km");
      print("   Speed: $speed km/h");
      print("   Calories: $calories kcal");
      print("   Duration: $duration seconds");
      print("   Max Elevation: $elevation m");

      // Update controller values
      bikeMetricsController.totalDistance.value = distance;
      bikeMetricsController.currentSpeed.value = speed;
      bikeMetricsController.calculatedCalories.value = calories;
      bikeMetricsController.maxElevation.value = elevation;
      bikeMetricsController.totalDuration.value = duration;

      // Save to local storage
      await localStorage.setDouble("totalDistance", distance);
      await localStorage.setDouble("currentSpeed", speed);
      await localStorage.setDouble("calories", calories);
      await localStorage.setDouble("maxElevation", elevation);
      await localStorage.setTime(duration.toInt());

      // Refresh the observables
      bikeMetricsController.totalDistance.refresh();
      bikeMetricsController.currentSpeed.refresh();
      bikeMetricsController.calculatedCalories.refresh();
      bikeMetricsController.maxElevation.refresh();
      bikeMetricsController.totalDuration.refresh();

      print("✅ Successfully loaded existing trip metrics");
    } catch (e) {
      print("⚠️ Error parsing trip metrics: $e");
      print("   Active trip data: $activeTrip");
      // Continue with zero values if parsing fails
    }
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
