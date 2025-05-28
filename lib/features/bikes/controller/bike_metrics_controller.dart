import 'dart:async';
import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
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

  // Reactive variables
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

  // History data
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

  // Private variables
  StreamSubscription<loc.LocationData>? _locationSubscription;
  Timer? _durationTimer;
  Timer? _historyUpdateTimer;

  final KalmanFilter _speedFilter = KalmanFilter();
  final List<_LocationPoint> _locationBuffer = [];
  final List<double> _speedReadings = [];
  final List<double> _elevationList = [];

  bool _isFirstLocationUpdate = true;
  static const int _maxSpeedReadings = 5;
  static const double _minDistanceThreshold = 5.0;
  //static const double _minSpeedThreshold = 0.5;
  static const double _maxReasonableSpeed = 50.0;

  @override
  Future<void> onInit() async {
    super.onInit();
    _location = loc.Location();
    await _loadMetricsFromStorage();
    _initializeHistoryData();
    _updateAverageSpeed();
  }

  Future<void> _loadMetricsFromStorage() async {
    totalDuration.value = localStorage.getTime().toDouble();
    totalDistance.value = localStorage.getDouble("totalDistance") ?? 0.0;
    currentSpeed.value = localStorage.getDouble("currentSpeed") ?? 0.0;
    calculatedCalories.value = localStorage.getDouble("calories") ?? 0.0;
    maxElevation.value = localStorage.getDouble("maxElevation") ?? 0.0;
    lastTripCalories.value = localStorage.getDouble("lastTripCalories") ?? 0.0;
    bikeID.value = localStorage.getString("bikeId") ?? '';
    bikeSubscribed.value = localStorage.getBool("bikeSubscribed");
  }

  void _initializeHistoryData() {
    final savedSpeedHistory = localStorage.getDoubleList("speedHistory");
    final savedDurationHistory = localStorage.getDoubleList("durationHistory");
    final savedCalorieHistory = localStorage.getDoubleList("calorieHistory");
    final savedTimePoints = localStorage.getStringList("timePoints");

    speedHistoryData.value = savedSpeedHistory.isNotEmpty
        ? savedSpeedHistory
        : List.generate(7, (index) => 0.0);

    durationHistoryData.value = savedDurationHistory.isNotEmpty
        ? savedDurationHistory
        : List.generate(7, (index) => 0.0);

    calorieHistoryData.value = savedCalorieHistory.isNotEmpty
        ? savedCalorieHistory
        : List.generate(7, (index) => 0.0);

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
  }

  @override
  void onReady() {
    super.onReady();

    // Set up listeners
    totalDuration.listen((_) {
      _persistMetrics();
      _updateAverageSpeed();
    });

    currentSpeed.listen((_) => _persistMetrics());
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
      // Only reset trip data if starting a completely new trip
      // If we're continuing an existing trip, keep the current values
      if (totalDistance.value == 0.0 && totalDuration.value == 0.0) {
        _resetTripData();
      } else {
        // Continuing existing trip - just clear path points for new tracking
        pathPoints.clear();
        localStorage.savePathPoints(pathPoints);
        localStorage.saveLocationList([]);
        _isFirstLocationUpdate = true;
        _locationBuffer.clear();
        _speedReadings.clear();
        _elevationList.clear();
      }

      await _location.changeSettings(
        interval: 2000,
        distanceFilter: 5,
        accuracy: loc.LocationAccuracy.high,
      );

      _startTimers();

      _locationSubscription = _location.onLocationChanged.listen(
          _handleLocationUpdate,
          onError: (error) => handleError('Location tracking error: $error'));

      isTracking.value = true;
      print("Tracking started successfully");

      if (totalDistance.value > 0) {
        print(
            "Continuing existing trip with ${totalDistance.value}km traveled");
      }
    } catch (e) {
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
  }

  void _startTimers() {
    _startDurationTimer();
    _startHistoryTimer();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isTracking.value) {
        totalDuration.value++;
      }
    });
  }

  void _startHistoryTimer() {
    _historyUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isTracking.value) {
        _updateHistoryData();
        _calculateCalories();
      }
    });
  }

  void stopTracking() {
    _locationSubscription?.cancel();
    _stopTimers();
    isTracking.value = false;
    _persistMetrics();
    print("Tracking stopped");
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

  void _stopTimers() {
    _durationTimer?.cancel();
    _historyUpdateTimer?.cancel();
    _durationTimer = null;
    _historyUpdateTimer = null;
  }

  void _handleLocationUpdate(loc.LocationData locationData) {
    if (!_isValidLocationData(locationData)) return;

    final newLocation = _LocationPoint.fromLocationData(locationData);
    _locationBuffer.add(newLocation);

    if (_locationBuffer.length > 5) {
      _locationBuffer.removeAt(0);
    }

    _processLocationData(newLocation);
    _updatePathAndElevation(newLocation);
  }

  bool _isValidLocationData(loc.LocationData data) {
    return data.accuracy != null &&
        data.accuracy! <= 15 &&
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
  }

  double _calculateSmoothedSpeed() {
    if (_speedReadings.isEmpty) return 0.0;

    double totalWeight = 0;
    double weightedSum = 0;

    for (int i = 0; i < _speedReadings.length; i++) {
      final weight = i + 1; // Recent speeds have higher weight
      weightedSum += _speedReadings[i] * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
  }

  void _updateDistance(double distanceKm) {
    totalDistance.value += distanceKm;
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
    _updateSpeedHistory(currentSpeed.value);
    _updateDurationHistory(0.5); // 30 seconds in minutes
    _updateCalorieHistory(calculatedCalories.value);
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

    durationHistoryData.add(minutes * 60);
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

  void _updateAverageSpeed() {
    if (totalDistance.value > 0 && totalDuration.value > 0) {
      final durationInHours = totalDuration.value / 3600;
      avgSpeed.value = totalDistance.value / durationInHours;
    } else {
      avgSpeed.value = 0.0;
    }
  }

  Future<String> fetchBatteryInfo(String encodedId) async {
    try {
      bikeEncoded.value = encodedId;
      final response =
          await apiService.get(endpoint: '/v1/metal/status/$encodedId');

      if (response?.statusCode == 200) {
        final batteryData = response!.data['data'];
        batteryPercentage.value = batteryData;
        return batteryData;
      }
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
