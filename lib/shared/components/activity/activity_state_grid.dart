import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/models/trips/trips_model.dart';
import '../../constants/colors.dart';

class ActivityStatsGrid extends StatelessWidget {
  final TripSummaryModel tripSummary;
  final String Function(double) formatTime;
  final bool isLoading;

  const ActivityStatsGrid({
    super.key,
    required this.tripSummary,
    required this.formatTime,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const double cardSpacing = 10.0;
    const double rowSpacing = 14.0;

    return Column(
      children: [
        // First row - Total Trips and Calories
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Total Trips",
                value: "${tripSummary.totalTrips}",
                height: 80.h,
                isLoading: isLoading,
                icon: Icons.directions_bike,
                iconColor: AppColors.primary,
              ),
            ),
            SizedBox(width: cardSpacing.w),
            Expanded(
              child: _StatCard(
                title: "Calories",
                value: "${tripSummary.totalCalories} Kcal",
                height: 80.h,
                isLoading: isLoading,
                icon: Icons.local_fire_department,
                iconColor: Colors.orange[600]!,
              ),
            ),
          ],
        ),
        SizedBox(height: rowSpacing.h),

        // Second row - My Best and Total Time
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _StatCard(
                title: "My Best Distance",
                value:
                    "${tripSummary.longestRide.distanceKm.toStringAsFixed(1)} Km",
                height: 80.h,
                isLoading: isLoading,
                icon: Icons.emoji_events,
                iconColor: Colors.amber[700]!,
              ),
            ),
            SizedBox(width: cardSpacing.w),
            Expanded(
              flex: 2,
              child: _StatCard(
                title: "Total Time",
                value: formatTime(tripSummary.totalTimeHours),
                height: 80.h,
                isLoading: isLoading,
                icon: Icons.schedule,
                iconColor: Colors.blue[600]!,
              ),
            ),
          ],
        ),
        SizedBox(height: rowSpacing.h),

        // Third row - Highest Speed (full width)
        _StatCard(
          title: "Highest Speed",
          value: "${tripSummary.highestSpeed.toStringAsFixed(1)} Km/h",
          width: double.infinity,
          height: 80.h,
          isLoading: isLoading,
          icon: Icons.speed,
          iconColor: Colors.red[600]!,
        ),
        SizedBox(height: rowSpacing.h),

        // Fourth row - Avg Distance and Carbon Saved
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Avg Distance",
                value:
                    "${tripSummary.averages.distanceKm.toStringAsFixed(1)} Km",
                height: 80.h,
                isLoading: isLoading,
                icon: Icons.timeline,
                iconColor: Colors.purple[600]!,
              ),
            ),
            SizedBox(width: cardSpacing.w),
            Expanded(
              child: _StatCard(
                title: "Carbon Saved",
                value: "${tripSummary.carbonFootprintKg.toStringAsFixed(1)} Kg",
                height: 80.h,
                isLoading: isLoading,
                icon: Icons.eco,
                iconColor: Colors.green[600]!,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final double? width;
  final double height;
  final bool isLoading;
  final IconData? icon;
  final Color? iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.width,
    required this.height,
    this.isLoading = false,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.accent1, // Keeping the original color
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: iconColor?.withOpacity(0.15) ??
                          AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      icon,
                      size: 16.w,
                      color: iconColor ?? AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 0.2,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Value section
            if (isLoading)
              _buildShimmerLoader()
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Container(
      height: 20.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }
}
