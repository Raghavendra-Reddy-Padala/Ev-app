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
import '../../../core/utils/kalman_filter.dart';
import '../../../main.dart';
import '../../../shared/models/trips/trips_model.dart';
import '../../account/controllers/trips_controller.dart';

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

  // Trip data
  final RxDouble calculatedCalories = 0.0.obs;
  final RxDouble maxElevation = 0.0.obs;
  final RxDouble lastTripCalories = 0.0.obs;
  final RxDouble avgSpeed = 0.0.obs;

  // History data - Make these more reactive
  final RxList<double> speedHistoryData = <double>[].obs;
  final RxList<double> durationHistoryData = <double>[].obs;
  final RxList<double> calorieHistoryData = <double>[].obs;
  final RxList<DateTime> timePoints = <DateTime>[].obs;

  // Location data
  final RxList<List<double>> pathPoints = <List<double>>[].obs;
  final RxString startLocationName = ''.obs;
  final RxString endLocationName = ''.obs;
  LatLng? startPosition;
  LatLng? endPosition;

  StreamSubscription<loc.LocationData>? _locationSubscription;
  Timer? _durationTimer;
  Timer? _historyUpdateTimer;
  Timer? _dataUpdateTimer;

  final KalmanFilter _speedFilter = KalmanFilter();
  final List<_LocationPoint> _locationBuffer = [];
  final List<double> _speedReadings = [];
  final List<double> _elevationList = [];
  final List<double> _instantSpeedHistory = [];

  bool _isFirstLocationUpdate = true;
  static const int _maxSpeedReadings = 10;
  static const double _minDistanceThreshold = 2.0;
  static const double _maxReasonableSpeed = 60.0;

  @override
  Future<void> onInit() async {
    super.onInit();
    _location = loc.Location();
    await _loadMetricsFromStorage();
    _initializeHistoryData();
    _updateAverageSpeed();
    _startDataUpdateTimer();
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

      print("📊 Loaded metrics from storage:");
      print("   Duration: ${totalDuration.value}s");
      print("   Distance: ${totalDistance.value}km");
      print("   Speed: ${currentSpeed.value}km/h");
      print("   Calories: ${calculatedCalories.value}");
      print("   BikeID: ${bikeID.value}");
    } catch (e) {
      print("❌ Error loading metrics: $e");
    }
  }

  void _startDataUpdateTimer() {
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (isTracking.value) {
        _updateInstantaneousData();
        _persistMetrics();
        update(); // Force UI update
      }
    });
  }

  List<double> _generateInitialData() {
    // Generate some realistic initial data instead of zeros
    final random = Random();
    return List.generate(7, (index) => random.nextDouble() * 10);
  }

  void _updateInstantaneousData() {
    if (currentSpeed.value > 0) {
      _instantSpeedHistory.add(currentSpeed.value);
      if (_instantSpeedHistory.length > 20) {
        _instantSpeedHistory.removeAt(0);
      }
    }
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

    // Initialize with some default data if empty
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

    print("📈 Initialized history data:");
    print("   Speed history: ${speedHistoryData.length} points");
    print("   Duration history: ${durationHistoryData.length} points");
    print("   Calorie history: ${calorieHistoryData.length} points");
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

      // Debug print every 30 seconds
      if (totalDuration.value.toInt() % 30 == 0) {
        if (kDebugMode) {
          print("💾 Persisted metrics at ${DateTime.now()}");
        }
        if (kDebugMode) {
          print(
              "   Current values: Speed=${currentSpeed.value}, Distance=${totalDistance.value}, Duration=${totalDuration.value}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error persisting metrics: $e");
      }
    }
  }

  @override
  void onReady() {
    super.onReady();

    // Enhanced listeners with better reactivity
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
      print("🚀 Starting bike tracking...");

      // Only reset if completely new trip
      if (totalDistance.value == 0.0 && totalDuration.value == 0.0) {
        print("   New trip - resetting data");
        _resetTripData();
      } else {
        print("   Continuing existing trip");
        print(
            "   Current: Distance=${totalDistance.value}km, Duration=${totalDuration.value}s");
      }

      await _location.changeSettings(
        interval: 1000, // More frequent updates
        distanceFilter: 2, // Smaller distance filter
        accuracy: loc.LocationAccuracy.high,
      );

      _startTimers();

      _locationSubscription = _location.onLocationChanged
          .listen(_handleLocationUpdate, onError: (error) {
        print("❌ Location tracking error: $error");
        handleError('Location tracking error: $error');
      });

      isTracking.value = true;
      print("✅ Tracking started successfully");
    } catch (e) {
      print("❌ Failed to start tracking: $e");
      handleError('Failed to start tracking: $e');
    }
  }

  void _resetTripData() {
    pathPoints.clear();
    localStorage.savePathPoints(pathPoints);
    localStorage.saveLocationList([]);
    _isFirstLocationUpdate = true;
    _locationBuffer.clear();
    _speedReadings.clear();
    _elevationList.clear();
    _instantSpeedHistory.clear();
  }

  void _startTimers() {
    _startDurationTimer();
    _startHistoryTimer();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isTracking.value) {
        totalDuration.value++;
        // Update UI every second
        totalDuration.refresh();
      }
    });
  }

  void _startHistoryTimer() {
    _historyUpdateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (isTracking.value) {
        _updateHistoryData();
        _calculateCalories();
      }
    });
  }

  void pauseTracking() {
    _locationSubscription?.pause();
    _stopTimers();
    print("Tracking paused");
  }

  void resumeTracking() {
    _locationSubscription?.resume();
    _startTimers();
    print("Tracking resumed");
  }

  void _handleLocationUpdate(loc.LocationData locationData) {
    if (!_isValidLocationData(locationData)) return;

    final newLocation = _LocationPoint.fromLocationData(locationData);
    _locationBuffer.add(newLocation);

    if (_locationBuffer.length > 10) {
      // Keep more points for better accuracy
      _locationBuffer.removeAt(0);
    }

    _processLocationData(newLocation);
    _updatePathAndElevation(newLocation);

    // Debug location updates
    if (_locationBuffer.length % 10 == 0) {
      if (kDebugMode) {
        print(
            "📍 Location update: ${locationData.latitude}, ${locationData.longitude}");
      }
      if (kDebugMode) {
        print(
            "   Speed: ${currentSpeed.value}km/h, Distance: ${totalDistance.value}km");
      }
    }
  }

  bool _isValidLocationData(loc.LocationData data) {
    return data.accuracy != null &&
        data.accuracy! <= 20 && // Slightly relaxed accuracy
        data.latitude != null &&
        data.longitude != null;
  }

  void _processLocationData(_LocationPoint newLocation) {
    if (_locationBuffer.length >= 2) {
      final currentPoint = _locationBuffer.last;
      final previousPoint = _locationBuffer[_locationBuffer.length - 2];

      _updateSpeedAndDistance(previousPoint, currentPoint);
    }

    if (_isFirstLocationUpdate) {
      _setStartLocation(newLocation);
      _isFirstLocationUpdate = false;
    }

    _setEndLocation(newLocation);
  }

  void _updateSpeedAndDistance(
      _LocationPoint previous, _LocationPoint current) {
    final distance =
        _calculateHaversineDistance(previous, current) * 1000; // meters
    final timeDiff = (current.time - previous.time) / 1000; // seconds

    if (timeDiff > 0 && distance >= _minDistanceThreshold) {
      final speedKmh = (distance / timeDiff) * 3.6;
      _updateSpeed(speedKmh);
      _updateDistance(distance / 1000); // convert to km
    }
  }

  void _updateSpeed(double newSpeed) {
    if (newSpeed > _maxReasonableSpeed) return;

    _speedReadings.add(newSpeed);
    if (_speedReadings.length > _maxSpeedReadings) {
      _speedReadings.removeAt(0);
    }

    final smoothedSpeed = _calculateSmoothedSpeed();
    currentSpeed.value = _speedFilter.update(smoothedSpeed);

    currentSpeed.refresh();
  }

  double _calculateSmoothedSpeed() {
    if (_speedReadings.isEmpty) return 0.0;

    double totalWeight = 0;
    double weightedSum = 0;

    for (int i = 0; i < _speedReadings.length; i++) {
      final weight = (i + 1) * 1.5;
      weightedSum += _speedReadings[i] * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
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

  void _setStartLocation(_LocationPoint location) {
    startPosition = LatLng(location.lat, location.lng);
    _getLocationName(location.lat, location.lng, true);
  }

  void _setEndLocation(_LocationPoint location) {
    endPosition = LatLng(location.lat, location.lng);
  }

  Future<void> _getLocationName(double lat, double lng, bool isStart) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locationName = '${place.street}, ${place.locality}';

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
    if (kDebugMode) {
      print("📊 Updating history data...");
    }
    _updateSpeedHistory(currentSpeed.value);
    _updateDurationHistory(totalDuration.value / 60); // Convert to minutes
    _updateCalorieHistory(calculatedCalories.value);

    // Force refresh of all history data
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

    if (kDebugMode) {
      print("   Speed history updated: ${speedHistoryData.last}");
    }
  }

  void _updateDurationHistory(double minutes) {
    if (durationHistoryData.length >= 7) {
      durationHistoryData.removeAt(0);
    }

    durationHistoryData.add(minutes);
    if (kDebugMode) {
      print("   Duration history updated: ${durationHistoryData.last}");
    }
  }

  void _updateCalorieHistory(double newCalories) {
    if (calorieHistoryData.length >= 7) {
      calorieHistoryData.removeAt(0);
    }

    calorieHistoryData.add(newCalories);
    if (kDebugMode) {
      print("   Calorie history updated: ${calorieHistoryData.last}");
    }
  }

  void _calculateCalories() {
    final met = _getMetValue(currentSpeed.value);
    final elevationFactor = _getElevationFactor();
    final userWeight = localStorage.getDouble('userWeight') ?? 70.0;
    final durationInHours = totalDuration.value / 3600;

    final oldCalories = calculatedCalories.value;
    calculatedCalories.value =
        met * userWeight * durationInHours * elevationFactor;

    if ((calculatedCalories.value - oldCalories).abs() > 1) {
      print(
          "🔥 Calories updated: ${calculatedCalories.value.toStringAsFixed(1)}");
      calculatedCalories.refresh();
    }

    lastTripCalories.value = calculatedCalories.value;
  }

  double _getMetValue(double speed) {
    if (speed < 8) return 3.0;
    if (speed < 16) return 4.0;
    if (speed < 20) return 6.0;
    if (speed < 25) return 8.0;
    if (speed < 30) return 10.0;
    return 12.0;
  }

  double _getElevationFactor() {
    if (_elevationList.length < 10) return 1.0;

    final recentElevations = _elevationList.sublist(_elevationList.length - 10);
    final elevationChange = recentElevations.last - recentElevations.first;

    if (elevationChange > 5) return 1.2;
    if (elevationChange < -5) return 0.9;
    return 1.0;
  }

  Future<String> fetchBatteryInfo(String encodedId) async {
    try {
      bikeEncoded.value = encodedId;
      final response =
          await apiService.get(endpoint: '/v1/metal/status/$encodedId');


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

    _speedReadings.clear();
    _elevationList.clear();
    _locationBuffer.clear();

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
    const double earthRadius = 6371.0; // km

    final lat1Rad = p1.lat * pi / 180;
    final lat2Rad = p2.lat * pi / 180;
    final deltaLat = (p2.lat - p1.lat) * pi / 180;
    final deltaLng = (p2.lng - p1.lng) * pi / 180;

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
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
    print("\n🏁 =============== TRIP SUMMARY ===============");
    print("📊 BASIC METRICS:");
    print("   🚴 Total Distance: ${totalDistance.value.toStringAsFixed(2)} km");
    print("   ⏱️  Total Duration: ${_formatDuration(totalDuration.value)}");
    print(
        "   🏎️  Current Speed: ${currentSpeed.value.toStringAsFixed(1)} km/h");
    print("   📈 Average Speed: ${avgSpeed.value.toStringAsFixed(1)} km/h");
    print(
        "   🔥 Calories Burned: ${calculatedCalories.value.toStringAsFixed(1)} kcal");
    print("   🏔️  Max Elevation: ${maxElevation.value.toStringAsFixed(1)} m");
    print("   🔋 Battery: ${batteryPercentage.value}");

    print("\n📍 LOCATION DATA:");
    print("   🛣️  Path Points: ${pathPoints.length} points");
    print("   📍 Start Location: ${startLocationName.value}");
    print("   🏁 End Location: ${endLocationName.value}");

    if (pathPoints.isNotEmpty) {
      print("   📊 Path Sample:");
      final sampleSize = min(5, pathPoints.length);
      for (int i = 0; i < sampleSize; i++) {
        final point = pathPoints[i];
        print(
            "     Point $i: [${point[0].toStringAsFixed(6)}, ${point[1].toStringAsFixed(6)}]");
      }
      if (pathPoints.length > 5) {
        print("     ... and ${pathPoints.length - 5} more points");
      }
    }

    print("\n📈 HISTORY DATA:");
    print(
        "   🏎️  Speed History: ${speedHistoryData.map((s) => s.toStringAsFixed(1)).join(', ')} km/h");
    print(
        "   ⏱️  Duration History: ${durationHistoryData.map((d) => d.toStringAsFixed(1)).join(', ')} min");
    print(
        "   🔥 Calorie History: ${calorieHistoryData.map((c) => c.toStringAsFixed(1)).join(', ')} kcal");

    print("\n🚴 BIKE INFO:");
    print("   🆔 Bike ID: ${bikeID.value}");
    print("   🔗 Encoded ID: ${bikeEncoded.value}");
    print("   ✅ Subscribed: ${bikeSubscribed.value}");

    print("===============================================\n");
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
    print("🛑 Stopping bike tracking...");
    printTripSummary();

    _locationSubscription?.cancel();
    _stopTimers();
    isTracking.value = false;
    final MainPageController controller = Get.find();
    if(controller.isBikeSubscribed.value){
      controller.isBikeSubscribed.value = false;
    }

    _persistMetrics();
    print("✅ Tracking stopped");
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
