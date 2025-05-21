import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mjollnir/core/navigation/navigation_service.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/authentication/controller/loc_controller.dart';
import 'package:mjollnir/features/authentication/views/auth_view.dart';
import 'package:mjollnir/features/main_page.dart';

class SplashController extends GetxController {
  static SplashController get find => Get.find();

  RxBool animate = false.obs;
  RxBool mapReady = false.obs;
  LatLng? currentLocation;

  @override
  void onInit() {
    super.onInit();
    startAnimation();
  }

  Future<void> startAnimation() async {
    animate.value = true;
    _initializeMap();
    await Future.delayed(const Duration(seconds: 2));
    _navigateToApp();
  }

  void _navigateToApp() {
    if (!Get.isRegistered<LocationController>()) {
      Get.put(LocationController());
    }
    NavigationService.pushReplacementTo(
      LocalStorage().isLoggedIn() ? MainPage() : const AuthView(),
    );
  }

  Future<void> _initializeMap() async {
    try {
      final location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) return;
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          AppLogger.w('Location services disabled');
          return;
        }
      }

      var permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) {
          AppLogger.w('Location permission denied');
          return;
        }
      }

      try {
        final locationData = await location.getLocation().timeout(
              const Duration(seconds: 3),
            );

        currentLocation =
            LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
      } catch (e) {
        AppLogger.w('Location fetch error: $e');
      }

      mapReady.value = true;
    } catch (e) {
      AppLogger.e('Map init error: $e');
    }
  }

  Future<bool> fetchLocation() async {
    try {
      final location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          AppLogger.e('Location service not enabled');
          return false;
        }
      }

      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          AppLogger.e('Location permission denied');
          return false;
        }
      }

      try {
        final locationData = await location.getLocation();
        if (locationData.latitude != null && locationData.longitude != null) {
          currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          return true;
        }
      } catch (e) {
        AppLogger.e('Error getting location: $e');
      }

      return false;
    } catch (e) {
      AppLogger.e('Error fetching location: $e');
      return false;
    }
  }
}
