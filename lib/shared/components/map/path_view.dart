import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants/constants.dart';

class PathView extends StatefulWidget {
  final List<LatLng> pathPoints;
  final bool isScreenshotMode;
  final Widget? overlay;
  final double height;
  final BorderRadius? borderRadius;
  final bool showLogoBadge;

  const PathView({
    super.key,
    required this.pathPoints,
    this.isScreenshotMode = false,
    this.overlay,
    this.height = 170,
    this.borderRadius,
    this.showLogoBadge = true,
  });

  @override
  State<PathView> createState() => _PathViewState();
}

class _PathViewState extends State<PathView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLngBounds? _bounds;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  Future<void> _initializeMapData() async {
    if (widget.pathPoints.isEmpty) return;

    _calculateBounds();
    await _createMarkers();
  }

  void _calculateBounds() {
    if (widget.pathPoints.isEmpty) return;

    final latitudes = widget.pathPoints.map((point) => point.latitude);
    final longitudes = widget.pathPoints.map((point) => point.longitude);

    final minLat = latitudes.reduce(min);
    final maxLat = latitudes.reduce(max);
    final minLng = longitudes.reduce(min);
    final maxLng = longitudes.reduce(max);

    final latPadding = max((maxLat - minLat) * 0.3, 0.005);
    final lngPadding = max((maxLng - minLng) * 0.3, 0.005);

    _bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
  }

  Future<void> _createMarkers() async {
    if (widget.pathPoints.isEmpty) return;

    try {
      final startIcon = await _loadCustomIcon('assets/images/start_marker.png');
      final endIcon = await _loadCustomIcon('assets/images/end_marker.png');

      _markers = {
        Marker(
          markerId: const MarkerId('start'),
          position: widget.pathPoints.first,
          icon: startIcon,
          infoWindow: const InfoWindow(title: 'Start Point'),
        ),
        Marker(
          markerId: const MarkerId('end'),
          position: widget.pathPoints.last,
          icon: endIcon,
          infoWindow: const InfoWindow(title: 'End Point'),
        ),
      };
    } catch (e) {
      debugPrint('Error creating custom markers: $e');
      _createDefaultMarkers();
    }

    if (mounted) setState(() {});
  }

  Future<BitmapDescriptor> _loadCustomIcon(String assetPath) async {
    return await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        size: Size(48.w, 48.w),
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      ),
      assetPath,
    );
  }

  void _createDefaultMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: widget.pathPoints.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start Point'),
      ),
      Marker(
        markerId: const MarkerId('end'),
        position: widget.pathPoints.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'End Point'),
      ),
    };
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    await _applyMapStyle();
    _isMapReady = true;

    if (_bounds != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(_bounds!, 100.0),
      );
    }
  }

  Future<void> _applyMapStyle() async {
    if (_mapController == null || !mounted) return;

    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final mapStyle =
          isDark ? Constants.darkMapStyle : Constants.lightMapStyle;
      await _mapController?.setMapStyle(mapStyle);
    } catch (e) {
      debugPrint('Error applying map style: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pathPoints.isEmpty) {
      return _buildErrorContainer('No path data available');
    }

    if (widget.isScreenshotMode) {
      return _buildScreenshotPlaceholder();
    }

    return _buildMapContainer();
  }

  Widget _buildMapContainer() {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12.r);

    return Container(
      height: widget.height.h,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: widget.pathPoints.first,
                zoom: 14,
              ),
              markers: _markers,
              polylines: {
                Polyline(
                  polylineId: const PolylineId('path'),
                  points: widget.pathPoints,
                  color: Colors.blue,
                  width: 4,
                  patterns: [],
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
            if (widget.showLogoBadge) _buildLogoBadge(),
            if (widget.overlay != null) widget.overlay!,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoBadge() {
    return Positioned(
      bottom: 6.h,
      left: 3.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 3.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Image.asset(
          'assets/company/Logo-Black.png',
          height: 15.h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.business,
              size: 14.h,
              color: Colors.grey[700],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorContainer(String message) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12.r);

    return Container(
      height: widget.height.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey[300]!, width: 1.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 32.w,
              color: Colors.grey[600],
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotPlaceholder() {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12.r);

    return Container(
      height: widget.height.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey[400]!, width: 1.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 40.w,
              color: Colors.grey[600],
            ),
            SizedBox(height: 12.h),
            Text(
              'Map Preview',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Not available in screenshots',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
