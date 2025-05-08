import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/api/base/base_controller.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/kalman_filter.dart';
import '../../../main.dart';
import '../../../shared/services/dummy_data_service.dart';

class TripMetricsController extends BaseController {
  final LocalStorage localStorage = Get.find<LocalStorage>();
  final RxDouble currentSpeed = 0.0.obs;
  final RxDouble totalDistance = 0.0.obs;
  final RxDouble totalDuration = 0.0.obs;
  final RxString batteryPercentage = '0'.obs;
  final RxBool isTracking = false.obs;
  final RxString bikeEncoded = ''.obs;
  final RxString bikeID = ''.obs;
  final RxBool isMoving = false.obs;
  final RxString startLocationName = ''.obs;
  final RxString endLocationName = ''.obs;
  final RxList<List<double>> pathPoints = <List<double>>[].obs;

  final RxList<double> speedHistoryData = <double>[].obs;
  final RxList<double> durationHistoryData = <double>[].obs;
  final RxList<DateTime> timePoints = <DateTime>[].obs;
  final RxDouble calculatedCalories = 0.0.obs;
  final RxDouble maxElevation = 0.0.obs;
  final RxDouble lastTripCalories = 0.0.obs;
  final RxDouble avgSpeed = 0.0.obs;
  final RxList<double> calorieHistoryData = <double>[].obs;

  late loc.Location _location;
  final _speedFilter = KalmanFilter();
  final List<_LocationPoint> _locationBuffer = [];
  List<double> speedList = [];
  List<double> elevationList = [];
  final double minDistanceThreshold = 5.0;
  bool isFirstLocationUpdate = true;
  Stopwatch? _stationaryTimer;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  Timer? _durationTimer;
  Timer? _historyUpdateTimer;

  LatLng? startPosition;
  LatLng? endPosition;

  @override
  void onInit() {
    super.onInit();
    _location = loc.Location();
    _initializeMetrics();
  }

  void _initializeMetrics() {
    _loadMetricsFromStorage();
    _initializeHistoryData();
    _updateAverageSpeed();
  }

  Future<void> _loadMetricsFromStorage() async {
    totalDuration.value = (localStorage.getInt('time') ?? 0).toDouble();
    totalDistance.value =
        (localStorage.getDouble('totalDistance') ?? 0.0).toDouble();
    currentSpeed.value =
        (localStorage.getDouble('currentSpeed') ?? 0.0).toDouble();
    pathPoints.value = localStorage.getPathPoints();
  }

  void _initializeHistoryData() {
    final savedSpeedHistory = localStorage.getDoubleList('speedHistory');
    final savedDurationHistory = localStorage.getDoubleList('durationHistory');
    final savedTimePoints = localStorage.getStringList('timePoints');
    final savedCalorieHistory = localStorage.getDoubleList('calorieHistory');

    if (savedCalorieHistory.isNotEmpty) {
      calorieHistoryData.value = savedCalorieHistory;
    } else {
      calorieHistoryData.value = List.generate(7, (index) => 0.0);
    }
    final timePointsList = savedTimePoints ?? [];
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

    calculatedCalories.value = localStorage.getDouble('calories') ?? 0.0;
    maxElevation.value = localStorage.getDouble('maxElevation') ?? 0.0;
    lastTripCalories.value = localStorage.getDouble('lastTripCalories') ?? 0.0;
  }

  void _persistMetrics() {
    localStorage.setInt('time', totalDuration.value.toInt());
    localStorage.setDouble('totalDistance', totalDistance.value);
    localStorage.setDouble('currentSpeed', currentSpeed.value);
    localStorage.setDoubleList('speedHistory', speedHistoryData);
    localStorage.setDoubleList('durationHistory', durationHistoryData);
    localStorage.setDoubleList('calorieHistory', calorieHistoryData);
    localStorage.setStringList('timePoints',
        timePoints.map((time) => time.toIso8601String()).toList());
    localStorage.setDouble('calories', calculatedCalories.value);
    localStorage.setDouble('maxElevation', maxElevation.value);
    localStorage.setDouble('lastTripCalories', lastTripCalories.value);
    localStorage.savePathPoints(pathPoints);
  }

  void _updateAverageSpeed() {
    if (totalDistance.value > 0 && totalDuration.value > 0) {
      double totalMovingTime =
          localStorage.getDouble('totalMovingTime') ?? totalDuration.value;
      if (totalMovingTime < 1) totalMovingTime = totalDuration.value;
      double movingTimeHours = totalMovingTime / 3600;
      avgSpeed.value = currentSpeed.value / movingTimeHours;
    } else {
      avgSpeed.value = 0.0;
    }
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
  }

  void stopTracking() {
    _locationSubscription?.cancel();
    _stopDurationTimer();
    _stopHistoryTimer();
    isTracking.value = false;
    _persistMetrics();
  }

  void pauseTracking() {
    _locationSubscription?.pause();
    _stopDurationTimer();
    _stopHistoryTimer();
  }

  void resumeTracking() {
    _locationSubscription?.resume();
    _startDurationTimer();
    _startHistoryTimer();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isTracking.value) {
        totalDuration.value++;
        _persistMetrics();
      }
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
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
  }

  void updateDurationHistory(double minutes) {
    if (durationHistoryData.length >= 7) {
      durationHistoryData.removeAt(0);
    }
    durationHistoryData.add(minutes * 60);
  }

  void updateCalorieHistory(double newCalories) {
    if (calorieHistoryData.length >= 7) {
      calorieHistoryData.removeAt(0);
    }
    calorieHistoryData.add(newCalories);
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

      final result = await useApiOrDummy(
        apiCall: () async {
          final response =
              await apiService.get(endpoint: '/v1/metal/status/$encodedId');

          if (response != null && response.statusCode == 200) {
            batteryPercentage.value = response.data['data'];
            return response.data['data'];
          }
          return '';
        },
        dummyData: () {
          final dummyData = DummyDataService.getBatteryResponse();
          batteryPercentage.value = dummyData['data'];
          return dummyData['data'];
        },
      );

      return result ?? '';
    } catch (e) {
      handleError(e);
      return '';
    }
  }

  void resetTripData() {
    lastTripCalories.value = calculatedCalories.value;
    localStorage.setDouble('lastTripCalories', lastTripCalories.value);
    totalDistance.value = 0.0;
    totalDuration.value = 0.0;
    speedList.clear();
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
      handleError(e);
    }
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
      handleError(e);
      return false;
    }
  }

  void _updateMetrics(loc.LocationData locationData) {
    if (locationData.accuracy! > 10) return;

    final latitude = locationData.latitude ?? 0.0;
    final longitude = locationData.longitude ?? 0.0;
    final altitude = locationData.altitude ?? 0.0;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final newLocation = _LocationPoint(
      lat: latitude,
      lng: longitude,
      time: timestamp,
      accuracy: locationData.accuracy ?? 0.0,
    );

    _locationBuffer.add(newLocation);
    if (_locationBuffer.length > 5) {
      _locationBuffer.removeAt(0);
    }

    if (_locationBuffer.length >= 2) {
      final currentPoint = _locationBuffer.last;
      final previousPoint = _locationBuffer[_locationBuffer.length - 2];

      final distance = _calculateHaversine(previousPoint, currentPoint);
      if (distance > 0.005) {
        final timeDiffHours =
            (currentPoint.time - previousPoint.time) / 3600000;
        final instantaneousSpeed = distance / timeDiffHours;

        _updateSpeed(instantaneousSpeed);
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

  void _updateSpeed(double newSpeed) {
    if (newSpeed > 45.0) {
      return;
    }

    if (newSpeed < 1.0) {
      if (_stationaryTimer != null &&
          _stationaryTimer!.elapsed.inSeconds >= 5) {
        currentSpeed.value = 0.0;
        speedList.clear();
      } else {
        _stationaryTimer ??= Stopwatch()..start();
      }
      return;
    }

    _stationaryTimer = null;

    speedList.add(newSpeed);
    if (speedList.length > 5) {
      speedList.removeAt(0);
    }

    double smoothedSpeed = _calculateSmoothedSpeed(speedList);
    currentSpeed.value = _speedFilter.update(smoothedSpeed);
  }

  double _calculateSmoothedSpeed(List<double> speeds) {
    if (speeds.isEmpty) return 0.0;

    double totalWeight = 0;
    double weightedSum = 0;

    for (int i = 0; i < speeds.length; i++) {
      double weight = 1.0 / (i + 1);
      weightedSum += speeds[i] * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
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

  _LocationPoint({
    required this.lat,
    required this.lng,
    required this.time,
    required this.accuracy,
  });
}
