import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/home/controller/station_controller.dart';
import 'package:mjollnir/shared/models/stations/station.dart';
import 'dart:async';

class RouteInfo {
  final List<LatLng> points;
  final String distance;
  final String duration;
  final int distanceValue;
  final int durationValue;

  RouteInfo({
    required this.points,
    required this.distance,
    required this.duration,
    required this.distanceValue,
    required this.durationValue,
  });
}

class LocationController extends GetxController 
    with GetTickerProviderStateMixin {
  Rx<LatLng> initialLocation = const LatLng(17.4065, 78.4772).obs;
  Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
    Rx<MapType> currentMapType = MapType.terrain.obs;
  RxBool isHybridMode = true.obs;   RxBool isLocationReady = false.obs;
  RxBool isMarkersLoading = false.obs;
  RxBool showPaths = false.obs;
  RxBool isLoadingRoutes = false.obs;

  

  static const String _googleMapsApiKey = String.fromEnvironment(
      'GOOGLE_MAPS_API_KEY',
      defaultValue: 'AIzaSyD-pvZSAX89ZDga-lgutLKQYGb1mCpdMuU');

  late AnimationController _markerAnimationController;
  late AnimationController _cameraAnimationController;
  late AnimationController _pathAnimationController;
  RxDouble animationProgress = 0.0.obs;
  RxDouble tiltAnimation = 0.0.obs;
  RxDouble zoomAnimation = 7.0.obs;
  RxDouble pathAnimationProgress = 0.0.obs;

  RxSet<Polyline> polylines = <Polyline>{}.obs;
  RxSet<Marker> markers = <Marker>{}.obs;
  RxList<LatLng> locations = <LatLng>[].obs;

  Rx<Marker?> userLocationMarker = Rx<Marker?>(null);

  Map<String, RouteInfo> routeCache = {};

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    ever(locations, (_) => _updateMarkersAnimated());
    fetchUserLocation();
    _setupLocationListener();
  }

  void _setupLocationListener() {
    _location.enableBackgroundMode(enable: true);
    _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 10000,
      distanceFilter: 10,
    );

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        initialLocation.value =
            LatLng(locationData.latitude!, locationData.longitude!);
        _updateUserLocationMarker(locationData);
      }
    });
  }
 void toggleMapType() {
    switch (currentMapType.value) {
      case MapType.satellite:
        currentMapType.value = MapType.hybrid;
        isHybridMode.value = true;
        break;
      case MapType.hybrid:
        currentMapType.value = MapType.terrain;
        isHybridMode.value = false;
        break;
      case MapType.terrain:
        currentMapType.value = MapType.normal;
        isHybridMode.value = false;
        break;
      case MapType.normal:
        currentMapType.value = MapType.satellite;
        isHybridMode.value = false;
        break;
      case MapType.none:
        throw UnimplementedError();
    }
  }
  IconData getCurrentMapTypeIcon() {
    switch (currentMapType.value) {
      case MapType.satellite:
        return Icons.satellite_alt;
      case MapType.hybrid:
        return Icons.layers;
      case MapType.terrain:
        return Icons.terrain;
      case MapType.normal:
        return Icons.map;
      case MapType.none:
        throw UnimplementedError();
    }
  }
   String getCurrentMapTypeLabel() {
    switch (currentMapType.value) {
      case MapType.satellite:
        return 'Satellite';
      case MapType.hybrid:
        return 'Hybrid';
      case MapType.terrain:
        return 'Terrain';
      case MapType.normal:
        return 'Default';
      case MapType.none:
        throw UnimplementedError();
    }
  }
  String getSatelliteStyleMapStyle() {
    return '''[
      {
        "elementType": "geometry",
        "stylers": [
          {
            "saturation": 15
          },
          {
            "lightness": -10
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "on"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#ffffff"
          },
          {
            "weight": "0.5"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "weight": "2"
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "color": "#c9b2a6"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "color": "#dcd2be"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#ae9e90"
          }
        ]
      },
      {
        "featureType": "landscape.natural",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#dfd2ae"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#dfd2ae"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#93817c"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#a5b076"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#447530"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#f5f1e6"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#fdfcf8"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#f8c967"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "color": "#e9bc62"
          }
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e98d58"
          }
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "color": "#db8555"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#806b63"
          }
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#dfd2ae"
          }
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#8f7d77"
          }
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#ebe3cd"
          }
        ]
      },
      {
        "featureType": "transit.station",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#dfd2ae"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#b9d3c2"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#92998d"
          }
        ]
      }
    ]''';
  }



  void _updateUserLocationMarker(LocationData locationData) async {
    if (locationData.latitude == null || locationData.longitude == null) return;

    final position = LatLng(locationData.latitude!, locationData.longitude!);
    final heading = locationData.heading ?? 0.0;

    final customIcon = await _getDirectionPointerIcon(heading);

    final marker = Marker(
      markerId: const MarkerId('user_location'),
      position: position,
      icon: customIcon,
      rotation: heading,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      zIndex: 2,
    );

    userLocationMarker.value = marker;

    final updatedMarkers = {...markers};
    updatedMarkers.removeWhere((m) => m.markerId.value == 'user_location');
    updatedMarkers.add(marker);
    markers.assignAll(updatedMarkers);
  }

  Future<BitmapDescriptor> _getDirectionPointerIcon(double heading) async {
    try {
      final ByteData arrowData =
          await rootBundle.load('assets/images/iconn.png');
      final Uint8List arrowBytes = arrowData.buffer.asUint8List();

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Size size = const Size(80.0, 80.0);

      final ui.Codec codec = await ui.instantiateImageCodec(
        arrowBytes,
        targetWidth: 80,
        targetHeight: 80,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();

      final Offset center = Offset(size.width / 2, size.height / 2);

      final Paint circlePaint = Paint()
        ..color = Colors.blue.shade700.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, size.width * 0.4, circlePaint);

      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(center, size.width * 0.4, borderPaint);

      canvas.save();
      canvas.translate(center.dx, center.dy);

      const scale = 0.6;
      canvas.scale(scale, scale);
      canvas.translate(-frameInfo.image.width / 2, -frameInfo.image.height / 2);

      canvas.drawImage(frameInfo.image, Offset.zero, Paint());
      canvas.restore();

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
      }
    } catch (e) {
      AppLogger.e('Error creating direction pointer: $e');
    }

    return await _createFallbackDirectionPointer(heading);
  }

  Future<BitmapDescriptor> _createFallbackDirectionPointer(
      double heading) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const size = Size(60.0, 60.0);

    final center = Offset(size.width / 2, size.height / 2);

    final Paint circlePaint = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 25, circlePaint);

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 25, borderPaint);

    final Paint arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path arrowPath = Path()
      ..moveTo(center.dx, center.dy - 15)
      ..lineTo(center.dx + 10, center.dy + 5)
      ..lineTo(center.dx, center.dy)
      ..lineTo(center.dx - 10, center.dy + 5)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    }

    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
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

    if (userLocationMarker.value != null) {
      newMarkers.add(userLocationMarker.value!);
    }

    markers.assignAll(newMarkers);
    await _markerAnimationController.forward();
    isMarkersLoading.value = false;
  }

  void _onMarkerTapped(LatLng position, int index) {
    _createAnimatedPathToStation(position, index);
    _animateCameraToStation(position);
  }

  void _animateCameraToStation(LatLng position) async {
    if (mapController.value == null) return;

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

    _cameraAnimationController.reset();
    await _cameraAnimationController.forward();
  }

  void _createAnimatedPathToStation(
      LatLng destination, int stationIndex) async {
    if (!isLocationReady.value) return;

    isLoadingRoutes.value = true;

    try {
      final routeInfo = await _getDirectionsRoute(
        initialLocation.value,
        destination,
        stationIndex,
      );

      if (routeInfo != null) {
        polylines.clear();
        _createRoadBasedPolyline(routeInfo, stationIndex);
        _animatePathDrawing(routeInfo.points, stationIndex);
      } else {
        _createFallbackRoute(destination, stationIndex);
      }
    } catch (e) {
      AppLogger.e('Error creating route: $e');
      _createFallbackRoute(destination, stationIndex);
    } finally {
      isLoadingRoutes.value = false;
    }
  }

  Future<RouteInfo?> _getDirectionsRoute(
    LatLng origin,
    LatLng destination,
    int stationIndex,
  ) async {
    final cacheKey =
        '${origin.latitude},${origin.longitude}-${destination.latitude},${destination.longitude}';

    if (routeCache.containsKey(cacheKey)) {
      return routeCache[cacheKey];
    }

    if (_googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      AppLogger.e(
          'Google Maps API key not configured. Please set a valid API key.');
      return null;
    }

    try {
      final url =
          Uri.parse('https://maps.googleapis.com/maps/api/directions/json?'
              'origin=${origin.latitude},${origin.longitude}&'
              'destination=${destination.latitude},${destination.longitude}&'
              'mode=driving&'
              'alternatives=false&'
              'key=$_googleMapsApiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          final decodedPoints = _decodePolyline(polylinePoints);

          if (decodedPoints.isNotEmpty) {
            final routeInfo = RouteInfo(
              points: decodedPoints,
              distance: route['legs'][0]['distance']['text'],
              duration: route['legs'][0]['duration']['text'],
              distanceValue: route['legs'][0]['distance']['value'],
              durationValue: route['legs'][0]['duration']['value'],
            );

            routeCache[cacheKey] = routeInfo;
            return routeInfo;
          } else {
            AppLogger.e('Decoded points list is empty');
          }
        } else {
          AppLogger.e('Directions API returned status: ${data['status']}');
          if (data.containsKey('error_message')) {
            AppLogger.e('API Error message: ${data['error_message']}');
          }
        }
      } else {
        AppLogger.e('HTTP request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('Directions API error: $e');
    }

    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final position = LatLng(lat / 1E5, lng / 1E5);
      points.add(position);
    }

    return points;
  }

  void _createRoadBasedPolyline(RouteInfo routeInfo, int stationIndex) {
    final outlinePolyline = Polyline(
      polylineId: PolylineId('outline_road_$stationIndex'),
      points: routeInfo.points,
      color: Colors.black87,
      width: 8,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );

    final routeColor = _getRouteColorByDistance(routeInfo.distanceValue);
    final mainPolyline = Polyline(
      polylineId: PolylineId('main_road_$stationIndex'),
      points: routeInfo.points,
      color: routeColor,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      patterns: [
        PatternItem.gap(10),
        PatternItem.dash(20),
      ],
    );

    polylines.assignAll({outlinePolyline, mainPolyline});
  }

  void _createFallbackRoute(LatLng destination, int stationIndex) {
    final fallbackPoints = [initialLocation.value, destination];

    final outlinePolyline = Polyline(
      polylineId: PolylineId('fallback_outline_$stationIndex'),
      points: fallbackPoints,
      color: Colors.black87,
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    final mainPolyline = Polyline(
      polylineId: PolylineId('fallback_main_$stationIndex'),
      points: fallbackPoints,
      color: Colors.orange,
      width: 4,
      patterns: [
        PatternItem.gap(15),
        PatternItem.dash(15),
      ],
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    polylines.assignAll({outlinePolyline, mainPolyline});
  }

  Color _getRouteColorByDistance(int distanceInMeters) {
    if (distanceInMeters < 2000) return Colors.green.shade600;
    if (distanceInMeters < 10000) return Colors.blue.shade600;
    if (distanceInMeters < 25000) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

 

  void _animatePathDrawing(List<LatLng> fullPath, int stationIndex) async {
    _pathAnimationController.reset();
    showPaths.value = true;
    await _pathAnimationController.forward();
  }

  void togglePathsToAllStations() async {
    if (showPaths.value) {
      polylines.clear();
      showPaths.value = false;
    } else {
      await _createRoadPathsToAllStations();
    }
  }

  Future<void> _createRoadPathsToAllStations() async {
    if (!isLocationReady.value || locations.isEmpty) return;

    isLoadingRoutes.value = true;
    polylines.clear();
    Set<Polyline> allPolylines = {};

    try {
      for (int i = 0; i < locations.length; i++) {
        final destination = locations[i];

        final routeInfo = await _getDirectionsRoute(
          initialLocation.value,
          destination,
          i,
        );

        if (routeInfo != null) {
          final outlinePolyline = Polyline(
            polylineId: PolylineId('outline_all_$i'),
            points: routeInfo.points,
            color: Colors.black87,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          );

          final pathColor = _getRouteColorByDistance(routeInfo.distanceValue);

          final mainPolyline = Polyline(
            polylineId: PolylineId('main_all_$i'),
            points: routeInfo.points,
            color: pathColor,
            width: 4,
            patterns: [
              PatternItem.gap(8),
              PatternItem.dash(15),
            ],
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          );

          allPolylines.addAll({outlinePolyline, mainPolyline});
        } else {
          _addFallbackPolyline(allPolylines, destination, i);
        }

        if (i < locations.length - 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      polylines.assignAll(allPolylines);
      showPaths.value = true;
    } catch (e) {
      AppLogger.e('Error creating all routes: $e');
    } finally {
      isLoadingRoutes.value = false;
    }
  }

  void _addFallbackPolyline(
      Set<Polyline> polylines, LatLng destination, int index) {
    final fallbackPoints = [initialLocation.value, destination];

    final outlinePolyline = Polyline(
      polylineId: PolylineId('fallback_outline_all_$index'),
      points: fallbackPoints,
      color: Colors.black87,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    final mainPolyline = Polyline(
      polylineId: PolylineId('fallback_main_all_$index'),
      points: fallbackPoints,
      color: Colors.grey.shade600,
      width: 3,
      patterns: [
        PatternItem.gap(10),
        PatternItem.dash(10),
      ],
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    polylines.addAll({outlinePolyline, mainPolyline});
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

    await mapController.value!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 120.0),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    await _animateTiltSequence();
  }

  Future<void> _animateTiltSequence() async {
    if (mapController.value == null) return;

    await Future.delayed(const Duration(milliseconds: 800));

    final visibleRegion = await mapController.value!.getVisibleRegion();
    final center = LatLng(
      (visibleRegion.southwest.latitude + visibleRegion.northeast.latitude) / 2,
      (visibleRegion.southwest.longitude + visibleRegion.northeast.longitude) /
          2,
    );

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

    final userMarker =
        markers.firstWhereOrNull((m) => m.markerId.value == 'user_location');

    markers.clear();
    polylines.clear();
    showPaths.value = false;

    await Future.delayed(const Duration(milliseconds: 200));

    final BitmapDescriptor customIcon = await _getCustomMarkerWithFallback();
    Set<Marker> newMarkers = {};

    if (userMarker != null) {
      newMarkers.add(userMarker);
    }

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

    await fitMapToBoundsAnimated(locations);

    _markerAnimationController.forward();
    isMarkersLoading.value = false;
    update();
  }

  Future<BitmapDescriptor> _getCustomMarkerWithFallback() async {
    try {
      final ByteData data =
          await rootBundle.load('assets/company/mj.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 60,
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

        _updateUserLocationMarker(locationData);

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

        _updateUserLocationMarker(locationData);

        isLocationReady.value = true;
      }
    } catch (e) {
      AppLogger.e("Error fetching location: $e");
    }
  }

  void resetMapView() {
    polylines.clear();
    showPaths.value = false;
    routeCache.clear();
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
    _locationSubscription?.cancel();
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
  bool _isToggling = false; 


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
              snippet: 'Capacity: ${station.currentCapacity}/${station.capacity}',
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

    locationController._createAnimatedPathToStation(position, int.parse(station.id));
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
              zoom: 15,
              tilt: 45,
              bearing: 0,
            ),
            mapType: locationController.currentMapType.value,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            buildingsEnabled: true,
            trafficEnabled: false,
            indoorViewEnabled: true,
            markers: {...locationController.markers, ..._markers},
            polylines: locationController.polylines,
            onMapCreated: (GoogleMapController controller) async {
              locationController.mapController.value = controller;
              
              // Apply custom satellite style only if using normal map type
              if (locationController.currentMapType.value == MapType.normal) {
                await controller.setMapStyle(locationController.getSatelliteStyleMapStyle());
              }
              
              await Future.delayed(const Duration(milliseconds: 500));
              
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

          // Loading overlays
          if (locationController.isLoadingRoutes.value)
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
                        Text('Loading road routes...'),
                      ],
                    ),
                  ),
                ),
              ),
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

          Positioned(
  top: 80,
  right: 10,
  child: ScaleTransition(
    scale: _fabAnimation,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
          onTap: () async {
            // Add haptic feedback
            HapticFeedback.lightImpact();
            
            // Add loading state animation
            setState(() {
              _isToggling = true;
            });
            
            locationController.toggleMapType();
            
            // Apply/remove custom styling based on map type
            if (locationController.mapController.value != null) {
              try {
                if (locationController.currentMapType.value == MapType.normal) {
                  await locationController.mapController.value!
                      .setMapStyle(locationController.getSatelliteStyleMapStyle());
                } else {
                  await locationController.mapController.value!
                      .setMapStyle(null);
                }
              } catch (e) {
                print('Error setting map style: $e');
              }
            }
            
            await Future.delayed(const Duration(milliseconds: 300));
            setState(() {
              _isToggling = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with rotation animation and loading state
                AnimatedRotation(
                  turns: _isToggling ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _isToggling
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : Icon(
                            key: ValueKey(locationController.currentMapType.value),
                            locationController.getCurrentMapTypeIcon(),
                            color: Theme.of(context).primaryColor,
                            size: 22,
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                // Text with fade transition
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    key: ValueKey(locationController.getCurrentMapTypeLabel()),
                    locationController.getCurrentMapTypeLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
),

          // Routes toggle button
          Positioned(
            bottom: 220,
            right: 10,
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

          // Reset button
          Positioned(
            bottom: 160,
            left: 10,
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

          // Location button
          Positioned(
            bottom: 160,
            right: 10,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                heroTag: "locationFab",
                onPressed: locationController.goToUserLocationAnimated,
                child: const Icon(Icons.my_location),
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
