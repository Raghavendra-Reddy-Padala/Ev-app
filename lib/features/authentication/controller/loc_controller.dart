import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
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
  RxBool showPaths = false.obs;

  // Animation controllers
  late AnimationController _markerAnimationController;
  late AnimationController _cameraAnimationController;
  late AnimationController _pathAnimationController;

  // Animation values
  RxDouble animationProgress = 0.0.obs;
  RxDouble tiltAnimation = 0.0.obs;
  RxDouble zoomAnimation = 7.0.obs;
  RxDouble pathAnimationProgress = 0.0.obs;

  // Path management
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  RxSet<Marker> markers = <Marker>{}.obs;
  RxList<LatLng> locations = <LatLng>[].obs;

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

    _pathAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    final Animation<double> markerCurve = CurvedAnimation(
      parent: _markerAnimationController,
      curve: Curves.elasticOut,
    );

    final Animation<double> cameraCurve = CurvedAnimation(
      parent: _cameraAnimationController,
      curve: Curves.easeInOutCubic,
    );

    final Animation<double> pathCurve = CurvedAnimation(
      parent: _pathAnimationController,
      curve: Curves.easeInOutQuart,
    );

    markerCurve.addListener(() {
      animationProgress.value = markerCurve.value;
    });

    cameraCurve.addListener(() {
      tiltAnimation.value = cameraCurve.value * 60.0;
      zoomAnimation.value = 7.0 + (cameraCurve.value * 4.0);
    });

    pathCurve.addListener(() {
      pathAnimationProgress.value = pathCurve.value;
    });
  }

  Future<void> _updateMarkersAnimated() async {
    if (mapController.value == null) return;

    isMarkersLoading.value = true;
    _markerAnimationController.reset();

    final BitmapDescriptor customIcon = await _getCustomMarkerWithFallback();

    Set<Marker> newMarkers = locations.asMap().entries.map((entry) {
      int index = entry.key;
      LatLng latLng = entry.value;

      return Marker(
        markerId: MarkerId('${latLng.toString()}_$index'),
        position: latLng,
        icon: customIcon,
        infoWindow: InfoWindow(
          title: 'Station ${index + 1}',
          snippet: 'Tap for details',
        ),
        onTap: () => _onMarkerTapped(latLng, index),
      );
    }).toSet();

    markers.assignAll(newMarkers);
    await _markerAnimationController.forward();
    isMarkersLoading.value = false;
  }

  void _onMarkerTapped(LatLng position, int index) {
    // Create path to this specific station
    _createAnimatedPathToStation(position, index);

    // Animate camera with proper tilt
    _animateCameraToStation(position);
  }

  void _animateCameraToStation(LatLng position) async {
    if (mapController.value == null) return;

    // First, animate to the station with a nice 3D perspective
    await mapController.value!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15.0,
          tilt: 45.0,
          bearing: 30.0,
        ),
      ),
    );

    // Then apply additional tilt animation
    _cameraAnimationController.reset();
    await _cameraAnimationController.forward();
  }

  void _createAnimatedPathToStation(LatLng destination, int stationIndex) {
    if (!isLocationReady.value) return;

    // Generate smooth curved path
    final pathPoints = _generateCurvedPath(
      initialLocation.value,
      destination,
      curveIntensity: 0.3,
    );

    // Clear existing paths
    polylines.clear();

    // Create animated polyline
    _animatePathDrawing(pathPoints, stationIndex);
  }

  List<LatLng> _generateCurvedPath(LatLng start, LatLng end,
      {double curveIntensity = 0.2}) {
    List<LatLng> points = [];

    // Calculate midpoint with offset for curve
    double midLat = (start.latitude + end.latitude) / 2;
    double midLng = (start.longitude + end.longitude) / 2;

    // Add curve offset based on distance
    double distance = _calculateDistance(start, end);
    double offsetLat = (end.longitude - start.longitude) * curveIntensity;
    double offsetLng = (start.latitude - end.latitude) * curveIntensity;

    LatLng curvePoint = LatLng(midLat + offsetLat, midLng + offsetLng);

    // Generate smooth curve using quadratic Bézier
    int segments = 50;
    for (int i = 0; i <= segments; i++) {
      double t = i / segments;
      LatLng point = _quadraticBezier(start, curvePoint, end, t);
      points.add(point);
    }

    return points;
  }

  LatLng _quadraticBezier(LatLng p0, LatLng p1, LatLng p2, double t) {
    double lat = math.pow(1 - t, 2) * p0.latitude +
        2 * (1 - t) * t * p1.latitude +
        math.pow(t, 2) * p2.latitude;
    double lng = math.pow(1 - t, 2) * p0.longitude +
        2 * (1 - t) * t * p1.longitude +
        math.pow(t, 2) * p2.longitude;
    return LatLng(lat, lng);
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters
    double lat1Rad = start.latitude * math.pi / 180;
    double lat2Rad = end.latitude * math.pi / 180;
    double deltaLatRad = (end.latitude - start.latitude) * math.pi / 180;
    double deltaLngRad = (end.longitude - start.longitude) * math.pi / 180;

    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  void _animatePathDrawing(List<LatLng> fullPath, int stationIndex) async {
    _pathAnimationController.reset();

    // Create the polyline with gradient effect
    final polyline = Polyline(
      polylineId: PolylineId('path_to_station_$stationIndex'),
      points: fullPath,
      color: Colors.blue,
      width: 6,
      patterns: [
        PatternItem.gap(10),
        PatternItem.dash(20),
      ],
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );

    // Create a professional black collar outline
    final outlinePolyline = Polyline(
      polylineId: PolylineId('outline_path_to_station_$stationIndex'),
      points: fullPath,
      color: Colors.black87,
      width: 8,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );

    polylines.assignAll({outlinePolyline, polyline});
    showPaths.value = true;

    await _pathAnimationController.forward();
  }

  void togglePathsToAllStations() {
    if (showPaths.value) {
      // Hide paths
      polylines.clear();
      showPaths.value = false;
    } else {
      // Show paths to all stations
      _createPathsToAllStations();
    }
  }

  void _createPathsToAllStations() async {
    if (!isLocationReady.value || locations.isEmpty) return;

    polylines.clear();
    Set<Polyline> allPolylines = {};

    for (int i = 0; i < locations.length; i++) {
      final destination = locations[i];
      final pathPoints = _generateCurvedPath(
        initialLocation.value,
        destination,
        curveIntensity: 0.2,
      );

      // Create outline (black collar)
      final outlinePolyline = Polyline(
        polylineId: PolylineId('outline_$i'),
        points: pathPoints,
        color: Colors.black87,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      );

      // Create main path with color based on distance
      final distance = _calculateDistance(initialLocation.value, destination);
      final pathColor = _getPathColorByDistance(distance);

      final mainPolyline = Polyline(
        polylineId: PolylineId('main_$i'),
        points: pathPoints,
        color: pathColor,
        width: 3,
        patterns: [
          PatternItem.gap(8),
          PatternItem.dash(15),
        ],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      );

      allPolylines.addAll({outlinePolyline, mainPolyline});
    }

    polylines.assignAll(allPolylines);
    showPaths.value = true;
  }

  Color _getPathColorByDistance(double distance) {
    // Color code based on distance: Green (close) -> Yellow -> Red (far)
    if (distance < 1000) return Colors.green.shade600;
    if (distance < 5000) return Colors.orange.shade600;
    return Colors.red.shade600;
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

    final allLocations = List<LatLng>.from(locations);
    if (initialLocation.value != null) {
      allLocations.add(initialLocation.value);
    }

    final bounds = _boundsFromLatLngList(allLocations);

    // Animate camera to bounds first
    await mapController.value!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 120.0),
    );

    // Then apply tilt animation
    await Future.delayed(const Duration(milliseconds: 500));
    await _animateTiltSequence();
  }

  Future<void> _animateTiltSequence() async {
    if (mapController.value == null) return;

    // Wait a moment for the bounds animation to complete
    await Future.delayed(const Duration(milliseconds: 800));

    // Get current visible region to determine center
    final visibleRegion = await mapController.value!.getVisibleRegion();
    final center = LatLng(
      (visibleRegion.southwest.latitude + visibleRegion.northeast.latitude) / 2,
      (visibleRegion.southwest.longitude + visibleRegion.northeast.longitude) /
          2,
    );

    // Animate to tilted view
    await mapController.value!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: center,
          zoom: 11.0,
          tilt: 45.0,
          bearing: 30.0,
        ),
      ),
    );

    // Run additional smooth tilt animation
    _cameraAnimationController.reset();
    await _cameraAnimationController.forward();
  }

  Future<void> _animateTilt(double targetTilt) async {
    _cameraAnimationController.reset();
    await _cameraAnimationController.forward();
  }

  Future<void> markLocationsAnimated(List<LatLng> locations) async {
    final GoogleMapController? controller = mapController.value;
    if (controller == null) return;

    isMarkersLoading.value = true;
    markers.clear();
    polylines.clear();
    showPaths.value = false;

    await Future.delayed(const Duration(milliseconds: 200));

    final BitmapDescriptor customIcon = await _getCustomMarkerWithFallback();
    Set<Marker> newMarkers = {};

    for (int i = 0; i < locations.length; i++) {
      final latLng = locations[i];
      newMarkers.add(Marker(
        markerId: MarkerId('${latLng.toString()}_$i'),
        position: latLng,
        icon: customIcon,
        infoWindow: InfoWindow(
          title: 'Station ${i + 1}',
          snippet: 'Tap to show route',
        ),
        onTap: () => _onMarkerTapped(latLng, i),
      ));

      if (i % 5 == 0) {
        markers.assignAll(newMarkers);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    markers.assignAll(newMarkers);
    this.locations.assignAll(locations);

    // Fit bounds and then apply tilt
    await fitMapToBoundsAnimated(locations);

    _markerAnimationController.forward();
    isMarkersLoading.value = false;
    update();
  }

  Future<BitmapDescriptor> _getCustomMarkerWithFallback() async {
    try {
      final ByteData data =
          await rootBundle.load('assets/images/tmp/pointer.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 60,
        targetHeight: 60,
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
        initialLocation.value = newLocation;

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
    polylines.clear();
    showPaths.value = false;
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
    _pathAnimationController.dispose();
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

    final customIcon = await locationController._getCustomMarkerWithFallback();

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

    // Create animated path to this station
    locationController._createAnimatedPathToStation(
        position, int.parse(station.id));

    // Animate camera to station
    locationController._animateCameraToStation(position);

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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      locationController.togglePathsToAllStations();
                    },
                    icon: Icon(locationController.showPaths.value
                        ? Icons.visibility_off
                        : Icons.route),
                    label: Text(locationController.showPaths.value
                        ? 'Hide All Routes'
                        : 'Show All Routes'),
                  ),
                ),
              ],
            ),
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
            polylines: locationController.polylines,
            onMapCreated: (GoogleMapController controller) async {
              locationController.mapController.value = controller;
              await controller.setMapStyle(_getMapStyle(context));

              await _nearbyStationsController.fetchAllStations();
              final stationLocations = _nearbyStationsController.stations
                  .map((station) => LatLng(
                        double.parse(station.locationLatitude),
                        double.parse(station.locationLongitude),
                      ))
                  .toList();

              await locationController.markLocationsAnimated(stationLocations);
            },
            onCameraMove: (CameraPosition position) {},
          ),

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

          // Routes toggle button
          Positioned(
            bottom: 160,
            right: 20,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                heroTag: "routesFab",
                mini: true,
                backgroundColor: locationController.showPaths.value
                    ? Colors.red.shade400
                    : Colors.blue.shade400,
                onPressed: locationController.togglePathsToAllStations,
                child: Icon(
                  locationController.showPaths.value
                      ? Icons.visibility_off
                      : Icons.route,
                  color: Colors.white,
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
