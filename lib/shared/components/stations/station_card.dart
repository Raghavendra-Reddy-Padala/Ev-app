import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../models/stations/station.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final double distance;
  final VoidCallback? onTap;
  final VoidCallback? onGoToLocation;

  const StationCard({
    super.key,
    required this.station,
    required this.distance,
    this.onTap,
    this.onGoToLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DistanceDisplay(distance: distance),
                _StationInfo(
                  name: station.name,
                  currentCapacity: station.currentCapacity,
                  totalCapacity: station.capacity,
                ),
                GestureDetector(
                  onTap: onGoToLocation ?? onTap,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DistanceDisplay extends StatelessWidget {
  final double distance;

  const _DistanceDisplay({required this.distance});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Constants.distance,
            width: 24.w,
            height: 24.w,
            color: Colors.white,
          ),
          SizedBox(height: 4.h),
          Text(
            "Distance",
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white,
            ),
          ),
          Text(
            "${distance.toStringAsFixed(1)} km",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StationInfo extends StatelessWidget {
  final String name;
  final int currentCapacity;
  final int totalCapacity;

  const _StationInfo({
    required this.name,
    required this.currentCapacity,
    required this.totalCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CapacityIndicator(
                  icon: Icons.electric_bike,
                  count: totalCapacity,
                ),
                SizedBox(width: 16.w),
                _CapacityIndicator(
                  icon: Icons.directions_bike_sharp,
                  count: currentCapacity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CapacityIndicator extends StatelessWidget {
  final IconData icon;
  final int count;

  const _CapacityIndicator({
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 18.w,
        ),
        SizedBox(width: 4.w),
        Text(
          "$count",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
