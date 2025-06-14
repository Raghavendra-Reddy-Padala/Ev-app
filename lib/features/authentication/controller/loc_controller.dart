import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/home/controller/station_controller.dart';
import 'package:mjollnir/shared/constants/strings.dart';
import 'package:mjollnir/shared/models/stations/station.dart';

class LocationController extends GetxController
    with GetTickerProviderStateMixin {
  Rx<LatLng> initialLocation = const LatLng(17.4065, 78.4772).obs;
  Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  RxBool isLocationReady = false.obs;
  RxBool isMarkersLoading = false.obs;

  // Animation controllers
  late AnimationController _markerAnimationController;
  late AnimationController _cameraAnimationController;

  // Animation values
  RxDouble animationProgress = 0.0.obs;
  RxDouble tiltAnimation = 0.0.obs;
  RxDouble zoomAnimation = 7.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    ever(locations, (_) => _updateMarkersAnimated());
    fetchUserLocation();
  }

  void _initializeAnimations() {
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cameraAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create smooth animation curves
    final Animation<double> markerCurve = CurvedAnimation(
      parent: _markerAnimationController,
      curve: Curves.elasticOut,
    );

    final Animation<double> cameraCurve = CurvedAnimation(
      parent: _cameraAnimationController,
      curve: Curves.easeInOutCubic,
    );

    markerCurve.addListener(() {
      animationProgress.value = markerCurve.value;
    });

    cameraCurve.addListener(() {
      tiltAnimation.value = cameraCurve.value * 60.0;
      zoomAnimation.value = 7.0 + (cameraCurve.value * 4.0);
    });
  }

  RxList<LatLng> locations = <LatLng>[].obs;
  RxSet<Marker> markers = <Marker>{}.obs;

  Future<void> _updateMarkersAnimated() async {
    if (mapController.value == null) return;

    isMarkersLoading.value = true;

    // Reset animation
    _markerAnimationController.reset();

    final BitmapDescriptor customIcon = await _getCustomMarkerWithFallback();

    Set<Marker> newMarkers = locations.asMap().entries.map((entry) {
      int index = entry.key;
      LatLng latLng = entry.value;

      return Marker(
        markerId: MarkerId('${latLng.toString()}_$index'),
        position: latLng,
        icon: customIcon,
        // Add info window for better UX
        infoWindow: InfoWindow(
          title: 'Station ${index + 1}',
          snippet: 'Tap for details',
        ),
        // Add custom marker tap handling
        onTap: () => _onMarkerTapped(latLng),
      );
    }).toSet();

    markers.assignAll(newMarkers);

    // Start marker animation
    await _markerAnimationController.forward();
    isMarkersLoading.value = false;
  }

  void _onMarkerTapped(LatLng position) {
    // Animate to marker with 3D effect
    animateCameraTo3D(
      position,
      zoom: 15.0,
      tilt: 45.0,
      bearing: 30.0,
    );
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> locations) {
    double? minLat, maxLat, minLng, maxLng;

    for (final latLng in locations) {
      if (minLat == null || latLng.latitude < minLat) minLat = latLng.latitude;
      if (maxLat == null || latLng.latitude > maxLat) maxLat = latLng.latitude;
      if (minLng == null || latLng.longitude < minLng)
        minLng = latLng.longitude;
      if (maxLng == null || latLng.longitude > maxLng)
        maxLng = latLng.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  Future<void> fitMapToBoundsAnimated(List<LatLng> locations) async {
    if (mapController.value == null || locations.isEmpty) return;

    // Add user location to the locations list for bounds calculation
    final allLocations = List<LatLng>.from(locations);
    if (initialLocation.value != null) {
      allLocations.add(initialLocation.value);
    }

    final bounds = _boundsFromLatLngList(allLocations);

    // Animate with 3D tilt effect
    await Future.wait([
      mapController.value!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 120.0),
      ),
      _animateTilt(45.0), // Add 3D tilt
    ]);
  }

  Future<void> _animateTilt(double targetTilt) async {
    _cameraAnimationController.reset();
    await _cameraAnimationController.forward();
  }

  Future<void> markLocationsAnimated(List<LatLng> locations) async {
    final GoogleMapController? controller = mapController.value;
    if (controller == null) return;

    isMarkersLoading.value = true;

    // Clear existing markers with fade out effect
    markers.clear();
    await Future.delayed(const Duration(milliseconds: 200));

    final BitmapDescriptor customIcon = await _getCustomMarkerWithFallback();

    // Create markers with staggered animation
    Set<Marker> newMarkers = {};
    for (int i = 0; i < locations.length; i++) {
      final latLng = locations[i];
      newMarkers.add(Marker(
        markerId: MarkerId('${latLng.toString()}_$i'),
        position: latLng,
        icon: customIcon,
        infoWindow: InfoWindow(
          title: 'Station ${i + 1}',
          snippet: 'Tap to zoom in',
        ),
        onTap: () => _onMarkerTapped(latLng),
      ));

      // Staggered marker appearance
      if (i % 5 == 0) {
        markers.assignAll(newMarkers);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    markers.assignAll(newMarkers);
    await fitMapToBoundsAnimated(locations);

    // Start entrance animation
    _markerAnimationController.forward();
    isMarkersLoading.value = false;
    update();
  }

  Future<BitmapDescriptor> _getCustomMarkerWithFallback() async {
    try {
      // Try to load custom marker
      final ByteData data =
          await rootBundle.load('assets/images/tmp/pointer.png');
      final Uint8List bytes = data.buffer.asUint8List();

      // Create resized marker for better performance
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 120,
        targetHeight: 120,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ByteData? resizedData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (resizedData != null) {
        return BitmapDescriptor.fromBytes(resizedData.buffer.asUint8List());
      }
    } catch (e) {
      AppLogger.e('Error loading custom marker: $e');
    }

    // Fallback to default marker with custom color
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  void animateCameraTo3D(
    LatLng newLocation, {
    double zoom = 12.0,
    double tilt = 60.0,
    double bearing = 0.0,
  }) {
    mapController.value?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newLocation,
          zoom: zoom,
          tilt: tilt,
          bearing: bearing,
        ),
      ),
    );
  }

  Future<void> goToUserLocationAnimated() async {
    Location location = Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception("Location services are disabled.");
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception("Location permissions are denied.");
        }
      }

      LocationData locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        final newLocation =
            LatLng(locationData.latitude!, locationData.longitude!);

        // Animate with 3D effect
        animateCameraTo3D(
          newLocation,
          zoom: 15.0,
          tilt: 45.0,
          bearing: locationData.heading ?? 0.0,
        );
      } else {
        throw Exception("Unable to fetch location coordinates.");
      }
    } catch (e) {
      AppLogger.e("Error fetching user location: $e");
      throw Exception("Error fetching user location: $e");
    }
  }

  Future<void> fetchUserLocation() async {
    Location location = Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      LocationData locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        initialLocation.value =
            LatLng(locationData.latitude!, locationData.longitude!);
        isLocationReady.value = true;
      }
    } catch (e) {
      AppLogger.e("Error fetching location: $e");
    }
  }

  void resetMapView() {
    animateCameraTo3D(
      initialLocation.value,
      zoom: 7.0,
      tilt: 60.0,
      bearing: 45.0,
    );
  }

  @override
  void onClose() {
    _markerAnimationController.dispose();
    _cameraAnimationController.dispose();
    mapController.value?.dispose();
    super.onClose();
  }
}

class MapsView extends StatefulWidget {
  const MapsView({super.key});

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> with TickerProviderStateMixin {
  final LocationController locationController = Get.find();
  final _nearbyStationsController = Get.find<StationController>();
  final Set<Marker> _markers = {};

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initializeFabAnimation();
    _initializeMap();
  }

  void _initializeFabAnimation() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  void _initializeMap() async {
    await locationController.fetchUserLocation();
    await _fetchStations();

    ever(_nearbyStationsController.nearbyStations, (stations) {
      if (mounted) {
        _updateMarkersAnimated(stations);
      }
    });
  }

  Future<void> _fetchStations() async {
    await _nearbyStationsController.fetchNearbyStations(
      locationController.initialLocation.value.latitude,
      locationController.initialLocation.value.longitude,
    );
  }

  void _updateMarkersAnimated(List<Station> stations) async {
    if (!mounted) return;

    setState(() {
      _markers.clear();
    });

    // Load custom marker with fallback
    final customIcon = await locationController._getCustomMarkerWithFallback();

    // Add markers with staggered animation
    for (int i = 0; i < stations.length; i++) {
      final station = stations[i];
      await Future.delayed(Duration(milliseconds: i * 50));

      if (mounted) {
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(station.id),
            position: LatLng(
              double.parse(station.locationLatitude),
              double.parse(station.locationLongitude),
            ),
            icon: customIcon,
            infoWindow: InfoWindow(
              title: station.name,
              snippet:
                  'Capacity: ${station.currentCapacity}/${station.capacity}',
            ),
            onTap: () => _onStationMarkerTapped(station),
          ));
        });
      }
    }
  }

  void _onStationMarkerTapped(Station station) {
    final position = LatLng(
      double.parse(station.locationLatitude),
      double.parse(station.locationLongitude),
    );

    locationController.animateCameraTo3D(
      position,
      zoom: 16.0,
      tilt: 45.0,
      bearing: 30.0,
    );

    // Show station details with animation
    _showStationDetails(station);
  }

  void _showStationDetails(Station station) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 20),
            ),
            Text(
              station.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Capacity: ${station.currentCapacity}/${station.capacity}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getMapStyle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? MapStyles.customDark
        : MapStyles.customLight;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!locationController.isLocationReady.value) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading map...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      }

      return Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: locationController.initialLocation.value,
              zoom: 7,
              tilt: 60,
              bearing: 45,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            markers: {...locationController.markers, ..._markers},
            onMapCreated: (GoogleMapController controller) async {
              locationController.mapController.value = controller;
              await controller.setMapStyle(_getMapStyle(context));

              // Fetch and display stations with animation
              await _nearbyStationsController.fetchAllStations();
              final stationLocations = _nearbyStationsController.stations
                  .map((station) => LatLng(
                        double.parse(station.locationLatitude),
                        double.parse(station.locationLongitude),
                      ))
                  .toList();

              await locationController.markLocationsAnimated(stationLocations);
            },
            onCameraMove: (CameraPosition position) {
              // Optional: Add camera move feedback
            },
          ),

          // Animated loading overlay
          if (locationController.isMarkersLoading.value)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading stations...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Animated FAB
          Positioned(
            bottom: 20,
            right: 20,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                heroTag: "locationFab",
                onPressed: locationController.goToUserLocationAnimated,
                child: const Icon(Icons.my_location),
              ),
            ),
          ),

          // Reset view FAB
          Positioned(
            bottom: 90,
            right: 20,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                heroTag: "resetFab",
                mini: true,
                onPressed: locationController.resetMapView,
                child: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }
}
