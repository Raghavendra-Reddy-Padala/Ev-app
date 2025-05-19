import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:mjollnir/shared/components/map/graph_view.dart' show GraphView;
import 'package:mjollnir/shared/components/map/path_view.dart';
import 'package:mjollnir/shared/components/misc/details.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';
import 'package:screenshot/screenshot.dart';

class ScreenshotView extends StatelessWidget {
  final Trip details;
  final ScreenshotController screenshotController;

  const ScreenshotView({
    super.key, 
    required this.details, 
    required this.screenshotController
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Screenshot(
        controller: screenshotController,
        child: _buildScreenshotContent(context),
      ),
    );
  }

  Widget _buildScreenshotContent(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0.02.sh,
            vertical: 0.02.sh,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLogoHeader(context),
              SizedBox(height: 12.h),
              _buildActivityGraph(),
              SizedBox(height: 16.h),
              Expanded(
                flex: 2,
                child: Details(trip: details),
              ),
              SizedBox(height: 16.h),
              Expanded(
                flex: 3,
                child: _buildTripPath(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: SizedBox(
          height: 40.h,
          child: _getLogo(context),
        ),
      ),
    );
  }

  Widget _getLogo(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String logoPath = isDarkMode 
        ? 'assets/company/Logo.png'
        : 'assets/company/Logo-Black.png';
        
    return Image.asset(
      logoPath,
      fit: BoxFit.contain,
    );
  }

  Widget _buildActivityGraph() {
    
    return SizedBox(
      height: 0.22.sh,
      child: const GraphView(
        data: {8: 7, 9: 10, 10: 12, 11: 15, 12: 13},
        xLabels: {
          8: '8 AM',
          9: '9 AM',
          10: '10 AM',
          11: '11 AM',
          12: '12 PM'
        },
        showYAxisLabels: true,
        showHorizontalLines: true,
      ),
    );
  }

  Widget _buildTripPath() {
    final pathPoints = _getPathPoints();
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PathView(
          pathPoints: pathPoints,
        ),
      ),
    );
  }

   _getPathPoints() {
    try {
      final TripsController tripController = Get.find<TripsController>();
      return tripController.convertToLatLng(
        details.path.map((point) => [point.lat, point.long]).toList()
      );
    } catch (e) {
      debugPrint('Error converting path points: $e');
      return [];
    }
  }
}