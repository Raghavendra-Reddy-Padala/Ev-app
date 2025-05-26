import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants/colors.dart';
import '../../models/user/user_model.dart';
import '../map/path_view.dart';

class ActivityWidget extends StatelessWidget {
  final Trip trip;
  final List<LatLng> pathPoints;
  final bool isFullScreen;

  const ActivityWidget({
    super.key,
    required this.pathPoints,
    required this.trip,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 270.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent1,
            AppColors.accent1.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent1.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: PathView(
                    pathPoints: pathPoints,
                    isScreenshotMode: false,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: _buildTripStats(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStats() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildStatColumn("Time", _formatDuration(trip.duration),
              Icons.access_time_rounded),
          _buildDivider(),
          _buildStatColumn("Distance", _formatDistance(trip.distance),
              Icons.straighten_rounded),
          _buildDivider(),
          _buildStatColumn("Calories", _formatCalories(trip.kcal),
              Icons.local_fire_department_rounded),
          _buildDivider(),
          _buildStatColumn("Max Elv", _formatMaxElevation(trip.maxElevation),
              Icons.terrain_rounded),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18.w,
              color: AppColors.primary,
            ),
          ),

          SizedBox(height: 8.h),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 3.h),

          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 35.h,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  String _formatDistance(double distance) {
    return "${(distance / 1000).toStringAsFixed(1)} km";
  }

  String _formatDuration(double duration) {
    int hours = duration.floor();
    int minutes = ((duration - hours) * 60).round();
    if (hours > 0) {
      return "$hours h $minutes m";
    }
    return "$minutes m";
  }

  String _formatCalories(double calories) {
    return "${calories.round()} kcal";
  }

  String _formatMaxElevation(int elevation) {
    return "${elevation} m";
  }
}
