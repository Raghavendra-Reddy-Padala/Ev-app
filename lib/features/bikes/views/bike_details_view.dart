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
    _startLocationTracking();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
   
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