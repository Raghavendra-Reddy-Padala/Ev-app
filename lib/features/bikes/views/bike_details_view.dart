import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../shared/components/bike/bike_details_card.dart';
import '../../../../shared/components/bike/trip_control_panel.dart';
import '../../../../shared/components/header/header.dart';
import '../../../../shared/constants/colors.dart';
import '../controller/bike_metrics_controller.dart';
import 'speed_view.dart';
import 'time_view.dart';

class BikeDetailsView extends StatefulWidget {
  const BikeDetailsView({super.key});

  @override
  State<BikeDetailsView> createState() => _BikeDetailsViewState();
}

class _BikeDetailsViewState extends State<BikeDetailsView> with WidgetsBindingObserver {
  final Location _location = Location();
  final TripsController _tripsController = Get.find<TripsController>();
  final LocalStorage _localStorage = Get.find<LocalStorage>();
  LocationData? _currentLocation;
  bool _isLocationServiceEnabled = false;
  bool _isListening = false;
  static const String _backgroundTrackingKey = 'background_location_tracking';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocationTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Don't stop location tracking here if we want background tracking
    // Only stop if there's no active trip
    if (_tripsController.tripId.value.isEmpty) {
      _stopLocationTracking();
    } else {
      // Mark that background tracking should continue
      _localStorage.setBool(_backgroundTrackingKey, true);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('App resumed - checking location tracking status');
        // App came to foreground
        if (!_isListening && _shouldContinueTracking()) {
          _startLocationTracking();
        }
        break;
      case AppLifecycleState.paused:
        print('App paused - continuing background location tracking');
        // App went to background - continue tracking if there's an active trip
        if (_tripsController.tripId.value.isNotEmpty) {
          _localStorage.setBool(_backgroundTrackingKey, true);
          // Keep location tracking active for background updates
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // Handle app termination
        if (_tripsController.tripId.value.isEmpty) {
          _stopLocationTracking();
          _localStorage.setBool(_backgroundTrackingKey, false);
        }
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  bool _shouldContinueTracking() {
    return _localStorage.getBool(_backgroundTrackingKey) ?? false ||
           _tripsController.tripId.value.isNotEmpty;
  }

  Future<void> _initializeLocationTracking() async {
    try {
      // Request all necessary permissions first
      await _requestAllPermissions();

      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('Location service is disabled');
          _showLocationServiceDialog();
          return;
        }
      }

      // Check location permissions
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print('Location permission denied');
          _showPermissionDialog();
          return;
        }
      }

      _isLocationServiceEnabled = true;
      await _startLocationTracking();
    } catch (e) {
      print('Error initializing location tracking: $e');
    }
  }

  Future<void> _requestAllPermissions() async {
    try {
      // Request location permissions
      var locationStatus = await permission_handler.Permission.location.request();
      var locationAlwaysStatus = await permission_handler.Permission.locationAlways.request();
      
      print('Location permission: $locationStatus');
      print('Location always permission: $locationAlwaysStatus');

      // For Android, also request background location permission
      if (Theme.of(context).platform == TargetPlatform.android) {
        var backgroundLocationStatus = await permission_handler.Permission.locationAlways.request();
        print('Background location permission: $backgroundLocationStatus');
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  Future<void> _startLocationTracking() async {
    if (!_isLocationServiceEnabled || _isListening) return;

    try {
      // Enable background mode for location
      await _location.enableBackgroundMode(enable: true);
      
      // Configure location settings for background tracking
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000, // Update every 10 seconds (balance between accuracy and battery)
        distanceFilter: 5, // Update if moved 5 meters
      );

      // Start listening to location changes
      _location.onLocationChanged.listen(
        (LocationData locationData) {
          _onLocationChanged(locationData);
        },
        onError: (error) {
          print('Location tracking error: $error');
        },
      );

      _isListening = true;
      _localStorage.setBool(_backgroundTrackingKey, true);
      print('Background location tracking started');
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }

  void _stopLocationTracking() {
    if (_isListening) {
      _location.enableBackgroundMode(enable: false);
      _location.onLocationChanged.drain();
      _isListening = false;
      _localStorage.setBool(_backgroundTrackingKey, false);
      print('Location tracking stopped');
    }
  }

  Future<void> _onLocationChanged(LocationData locationData) async {
    try {
      if (locationData.latitude == null || locationData.longitude == null) {
        return;
      }

      _currentLocation = locationData;
      
      if (_tripsController.tripId.value.isEmpty) {
        String? storedTripId = _localStorage.getString("tripId");
        if (storedTripId == null || storedTripId.isEmpty) {
          print('No active trip found, stopping location tracking');
          _stopLocationTracking();
          return;
        }
        _tripsController.tripId.value = storedTripId;
      }

      double elevation = locationData.altitude ?? 0.0;

      print('Updating trip location (${DateTime.now()}): ${locationData.latitude}, ${locationData.longitude}');

      bool success = await _tripsController.updateTripLocation(
        tripId: _tripsController.tripId.value,
        lat: locationData.latitude!,
        long: locationData.longitude!,
        elevation: elevation,
      );

      if (success) {
        print('Trip location updated successfully');
        _localStorage.setString('last_location_update', DateTime.now().toIso8601String());
      } else {
        print('Failed to update trip location');
      }
    } catch (e) {
      print('Error in _onLocationChanged: $e');
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Service Required'),
          content: const Text('Please enable location services to track your bike trips.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _location.requestService();
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('Please grant location permission to track your bike trips, including background location access.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                permission_handler.openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Obx(() {
                bool hasActiveTrip = _tripsController.tripId.value.isNotEmpty;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: hasActiveTrip && _isListening 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: hasActiveTrip && _isListening 
                          ? Colors.green
                          : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasActiveTrip && _isListening 
                            ? Icons.location_on 
                            : Icons.location_off,
                        size: 16.sp,
                        color: hasActiveTrip && _isListening 
                            ? Colors.green
                            : Colors.orange,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        hasActiveTrip && _isListening 
                            ? 'Location tracking active'
                            : 'Location tracking inactive',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: hasActiveTrip && _isListening 
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BikeHeader(),
                    SizedBox(height: 20.h),
                    _BikeImage(),
                    SizedBox(height: 20.h),
                    Expanded(child: _BikeMetrics()),
                    SizedBox(height: 20.h),
                    const TripControlPanel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BikeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LocalStorage localStorage = Get.find();
    final cycleId = localStorage.getString('deviceId');
    final isValidCycleId = cycleId != null &&
        cycleId != "null" &&
        cycleId.trim().isNotEmpty &&
        cycleId != "0";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Bike",
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (isValidCycleId) ...[
          SizedBox(height: 4.h),
          Text(
            "Cycle ID: $cycleId",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}

class _BikeImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200.w,
        height: 120.h,
        child: Image.asset('assets/images/bike.png'),
      ),
    );
  }
}

class _BikeMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BikeMetricsController controller = Get.find();

    return Column(
      children: [
        // Current Speed Display
        Obx(() {
          return BikeDetailCard(
            title: "Current Speed",
            value: "${controller.currentSpeed.value.toInt()} km/h",
            icon: Icons.speed,
            iconColor: AppColors.primary,
          );
        }),
        SizedBox(height: 16.h),

        // Metrics Row
        Row(
          children: [
            Expanded(
              child: Obx(() {
                return BikeDetailCard(
                  title: "Time",
                  value: _formatDuration(controller.totalDuration.value),
                  icon: Icons.access_time,
                  iconColor: Colors.blue,
                  onTap: () => Get.to(()=> TimeDetailsView(duration: controller.totalDuration.value))
                );
              }),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() {
                return BikeDetailCard(
                  title: "Distance",
                  value:
                      "${controller.totalDistance.value.toStringAsFixed(2)} km",
                  icon: Icons.route,
                  iconColor: Colors.green,
                  onTap: () => Get.to(()=>SpeedDetailsView(
                        speed: controller.currentSpeed.value.toInt()))
                );
              }),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Battery Display
        Obx(() {
          return BikeDetailCard(
            title: "Battery",
            value: controller.batteryPercentage.value,
            icon: Icons.battery_full,
            isBattery: true,
            batteryPercentage: controller.batteryPercentage.value,
          );
        }),
      ],
    );
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
}