import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:mjollnir/features/main_page_controller.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/storage/local_storage.dart';
import '../../../main.dart';
import '../../../shared/models/trips/trips_model.dart';
import '../../account/controllers/trips_controller.dart';
import 'trips_control_service.dart';

class BikeMetricsController extends BaseController {
  final LocalStorage localStorage = Get.find<LocalStorage>();
  final TripsController tripsController = Get.find<TripsController>();

  late loc.Location _location;

  final RxBool bikeSubscribed = false.obs;
  final RxDouble currentSpeed = 0.0.obs;
  final RxDouble totalDistance = 0.0.obs;
  final RxDouble totalDuration = 0.0.obs;
  final RxString batteryPercentage = '0%'.obs;
  final RxBool isTracking = false.obs;
  final RxString bikeEncoded = ''.obs;
  final RxString bikeID = ''.obs;

  final RxDouble calculatedCalories = 0.0.obs;
  final RxDouble maxElevation = 0.0.obs;
  final RxDouble lastTripCalories = 0.0.obs;
  final RxDouble avgSpeed = 0.0.obs;

  final RxList<double> speedHistoryData = <double>[].obs;
  final RxList<double> durationHistoryData = <double>[].obs;
  final RxList<double> calorieHistoryData = <double>[].obs;
  final RxList<DateTime> timePoints = <DateTime>[].obs;

  final RxList<List<double>> pathPoints = <List<double>>[].obs;
  final RxString startLocationName = ''.obs;
  final RxString endLocationName = ''.obs;
  LatLng? startPosition;
  LatLng? endPosition;

  StreamSubscription<loc.LocationData>? _locationSubscription;
  Timer? _durationTimer;
  Timer? _historyUpdateTimer;
  Timer? _dataUpdateTimer;

  _LocationPoint? _lastLocationPoint;
  final List<double> _recentSpeeds = [];
  final List<double> _elevationList = [];

  bool _isFirstLocationUpdate = true;
  static const int _maxSpeedReadings = 3;
  static const double _minDistanceThreshold = 0.5;
  static const double _maxReasonableSpeed = 100.0;
  static const double _minAccuracy = 50.0;
  static const double _minTimeInterval = 1.0;

  Future<void> onInit() async {
    super.onInit();
    _location = loc.Location();
    await _loadMetricsFromStorage();
    _initializeHistoryData();
    _updateAverageSpeed();
    _startDataUpdateTimer();

    // Check if there was an active trip and restore tracking state
    await _checkAndRestoreActiveTrip();
  }

  Future<void> _updateTripLocation(loc.LocationData locationData) async {
    try {
      if (Get.isRegistered<TripControlService>()) {
        final tripControlService = Get.find<TripControlService>();
        if (tripControlService.isEndingTrip) {
          print('🛑 Trip is ending, skipping location update');
          return;
        }
      }

      if (tripsController.tripId.value.isEmpty) {
        String? storedTripId = localStorage.getString("tripId");
        if (storedTripId != null && storedTripId.isNotEmpty) {
          tripsController.tripId.value = storedTripId;
        } else {
          print('⚠️ No trip ID available, skipping location update');
          return;
        }
      }
      if (!isTracking.value) {
        print('⚠️ Tracking not active, skipping location update');
        return;
      }

      await tripsController.updateTripLocation(
        tripId: tripsController.tripId.value,
        lat: locationData.latitude!,
        long: locationData.longitude!,
        elevation: locationData.altitude ?? 0.0,
      );
    } catch (e) {
      if (e.toString().contains('Trip is not active')) {
        print('🛑 Trip is not active, stopping location updates');
        // Stop tracking if trip is not active
        stopTracking();
      } else {
        print('Error updating trip location: $e');
      }
    }
  }

  Future<void> _checkAndRestoreActiveTrip() async {
    try {
      final bool wasBikeSubscribed = localStorage.getBool("bikeSubscribed");
      final String? storedTripId = localStorage.getString("tripId");
      final String? storedBikeId = localStorage.getString("bikeCode");

      print("🔍 Checking for active trip on app restart...");
      print("   wasBikeSubscribed: $wasBikeSubscribed");
      print("   storedTripId: $storedTripId");
      print("   storedBikeId: $storedBikeId");

      if (wasBikeSubscribed &&
          storedTripId != null &&
          storedTripId.isNotEmpty &&
          storedBikeId != null &&
          storedBikeId.isNotEmpty) {
        print("✅ Found active trip data, restoring...");

        // Restore bike subscription state
        bikeSubscribed.value = true;
        bikeID.value = storedBikeId;

        // Check if there's actually an active trip via API
        try {
          final TripsController tripsController = Get.find<TripsController>();
          final activeTrip = await tripsController.fetchActiveTrip();

          if (activeTrip != null) {
            print("✅ Confirmed active trip exists, resuming tracking...");
            tripsController.tripId.value = activeTrip.id;

            // Resume tracking automatically
            if (!isTracking.value) {
              await startTracking();
            }

            // Update main page controller
            if (Get.isRegistered<MainPageController>()) {
              final mainController = Get.find<MainPageController>();
              mainController.isBikeSubscribed.value = true;
            }
          } else {
            print("⚠️ No active trip found via API, clearing stored data...");
            await _clearStoredTripData();
          }
        } catch (e) {
          print("⚠️ Error checking active trip: $e");
          // Keep local state but don't auto-resume tracking
        }
      } else {
        print("ℹ️ No active trip found in storage");
      }
    } catch (e) {
      print("❌ Error in _checkAndRestoreActiveTrip: $e");
    }
  }

  Future<void> _clearStoredTripData() async {
    await localStorage.setBool('bikeSubscribed', false);
    await localStorage.setString('bikeCode', '');
    await localStorage.setString('tripId', '');
    bikeSubscribed.value = false;
    bikeID.value = '';

    if (Get.isRegistered<MainPageController>()) {
      final mainController = Get.find<MainPageController>();
      mainController.isBikeSubscribed.value = false;
    }
  }

  Future<void> _loadMetricsFromStorage() async {
    try {
      totalDuration.value = localStorage.getTime().toDouble();
      totalDistance.value = localStorage.getDouble("totalDistance") ?? 0.0;
      currentSpeed.value = localStorage.getDouble("currentSpeed") ?? 0.0;
      calculatedCalories.value = localStorage.getDouble("calories") ?? 0.0;
      maxElevation.value = localStorage.getDouble("maxElevation") ?? 0.0;
      lastTripCalories.value =
          localStorage.getDouble("lastTripCalories") ?? 0.0;
      bikeID.value = localStorage.getString("bikeId") ?? '';
      bikeSubscribed.value = localStorage.getBool("bikeSubscribed");
    } catch (e) {
      print("Error loading metrics: $e");
    }
  }

  void _startDataUpdateTimer() {
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isTracking.value) {
        _updateInstantaneousData();
        _persistMetrics();
        currentSpeed.refresh();
        totalDistance.refresh();
        totalDuration.refresh();
        calculatedCalories.refresh();
        update();
      }
    });
  }

  List<double> _generateInitialData() {
    final random = Random();
    return List.generate(7, (index) => random.nextDouble() * 5);
  }

  void _updateInstantaneousData() {
    _updateAverageSpeed();
    _calculateCalories();
    currentSpeed.refresh();
    totalDistance.refresh();
    totalDuration.refresh();
    calculatedCalories.refresh();
  }

  void _initializeHistoryData() {
    final savedSpeedHistory = localStorage.getDoubleList("speedHistory");
    final savedDurationHistory = localStorage.getDoubleList("durationHistory");
    final savedCalorieHistory = localStorage.getDoubleList("calorieHistory");
    final savedTimePoints = localStorage.getStringList("timePoints");

    speedHistoryData.value = savedSpeedHistory.isNotEmpty
        ? savedSpeedHistory
        : _generateInitialData();
    durationHistoryData.value = savedDurationHistory.isNotEmpty
        ? savedDurationHistory
        : _generateInitialData();
    calorieHistoryData.value = savedCalorieHistory.isNotEmpty
        ? savedCalorieHistory
        : _generateInitialData();

    if (savedTimePoints?.isNotEmpty == true) {
      timePoints.value = savedTimePoints!
          .map((timeStr) => DateTime.tryParse(timeStr) ?? DateTime.now())
          .toList();
    } else {
      final now = DateTime.now();
      timePoints.value = List.generate(
          7, (index) => now.subtract(Duration(minutes: (6 - index) * 10)));
    }
  }

  void _persistMetrics() {
    try {
      localStorage.setTime(totalDuration.value.toInt());
      localStorage.setDouble("totalDistance", totalDistance.value);
      localStorage.setDouble("currentSpeed", currentSpeed.value);
      localStorage.setDouble("calories", calculatedCalories.value);
      localStorage.setDouble("maxElevation", maxElevation.value);
      localStorage.setDouble("lastTripCalories", lastTripCalories.value);
      localStorage.setString("bikeId", bikeID.value);
      localStorage.setBool("bikeSubscribed", bikeSubscribed.value);

      localStorage.setDoubleList("speedHistory", speedHistoryData);
      localStorage.setDoubleList("durationHistory", durationHistoryData);
      localStorage.setDoubleList("calorieHistory", calorieHistoryData);
      localStorage.setStringList("timePoints",
          timePoints.map((time) => time.toIso8601String()).toList());
    } catch (e) {
      if (kDebugMode) {
        print("Error persisting metrics: $e");
      }
    }
  }

  @override
  void onReady() {
    super.onReady();

    totalDuration.listen((value) {
      _persistMetrics();
      _updateAverageSpeed();
      _calculateCalories();
    });

    currentSpeed.listen((value) {
      _persistMetrics();
      _updateAverageSpeed();
    });

    totalDistance.listen((value) {
      _persistMetrics();
      _calculateCalories();
    });

    calculatedCalories.listen((_) => _persistMetrics());
    maxElevation.listen((_) => _persistMetrics());
    lastTripCalories.listen((_) => _persistMetrics());
    bikeID.listen((_) => _persistMetrics());
    bikeSubscribed.listen((_) => _persistMetrics());
  }

  Future<void> startTracking() async {
    if (!await _requestLocationPermissions()) {
      handleError('Location permissions denied');
      return;
    }

    try {
      if (totalDistance.value == 0.0 && totalDuration.value == 0.0) {
        _resetTripData();
      }

      await _location.changeSettings(
        interval: 1000,
        distanceFilter: 0,
        accuracy: loc.LocationAccuracy.high,
      );

      _startTimers();

      _locationSubscription = _location.onLocationChanged
          .listen(_handleLocationUpdate, onError: (error) {
        print("Location tracking error: $error");
        handleError('Location tracking error: $error');
      });

      isTracking.value = true;
    } catch (e) {
      print("Failed to start tracking: $e");
      handleError('Failed to start tracking: $e');
    }
  }

  void _resetTripData() {
    pathPoints.clear();
    localStorage.savePathPoints(pathPoints);
    localStorage.saveLocationList([]);
    _isFirstLocationUpdate = true;
    _lastLocationPoint = null;
    _recentSpeeds.clear();
    _elevationList.clear();
  }

  void _startTimers() {
    _startDurationTimer();
    _startHistoryTimer();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isTracking.value) {
        totalDuration.value++;
        totalDuration.refresh();
      }
    });
  }

  void _startHistoryTimer() {
    _historyUpdateTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (isTracking.value) {
        _updateHistoryData();
        _calculateCalories();
      }
    });
  }

  void pauseTracking() {
    _locationSubscription?.pause();
    _stopTimers();
  }

  void resumeTracking() {
    _locationSubscription?.resume();
    _startTimers();
  }

  void _handleLocationUpdate(loc.LocationData locationData) {
    if (!_isValidLocationData(locationData)) {
      return;
    }

    final newLocation = _LocationPoint.fromLocationData(locationData);
    _processLocationData(newLocation);
    _updatePathAndElevation(newLocation);
    _updateTripLocation(locationData);
  }

  bool _isValidLocationData(loc.LocationData data) {
    return data.accuracy != null &&
        data.accuracy! <= _minAccuracy &&
        data.latitude != null &&
        data.longitude != null &&
        data.latitude! != 0.0 &&
        data.longitude! != 0.0;
  }

  void _processLocationData(_LocationPoint newLocation) {
    if (_lastLocationPoint != null) {
      _updateSpeedAndDistance(_lastLocationPoint!, newLocation);
    }

    if (_isFirstLocationUpdate) {
      _setStartLocation(newLocation);
      _isFirstLocationUpdate = false;
    }

    _setEndLocation(newLocation);
    _lastLocationPoint = newLocation;
  }

  void _updateSpeedAndDistance(
      _LocationPoint previous, _LocationPoint current) {
    final distance = _calculateHaversineDistance(previous, current) * 1000;
    final timeDiff = (current.time - previous.time) / 1000;

    if (timeDiff >= _minTimeInterval && distance >= _minDistanceThreshold) {
      final speedMs = distance / timeDiff;
      final speedKmh = speedMs * 3.6;

      if (speedKmh <= _maxReasonableSpeed) {
        _updateSpeed(speedKmh);
        _updateDistance(distance / 1000);
      }
    }
  }

  void _updateSpeed(double newSpeed) {
    _recentSpeeds.add(newSpeed);
    if (_recentSpeeds.length > _maxSpeedReadings) {
      _recentSpeeds.removeAt(0);
    }

    double filteredSpeed;
    if (_recentSpeeds.length == 1) {
      filteredSpeed = newSpeed;
    } else {
      _recentSpeeds.sort();
      if (_recentSpeeds.length == 2) {
        filteredSpeed = (_recentSpeeds[0] + _recentSpeeds[1]) / 2;
      } else {
        filteredSpeed = _recentSpeeds[1];
      }
    }

    currentSpeed.value = filteredSpeed;
    currentSpeed.refresh();
  }

  void _updateDistance(double distanceKm) {
    totalDistance.value += distanceKm;
    totalDistance.refresh();
  }

  void _updatePathAndElevation(_LocationPoint location) {
    pathPoints.add([location.lat, location.lng]);
    localStorage.savePathPoints(pathPoints);

    _elevationList.add(location.altitude);
    if (location.altitude > maxElevation.value) {
      maxElevation.value = location.altitude;
    }

    final locations = localStorage.getLocationList();
    locations.add([location.lat, location.lng]);
    localStorage.saveLocationList(locations);
  }

  // Future<void> _updateTripLocation(loc.LocationData locationData) async {
  //   try {
  //     if (tripsController.tripId.value.isEmpty) {
  //       String? storedTripId = localStorage.getString("tripId");
  //       if (storedTripId != null && storedTripId.isNotEmpty) {
  //         tripsController.tripId.value = storedTripId;
  //       } else {
  //         return;
  //       }
  //     }

  //     await tripsController.updateTripLocation(
  //       tripId: tripsController.tripId.value,
  //       lat: locationData.latitude!,
  //       long: locationData.longitude!,
  //       elevation: locationData.altitude ?? 0.0,
  //     );
  //   } catch (e) {
  //     print('Error updating trip location: $e');
  //   }
  // }

  void _setStartLocation(_LocationPoint location) {
    startPosition = LatLng(location.lat, location.lng);
    _getLocationName(location.lat, location.lng, true);
  }

  void _setEndLocation(_LocationPoint location) {
    endPosition = LatLng(location.lat, location.lng);
    _getLocationName(location.lat, location.lng, false);
  }

  Future<void> _getLocationName(double lat, double lng, bool isStart) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locationName =
            '${place.street ?? 'Unknown'}, ${place.locality ?? 'Unknown'}';

        if (isStart) {
          startLocationName.value = locationName;
        } else {
          endLocationName.value = locationName;
        }
      }
    } catch (e) {
      print("Error getting location name: $e");
    }
  }

  void _updateHistoryData() {
    _updateSpeedHistory(currentSpeed.value);
    _updateDurationHistory(totalDuration.value / 60);
    _updateCalorieHistory(calculatedCalories.value);

    speedHistoryData.refresh();
    durationHistoryData.refresh();
    calorieHistoryData.refresh();
    timePoints.refresh();
  }

  void _updateAverageSpeed() {
    if (totalDistance.value > 0 && totalDuration.value > 0) {
      final durationInHours = totalDuration.value / 3600;
      avgSpeed.value = totalDistance.value / durationInHours;
      avgSpeed.refresh();
    } else {
      avgSpeed.value = 0.0;
    }
  }

  void _updateSpeedHistory(double newSpeed) {
    if (speedHistoryData.length >= 7) {
      speedHistoryData.removeAt(0);
      timePoints.removeAt(0);
    }

    speedHistoryData.add(newSpeed);
    timePoints.add(DateTime.now());
  }

  void _updateDurationHistory(double minutes) {
    if (durationHistoryData.length >= 7) {
      durationHistoryData.removeAt(0);
    }
    durationHistoryData.add(minutes);
  }

  void _updateCalorieHistory(double newCalories) {
    if (calorieHistoryData.length >= 7) {
      calorieHistoryData.removeAt(0);
    }
    calorieHistoryData.add(newCalories);
  }

  void _calculateCalories() {
    final met = _getMetValue(currentSpeed.value);
    final elevationFactor = _getElevationFactor();
    final userWeight = localStorage.getDouble('userWeight') ?? 70.0;
    final durationInHours = totalDuration.value / 3600;

    calculatedCalories.value =
        met * userWeight * durationInHours * elevationFactor;
    calculatedCalories.refresh();
    lastTripCalories.value = calculatedCalories.value;
  }

  double _getMetValue(double speed) {
    if (speed < 8) return 4.0;
    if (speed < 16) return 6.0;
    if (speed < 20) return 8.0;
    if (speed < 25) return 10.0;
    if (speed < 30) return 12.0;
    return 14.0;
  }

  double _getElevationFactor() {
    if (_elevationList.length < 5) return 1.0;

    final recentElevations = _elevationList.length >= 10
        ? _elevationList.sublist(_elevationList.length - 10)
        : _elevationList;

    if (recentElevations.length < 2) return 1.0;

    final elevationChange = recentElevations.last - recentElevations.first;

    if (elevationChange > 10) return 1.3;
    if (elevationChange > 5) return 1.2;
    if (elevationChange < -10) return 0.8;
    if (elevationChange < -5) return 0.9;
    return 1.0;
  }

  Future<String> fetchBatteryInfo(String encodedId) async {
    try {
      bikeEncoded.value = encodedId;
      final response =
          await apiService.get(endpoint: '/v1/metal/status/${bikeID.value}');
      final batteryData = response['data'];
      batteryPercentage.value = batteryData;
      return batteryData;
    } catch (e) {
      handleError('Failed to fetch battery info: $e');
    }
    return '0%';
  }

  void saveTripSummary() {
    localStorage.setDouble("lastTripCalories", calculatedCalories.value);
    localStorage.setDouble("lastTripDistance", totalDistance.value);
    localStorage.setDouble("lastTripDuration", totalDuration.value);
    localStorage.setString(
        "lastTripTimestamp", DateTime.now().toIso8601String());
  }

  void resetTripData() {
    lastTripCalories.value = calculatedCalories.value;
    localStorage.setDouble("lastTripCalories", lastTripCalories.value);

    totalDistance.value = 0.0;
    totalDuration.value = 0.0;
    currentSpeed.value = 0.0;
    calculatedCalories.value = 0.0;
    maxElevation.value = 0.0;

    speedHistoryData.value = List.generate(7, (index) => 0.0);
    durationHistoryData.value = List.generate(7, (index) => 0.0);
    calorieHistoryData.value = List.generate(7, (index) => 0.0);

    final now = DateTime.now();
    timePoints.value = List.generate(
        7, (index) => now.subtract(Duration(minutes: (6 - index) * 10)));

    _recentSpeeds.clear();
    _elevationList.clear();
    _lastLocationPoint = null;

    _stopTimers();
    _persistMetrics();
  }

  TripMetrics getCurrentMetrics() {
    return TripMetrics(
      speed: currentSpeed.value,
      distance: totalDistance.value,
      duration: totalDuration.value,
      calories: calculatedCalories.value,
      elevation: maxElevation.value,
      batteryPercentage: batteryPercentage.value,
    );
  }

  double _calculateHaversineDistance(_LocationPoint p1, _LocationPoint p2) {
    const double earthRadius = 6371000;

    final lat1Rad = p1.lat * pi / 180;
    final lat2Rad = p2.lat * pi / 180;
    final deltaLat = (p2.lat - p1.lat) * pi / 180;
    final deltaLng = (p2.lng - p1.lng) * pi / 180;

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c / 1000;
  }

  Future<bool> _requestLocationPermissions() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return false;
      }

      var permissionStatus = await _location.hasPermission();
      if (permissionStatus == loc.PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != loc.PermissionStatus.granted) return false;
      }

      return true;
    } catch (e) {
      print("Error requesting location permissions: $e");
      return false;
    }
  }

  void printTripSummary() {
    print("TRIP SUMMARY");
    print("Total Distance: ${totalDistance.value.toStringAsFixed(2)} km");
    print("Total Duration: ${_formatDuration(totalDuration.value)}");
    print("Current Speed: ${currentSpeed.value.toStringAsFixed(1)} km/h");
    print("Average Speed: ${avgSpeed.value.toStringAsFixed(1)} km/h");
    print(
        "Calories Burned: ${calculatedCalories.value.toStringAsFixed(1)} kcal");
    print("Max Elevation: ${maxElevation.value.toStringAsFixed(1)} m");
    print("Battery: ${batteryPercentage.value}");
    print("Path Points: ${pathPoints.length} points");
    print("Start Location: ${startLocationName.value}");
    print("End Location: ${endLocationName.value}");
    print("Bike ID: ${bikeID.value}");
    print("Encoded ID: ${bikeEncoded.value}");
    print("Subscribed: ${bikeSubscribed.value}");
  }

  String _formatDuration(double seconds) {
    final int hours = (seconds ~/ 3600);
    final int minutes = ((seconds % 3600) ~/ 60);
    final int secs = (seconds % 60).toInt();

    if (hours > 0) {
      return '$hours hr ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  void stopTracking() {
    printTripSummary();

    _locationSubscription?.cancel();
    _stopTimers();
    isTracking.value = false;

    final MainPageController controller = Get.find();
    if (controller.isBikeSubscribed.value) {
      controller.isBikeSubscribed.value = false;
    }

    _persistMetrics();
  }

  void _stopTimers() {
    _durationTimer?.cancel();
    _historyUpdateTimer?.cancel();
    _dataUpdateTimer?.cancel();
    _durationTimer = null;
    _historyUpdateTimer = null;
    _dataUpdateTimer = null;
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _stopTimers();
    _persistMetrics();
    super.onClose();
  }
}

class _LocationPoint {
  final double lat;
  final double lng;
  final int time;
  final double accuracy;
  final double altitude;

  _LocationPoint({
    required this.lat,
    required this.lng,
    required this.time,
    required this.accuracy,
    required this.altitude,
  });

  factory _LocationPoint.fromLocationData(loc.LocationData data) {
    return _LocationPoint(
      lat: data.latitude!,
      lng: data.longitude!,
      time: DateTime.now().millisecondsSinceEpoch,
      accuracy: data.accuracy!,
      altitude: data.altitude ?? 0.0,
    );
  }
}
