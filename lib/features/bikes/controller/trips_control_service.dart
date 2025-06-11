import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/bikes/controller/qr_controller.dart';
import 'package:mjollnir/features/bikes/views/qr_scanner.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/storage/local_storage.dart';
import '../../../shared/models/trips/active_trip_model.dart';
import '../../../shared/models/trips/trips_model.dart';
import '../../account/controllers/trips_controller.dart';
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

      final success =
          await tripsController.startTrip(startTripData, personal: personal);

      if (success) {
        currentTripId.value = tripsController.tripId.value;
        print("✅ Trip started successfully. Trip ID: ${currentTripId.value}");

        // Check if we have active trip data (continuing existing trip)
        if (tripsController.activeTripData.value != null) {
          print("🔄 Continuing existing trip with previous data");
          await _continueExistingTrip(tripsController.activeTripData.value!);
        } else {
          print("🆕 Starting fresh trip");
          // Start new trip tracking
          await bikeMetricsController.startTracking();
        }

        // Set bike subscription status
        bikeMetricsController.bikeSubscribed.value = true;
        bikeMetricsController.bikeID.value = startTripData.bikeId;

        // Persist trip data
        await localStorage.setBool('bikeSubscribed', true);
        await localStorage.setString('bikeCode', startTripData.bikeId);
        await localStorage.setString('tripId', currentTripId.value);

        print("💾 Trip data persisted to local storage");

        // Start tracking if not already started
        if (!bikeMetricsController.isTracking.value) {
          await bikeMetricsController.startTracking();
        }

        return true;
      } else {
        print("❌ Failed to start trip: ${tripsController.errorMessage.value}");
        errorMessage.value = tripsController.errorMessage.value;
        return false;
      }
    } catch (e) {
      print("❌ Exception in startTrip: $e");
      handleError('Failed to start trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _continueExistingTrip(ActiveTripResponse activeTrip) async {
    print("📊 Loading existing trip metrics:");
    print("   Distance: ${activeTrip.distanceKm} km");
    print("   Speed: ${activeTrip.speedKmh} km/h");
    print("   Calories: ${activeTrip.caloriesTrip} kcal");
    print("   Duration: ${activeTrip.totalTimeHours} hours");
    print("   Max Elevation: ${activeTrip.maxElevationM} m");

    // Load existing metrics from active trip
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

    // Force UI updates
    bikeMetricsController.totalDistance.refresh();
    bikeMetricsController.currentSpeed.refresh();
    bikeMetricsController.calculatedCalories.refresh();
    bikeMetricsController.maxElevation.refresh();
    bikeMetricsController.totalDuration.refresh();

    // Start tracking with existing data
    await bikeMetricsController.startTracking();

    print("✅ Successfully loaded existing trip data");
  }

  Future<bool> endTrip() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🏁 ========== ENDING TRIP ==========');

      // Print comprehensive trip summary before ending
      bikeMetricsController.printTripSummary();

      print('🔍 Trip ID Resolution:');
      print('   TripControlService.currentTripId: "${currentTripId.value}"');
      print('   TripsController.tripId: "${tripsController.tripId.value}"');

      final storedTripId = localStorage.getString('tripId');
      print('   localStorage tripId: "$storedTripId"');

      final bikeId = bikeMetricsController.bikeID.value;
      print('   BikeMetricsController.bikeID: "$bikeId"');

      // Try multiple sources for trip ID
      String? workingTripId;

      if (currentTripId.value.isNotEmpty) {
        workingTripId = currentTripId.value;
        print('✅ Using TripControlService.currentTripId');
      } else if (tripsController.tripId.value.isNotEmpty) {
        workingTripId = tripsController.tripId.value;
        currentTripId.value = workingTripId;
        print('✅ Using TripsController.tripId');
      } else if (storedTripId != null && storedTripId.isNotEmpty) {
        workingTripId = storedTripId;
        currentTripId.value = workingTripId;
        tripsController.tripId.value = workingTripId;
        print('✅ Using localStorage tripId');
      } else {
        print('🔍 No trip ID found, attempting to fetch active trip...');
        final activeTrip = await tripsController.fetchActiveTrip();
        if (activeTrip != null && activeTrip.id.isNotEmpty) {
          workingTripId = activeTrip.id;
          currentTripId.value = workingTripId;
          tripsController.tripId.value = workingTripId;
          await localStorage.setString('tripId', workingTripId);
          print('✅ Retrieved active trip ID: "$workingTripId"');
        }
      }

      if (workingTripId == null || workingTripId.isEmpty) {
        print('❌ CRITICAL ERROR - No trip ID found from any source!');
        handleError('No active trip found');
        return false;
      }

      print('🎯 Final working trip ID: "$workingTripId"');
      print('📡 Calling tripsController.dataSend(true)...');

      // Save trip summary before ending
      bikeMetricsController.saveTripSummary();

      final success = await tripsController.dataSend(true);
      print('📊 dataSend result: $success');

      if (tripsController.errorMessage.value.isNotEmpty) {
        print(
            '⚠️ TripsController error: "${tripsController.errorMessage.value}"');
      }

      if (success) {
        print('✅ Trip ended successfully via API');

        // Try to stop device if we have encoded ID
        try {
          final QrScannerController qrScannerController = Get.find();
          if (qrScannerController.encodedDeviceId.value.isNotEmpty) {
            print(
                '🔌 Attempting to stop device: ${qrScannerController.encodedDeviceId.value}');
            await qrScannerController.toggleDevice(
                qrScannerController.encodedDeviceId.value, false);
            print('✅ Device stopped successfully');
          }
        } catch (e) {
          print('⚠️ Device stop error (non-critical): $e');
        }

        await _cleanupAfterTripEnd();
        print('🧹 Cleanup completed');
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

  Future<void> _cleanupAfterTripEnd() async {
    print('🧹 Starting trip cleanup...');

    // Stop tracking and print final summary
    bikeMetricsController.stopTracking();

    // Save final trip summary
    bikeMetricsController.saveTripSummary();

    // Reset bike subscription status
    bikeMetricsController.bikeSubscribed.value = false;
    bikeMetricsController.bikeID.value = "";

    // Clear local storage
    await localStorage.remove('locations');
    await localStorage.setBool('bikeSubscribed', false);
    await localStorage.setString('bikeCode', "");
    await localStorage.setString('encodedId', '');
    await localStorage.setString('deviceId', "");
    await localStorage.setInt('time', 0);
    await localStorage.setString('tripId', '');

    // Reset trip data (but preserve last trip for summary)
    bikeMetricsController.resetTripData();

    // Reset control service state
    currentTripId.value = '';
    isEndTripSliderVisible.value = false;

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
