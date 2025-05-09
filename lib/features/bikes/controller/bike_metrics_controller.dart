import 'dart:async';
import 'dart:math';
import 'dart:collection';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/kalman_filter.dart';
import '../../../main.dart';
import '../../account/controllers/trips_controller.dart';

class BikeMetricsController extends GetxController {
  late loc.Location _location;
  final LocalStorage localStorage = Get.find<LocalStorage>();

  var bikeSubscribed = false.obs;
  var currentSpeed = 0.0.obs;
  var totalDistance = 0.0.obs;
  var totalDuration = 0.0.obs;
  var batteryPercentage = '0'.obs;
  var isTracking = false.obs;
  var bikeEncoded = ''.obs;
  var bikeID = ''.obs;
  var isMoving = false.obs;

  final TripsController _tripsController = Get.find<TripsController>();

  final RxList<double> speedHistoryData = <double>[].obs;
  final RxList<double> durationHistoryData = <double>[].obs;
  final RxList<DateTime> timePoints = <DateTime>[].obs;
  final RxDouble calculatedCalories = 0.0.obs;
  final RxDouble maxElevation = 0.0.obs;
  final RxDouble lastTripCalories = 0.0.obs;
  final RxDouble avgSpeed = 0.0.obs;
  final RxList<double> calorieHistoryData = <double>[].obs;

  RxList<List<double>> pathPoints = <List<double>>[].obs;
  RxString startLocationName = ''.obs;
  RxString endLocationName = ''.obs;
  LatLng? startPosition;
  LatLng? endPosition;

  Stopwatch? _stationaryTimer;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _durationTimer;
  Timer? _historyUpdateTimer;

  final _speedFilter = KalmanFilter();
  final List<_LocationPoint> _locationBuffer = [];
  final Queue<double> _speedReadings = Queue<double>();
  final int _maxReadingsToAverage = 5;

  List<double> speedList = [];
  List<double> elevationList = [];
  final double minDistanceThreshold = 5.0;
  final double minSpeedThreshold = 0.5;
  final double minAccelerationThreshold = 0.1;
  bool isFirstLocationUpdate = true;
  int _lastRecordTimestamp = 0;

  final Rx<Position?> currentPosition = Rx<Position?>(null);

  @override
  Future<void> onInit() async {
    super.onInit();
    _location = loc.Location();
    await _loadMetricsFromStorage();
    _initializeHistoryData();
    _updateAverageSpeed();
    _startSensors();
  }

  void _startSensors() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final acceleration =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (acceleration < minAccelerationThreshold &&
          currentSpeed.value < minSpeedThreshold) {
        _addSpeedReading(0.0);
        _updateSmoothedSpeed();
      }
    });
  }

  void updateLocation(Position position) async {
    currentPosition.value = position;

    await _tripsController.putTripLocation(
      tripId: _tripsController.tripId.toString(),
      lat: position.latitude,
      long: position.longitude,
      elevation: position.altitude,
    );
  }

  void _updateAverageSpeed() {
    if (totalDistance.value > 0 && totalDuration.value > 0) {
      double totalMovingTime =
          localStorage.getDouble('totalMovingTime') ?? totalDuration.value;

      if (totalMovingTime < 1) totalMovingTime = totalDuration.value;

      double movingTimeHours = totalMovingTime / 3600;
      avgSpeed.value = totalDistance.value / movingTimeHours;
    } else {
      avgSpeed.value = 0.0;
    }
  }

  void _initializeHistoryData() {
    final savedSpeedHistory = localStorage.getDoubleList("speedHistory");
    final savedDurationHistory = localStorage.getDoubleList("durationHistory");
    final savedTimePoints = localStorage.getStringList("timePoints");
    final savedCalorieHistory = localStorage.getDoubleList("calorieHistory");
    final timePointsList = savedTimePoints ?? [];

    if (savedCalorieHistory.isNotEmpty) {
      calorieHistoryData.value = savedCalorieHistory;
    } else {
      calorieHistoryData.value = List.generate(7, (index) => 0.0);
    }

    if (timePointsList.isNotEmpty) {
      timePoints.value = timePointsList
          .map((timeStr) => DateTime.tryParse(timeStr) ?? DateTime.now())
          .toList();
    } else {
      final now = DateTime.now();
      timePoints.value = List.generate(
          7, (index) => now.subtract(Duration(minutes: (6 - index) * 10)));
    }

    if (savedSpeedHistory.isNotEmpty) {
      speedHistoryData.value = savedSpeedHistory;
    } else {
      speedHistoryData.value = List.generate(7, (index) => 0.0);
    }

    if (savedDurationHistory.isNotEmpty) {
      durationHistoryData.value = savedDurationHistory;
    } else {
      durationHistoryData.value = List.generate(7, (index) => 0.0);
    }

    calculatedCalories.value = localStorage.getDouble("calories") ?? 0.0;
    maxElevation.value = localStorage.getDouble("maxElevation") ?? 0.0;
    lastTripCalories.value = localStorage.getDouble("lastTripCalories") ?? 0.0;
  }

  Future<void> _loadMetricsFromStorage() async {
    totalDuration.value = (localStorage.getTime() ?? 0).toDouble();
    totalDistance.value =
        (localStorage.getDouble("totalDistance") ?? 0.0).toDouble();
    currentSpeed.value =
        (localStorage.getDouble("currentSpeed") ?? 0.0).toDouble();
  }

  void _persistMetrics() {
    localStorage.setTime(totalDuration.value.toInt());
    localStorage.setDouble("totalDistance", totalDistance.value);
    localStorage.setDouble("currentSpeed", currentSpeed.value);
    localStorage.setDoubleList("speedHistory", speedHistoryData);
    localStorage.setDoubleList("durationHistory", durationHistoryData);
    localStorage.setDoubleList("calorieHistory", calorieHistoryData);

    localStorage.setStringList("timePoints",
        timePoints.map((time) => time.toIso8601String()).toList());

    localStorage.setDouble("calories", calculatedCalories.value);
    localStorage.setDouble("maxElevation", maxElevation.value);
    localStorage.setDouble("lastTripCalories", lastTripCalories.value);
  }

  @override
  void onReady() {
    super.onReady();

    totalDuration.listen((val) {
      _persistMetrics();
      _updateAverageSpeed();
    });

    currentSpeed.listen((_) => _persistMetrics());
    speedHistoryData.listen((_) => _persistMetrics());
    durationHistoryData.listen((_) => _persistMetrics());
    timePoints.listen((_) => _persistMetrics());
    calculatedCalories.listen((_) => _persistMetrics());
    maxElevation.listen((_) => _persistMetrics());
    lastTripCalories.listen((_) => _persistMetrics());
    calorieHistoryData.listen((_) => _persistMetrics());
  }

  void updateCalorieHistory(double newCalories) {
    if (calorieHistoryData.length >= 7) {
      calorieHistoryData.removeAt(0);
    }

    calorieHistoryData.add(newCalories);
  }

  Future<void> startTracking() async {
    if (!await _requestLocationPermissions()) return;

    pathPoints.clear();
    localStorage.savePathPoints(pathPoints);
    localStorage.saveLocationList([]);
    isFirstLocationUpdate = true;

    _location.changeSettings(
      interval: 2000,
      distanceFilter: 5,
      accuracy: loc.LocationAccuracy.high,
    );

    _startDurationTimer();
    _startHistoryTimer();

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      _updateMetrics(locationData);
    });

    isTracking.value = true;
    print("Tracking started");
  }

  void stopTracking() {
    _locationSubscription?.cancel();
    _stopDurationTimer();
    _stopHistoryTimer();
    isTracking.value = false;

    _persistMetrics();
    print("Tracking stopped");
  }

  void pauseTracking() {
    _locationSubscription?.pause();
    _stopDurationTimer();
    _stopHistoryTimer();
    print("Tracking paused");
  }

  void resumeTracking() {
    _locationSubscription?.resume();
    _startDurationTimer();
    _startHistoryTimer();
    print("Tracking resumed");
  }

  void _startHistoryTimer() {
    _historyUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isTracking.value) {
        updateSpeedHistory(currentSpeed.value);
        updateDurationHistory(0.5);
        calculateCalories();
      }
    });
  }

  void _stopHistoryTimer() {
    _historyUpdateTimer?.cancel();
    _historyUpdateTimer = null;
  }

  void updateSpeedHistory(double newSpeed) {
    if (speedHistoryData.length >= 7) {
      speedHistoryData.removeAt(0);
      timePoints.removeAt(0);
    }

    speedHistoryData.add(newSpeed);
    timePoints.add(DateTime.now());

    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (currentTimestamp - _lastRecordTimestamp >= 60 * 1000 &&
        isTracking.value) {
      _lastRecordTimestamp = currentTimestamp;
    }
  }

  void updateDurationHistory(double minutes) {
    if (durationHistoryData.length >= 7) {
      durationHistoryData.removeAt(0);
    }

    durationHistoryData.add(minutes * 60);
  }

  void calculateCalories() {
    double met;

    if (currentSpeed.value < 8) {
      met = 3.0;
    } else if (currentSpeed.value < 16) {
      met = 4.0;
    } else if (currentSpeed.value < 20) {
      met = 6.0;
    } else if (currentSpeed.value < 25) {
      met = 8.0;
    } else if (currentSpeed.value < 30) {
      met = 10.0;
    } else {
      met = 12.0;
    }

    double elevationFactor = 1.0;
    if (elevationList.length >= 10) {
      List<double> recentElevations =
          elevationList.sublist(elevationList.length - 10);
      double elevationChange = recentElevations.last - recentElevations.first;

      if (elevationChange > 5) {
        elevationFactor = 1.2;
      } else if (elevationChange < -5) {
        elevationFactor = 0.9;
      }
    }

    double userWeight = localStorage.getDouble('userWeight') ?? 70.0;
    double durationInHours = totalDuration.value / 3600;
    calculatedCalories.value =
        met * userWeight * durationInHours * elevationFactor;
    lastTripCalories.value = calculatedCalories.value;

    updateCalorieHistory(calculatedCalories.value);
  }

  Future<String> fetchBatteryInfo(String encodedId) async {
    try {
      bikeEncoded.value = encodedId;
      final response =
          await apiService.get(endpoint: '/v1/metal/status/$encodedId');
      print(response.data);
      if (response.statusCode == 200) {
        batteryPercentage.value = response.data['data'];
        return response.data['data'];
      }
    } catch (e) {
      print(e);
    }
    return '';
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
    speedList.clear();
    _speedReadings.clear();
    currentSpeed.value = 0.0;
    elevationList.clear();
    maxElevation.value = 0.0;
    calculatedCalories.value = 0.0;
    speedHistoryData.value = List.generate(7, (index) => 0.0);
    durationHistoryData.value = List.generate(7, (index) => 0.0);
    calorieHistoryData.value = List.generate(7, (index) => 0.0);
    final now = DateTime.now();
    timePoints.value = List.generate(
        7, (index) => now.subtract(Duration(minutes: (6 - index) * 10)));
    _stopDurationTimer();
    _stopHistoryTimer();
    _persistMetrics();
    _lastRecordTimestamp = 0;
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isTracking.value) {
        totalDuration.value++;
      }
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  Future<bool> _requestLocationPermissions() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return false;
        }
      }

      var permissionStatus = await _location.hasPermission();
      if (permissionStatus == loc.PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != loc.PermissionStatus.granted) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print("Error requesting location permissions: $e");
      return false;
    }
  }

  void _addSpeedReading(double speed) {
    if (speed > 50.0) return;

    _speedReadings.add(speed);
    if (_speedReadings.length > _maxReadingsToAverage) {
      _speedReadings.removeFirst();
    }
  }

  void _updateSmoothedSpeed() {
    if (_speedReadings.isEmpty) return;

    double totalWeight = 0;
    double weightedSum = 0;

    int weight = 1;
    for (double speed in _speedReadings) {
      weightedSum += speed * weight;
      totalWeight += weight;
      weight++;
    }

    double smoothedSpeed = weightedSum / totalWeight;

    if (smoothedSpeed < 6.0) {
      smoothedSpeed = (smoothedSpeed * 10).round() / 10;
    }

    currentSpeed.value = _speedFilter.update(smoothedSpeed);
  }

  bool _isStationary(double speed, double accuracy) {
    return speed < minSpeedThreshold && accuracy > 15.0;
  }

  void _updateMetrics(loc.LocationData locationData) {
    if (locationData.accuracy != null && locationData.accuracy! > 15) return;

    final latitude = locationData.latitude ?? 0.0;
    final longitude = locationData.longitude ?? 0.0;
    final altitude = locationData.altitude ?? 0.0;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final newLocation = _LocationPoint(
      lat: latitude,
      lng: longitude,
      time: timestamp,
      accuracy: locationData.accuracy ?? 0.0,
      altitude: altitude,
    );

    _locationBuffer.add(newLocation);
    if (_locationBuffer.length > 5) {
      _locationBuffer.removeAt(0);
    }

    if (_locationBuffer.length >= 2) {
      final currentPoint = _locationBuffer.last;
      final previousPoint = _locationBuffer[_locationBuffer.length - 2];

      final distance = _calculateHaversine(previousPoint, currentPoint) * 1000;
      final timeDiffSeconds = (currentPoint.time - previousPoint.time) / 1000;

      if (timeDiffSeconds > 0) {
        double speedKmPerHour = (distance / timeDiffSeconds) * 3.6;

        if (distance < minDistanceThreshold) {
          speedKmPerHour = 0.0;
        }

        if (_isStationary(speedKmPerHour, locationData.accuracy ?? 100.0)) {
          speedKmPerHour = 0.0;
        }

        _addSpeedReading(speedKmPerHour);
        _updateSmoothedSpeed();

        if (speedKmPerHour > minSpeedThreshold &&
            distance > minDistanceThreshold / 1000) {
          final elevationChange =
              currentPoint.altitude - previousPoint.altitude;
          final correctedDistance =
              sqrt(pow(distance, 2) + pow(elevationChange, 2));
          totalDistance.value += correctedDistance / 1000;
        }
      }
    }

    if (isFirstLocationUpdate) {
      startPosition = LatLng(latitude, longitude);
      getLocationName(latitude, longitude, true);
      isFirstLocationUpdate = false;
    }

    endPosition = LatLng(latitude, longitude);
    pathPoints.add([latitude, longitude]);
    localStorage.savePathPoints(pathPoints);

    elevationList.add(altitude);
    if (altitude > maxElevation.value) {
      maxElevation.value = altitude;
    }

    final locations = localStorage.getLocationList();

    if (!isFirstLocationUpdate && locations.isNotEmpty) {
      final lastLocation = locations.last;
      final lastLatitude = lastLocation[0];
      final lastLongitude = lastLocation[1];

      final distance = _calculateDistance(
        lastLatitude,
        lastLongitude,
        latitude,
        longitude,
      );

      if (distance > (minDistanceThreshold / 1000)) {
        totalDistance.value += distance;
      }
    }

    locations.add([latitude, longitude]);
    localStorage.saveLocationList(locations);
  }

  Future<void> getLocationName(
      double latitude, double longitude, bool isStartLocation) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String locationName = '${place.street}, ${place.locality}';

        if (isStartLocation) {
          startLocationName.value = locationName;
        } else {
          endLocationName.value = locationName;
        }
      }
    } catch (e) {
      print("Error getting location name: $e");
    }
  }

  double _calculateHaversine(_LocationPoint p1, _LocationPoint p2) {
    const double earthRadius = 6371.0;

    final double lat1 = _degreesToRadians(p1.lat);
    final double lon1 = _degreesToRadians(p1.lng);
    final double lat2 = _degreesToRadians(p2.lat);
    final double lon2 = _degreesToRadians(p2.lng);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0;

    final double lat1Rad = _degreesToRadians(lat1);
    final double lat2Rad = _degreesToRadians(lat2);
    final double deltaLat = _degreesToRadians(lat2 - lat1);
    final double deltaLon = _degreesToRadians(lon2 - lon1);

    final double a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        (cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    if (elevationList.length >= 2) {
      double elevationDiff =
          elevationList.last - elevationList[elevationList.length - 2];
      if (elevationDiff != 0) {
        double horizontalDistance = distance;
        double elevationChangeKm = elevationDiff / 1000;
        distance = sqrt(pow(horizontalDistance, 2) + pow(elevationChangeKm, 2));
      }
    }

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _durationTimer?.cancel();
    _historyUpdateTimer?.cancel();
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
}
