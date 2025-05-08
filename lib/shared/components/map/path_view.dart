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
    Key? key,
    required this.pathPoints,
    this.isScreenshotMode = false,
    this.overlay,
    this.height = 170,
    this.borderRadius,
    this.showLogoBadge = true,
  }) : super(key: key);

  @override
  _PathViewState createState() => _PathViewState();
}

class _PathViewState extends State<PathView> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _startIcon;
  BitmapDescriptor? _endIcon;
  LatLngBounds? _bounds;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _calculateBounds();
  }

  Future<void> _loadCustomMarkers() async {
    try {
      _startIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(24.w, 24.w)),
        'assets/images/start_marker.png',
      );

      _endIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(24.w, 24.w)),
        'assets/images/end_marker.png',
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error loading markers: $e");
      // Fallback to default markers if loading fails
      _startIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _endIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void _calculateBounds() {
    if (widget.pathPoints.isEmpty) return;

    double minLat = widget.pathPoints.map((e) => e.latitude).reduce(min);
    double maxLat = widget.pathPoints.map((e) => e.latitude).reduce(max);
    double minLng = widget.pathPoints.map((e) => e.longitude).reduce(min);
    double maxLng = widget.pathPoints.map((e) => e.longitude).reduce(max);

    // Add some padding around the bounds
    final double latPadding = (maxLat - minLat) * 0.2;
    final double lngPadding = (maxLng - minLng) * 0.2;

    _bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pathPoints.isEmpty) {
      return _buildErrorContainer('No path data available');
    }

    if (widget.isScreenshotMode) {
      return _buildScreenshotPlaceholder();
    }

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
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _applyMapStyle(context);
                if (_bounds != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngBounds(_bounds!, 50),
                  );
                }
              },
              initialCameraPosition: CameraPosition(
                target: widget.pathPoints.isNotEmpty
                    ? widget.pathPoints[0]
                    : const LatLng(0, 0),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('start'),
                  position: widget.pathPoints.first,
                  icon: _startIcon ??
                      BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                  infoWindow: const InfoWindow(title: 'Start Point'),
                ),
                Marker(
                  markerId: const MarkerId('end'),
                  position: widget.pathPoints.last,
                  icon: _endIcon ??
                      BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                  infoWindow: const InfoWindow(title: 'End Point'),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('path'),
                  points: widget.pathPoints,
                  color: Colors.blue,
                  width: 5,
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
            if (widget.showLogoBadge)
              Positioned(
                top: 8.h,
                left: 8.w,
                child: _buildLogoBadge(),
              ),
            if (widget.overlay != null) widget.overlay!,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Image.asset(
        'assets/company/Logo-Black.png',
        height: 20.h,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      height: widget.height.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotPlaceholder() {
    return Container(
      height: widget.height.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 32.w,
              color: Colors.grey[700],
            ),
            SizedBox(height: 8.h),
            Text(
              'Map preview not available in screenshots',
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

  void _applyMapStyle(BuildContext context) {
    if (_mapController != null) {
      final mapStyle = Theme.of(context).brightness == Brightness.dark
          ? Constants.darkMapStyle
          : Constants.lightMapStyle;
      _mapController?.setMapStyle(mapStyle);
    }
  }
}
