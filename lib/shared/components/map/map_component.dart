import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../../core/utils/logger.dart';
import '../../constants/constants.dart';
import '../../models/stations/station.dart';

class MapViewController extends GetxController {
  final Rx<LatLng> currentLocation = LatLng(17.4065, 78.4772).obs;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final RxBool isLocationReady = false.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxList<LatLng> locations = <LatLng>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool showMyLocation = true.obs;
  RxString mapStyle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserLocation();
    ever(locations, (_) => _updateMarkers());
  }

  void setMapController(GoogleMapController controller) {
    mapController.value = controller;
    _applyMapStyle();
  }

  void setMapStyle(String style) {
    mapStyle.value = style;
    _applyMapStyle();
  }

  void _applyMapStyle() {
    if (mapController.value != null && mapStyle.value.isNotEmpty) {
      mapController.value!.setMapStyle(mapStyle.value);
    }
  }

  Future<void> fetchUserLocation() async {
    isLoading.value = true;
    try {
      final Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          isLoading.value = false;
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          isLoading.value = false;
          return;
        }
      }

      final LocationData locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        currentLocation.value = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        isLocationReady.value = true;
      }
    } catch (e) {
      AppLogger.e('Error fetching location', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToMyLocation() async {
    if (!isLocationReady.value) {
      await fetchUserLocation();
    }

    if (mapController.value != null) {
      await mapController.value!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation.value,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void goToLocation(LatLng location, {double zoom = 15}) {
    if (mapController.value != null) {
      mapController.value!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: zoom,
          ),
        ),
      );
    }
  }

  void addMarkers(List<Station> stations) {
    final List<LatLng> stationLocations = stations.map((station) {
      final double lat = double.tryParse(station.locationLatitude) ?? 0;
      final double lng = double.tryParse(station.locationLongitude) ?? 0;
      return LatLng(lat, lng);
    }).toList();

    locations.assignAll(stationLocations);
  }

  Future<void> _updateMarkers() async {
    if (locations.isEmpty) return;

    final BitmapDescriptor icon = await _getCustomMarker();
    final Set<Marker> newMarkers = {};

    for (int i = 0; i < locations.length; i++) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(locations[i].toString()),
          position: locations[i],
          icon: icon,
        ),
      );
    }

    markers.assignAll(newMarkers);
  }

  Future<BitmapDescriptor> _getCustomMarker() async {
    const String assetPath = 'assets/images/location.png';

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 50,
        targetHeight: 50,
      );

      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? byteData =
          await fi.image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
      }
    } catch (e) {
      AppLogger.e('Error creating custom marker', error: e);
    }

    return BitmapDescriptor.defaultMarker;
  }
}

class MapView extends StatelessWidget {
  final bool showControls;
  final String? customMapStyle;
  final Function(GoogleMapController)? onMapCreated;
  final Widget? overlay;

  const MapView({
    Key? key,
    this.showControls = true,
    this.customMapStyle,
    this.onMapCreated,
    this.overlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MapViewController controller = Get.find<MapViewController>();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (customMapStyle != null) {
      controller.setMapStyle(customMapStyle!);
    } else {
      controller.setMapStyle(
          isDarkMode ? Constants.darkMapStyle : Constants.lightMapStyle);
    }

    return Obx(() {
      return Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.currentLocation.value,
              zoom: 15,
            ),
            myLocationEnabled: controller.showMyLocation.value,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: controller.markers,
            onMapCreated: (GoogleMapController mapController) {
              controller.setMapController(mapController);
              if (onMapCreated != null) {
                onMapCreated!(mapController);
              }
            },
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (showControls)
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: Column(
                children: [
                  Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.my_location,
                        size: 24.w,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: controller.goToMyLocation,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 24.w,
                      ),
                      onPressed: () {
                        controller.mapController.value?.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Zoom out button
                  Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.remove,
                        size: 24.w,
                      ),
                      onPressed: () {
                        controller.mapController.value?.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (overlay != null) overlay!,
        ],
      );
    });
  }
}
