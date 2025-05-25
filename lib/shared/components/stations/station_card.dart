import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/core/navigation/navigation_service.dart';
import 'package:mjollnir/features/home/views/stationbikesview.dart';

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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      _DistanceDisplay(distance: distance),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _StationInfo(
                          name: station.name,
                          currentCapacity: station.currentCapacity,
                          totalCapacity: station.capacity,
                        ),
                      ),
                      _ActionButton(onTap: onTap 
                      ),
                    ],
                  ),
                  // SizedBox(height: 12.h),
                  // _CapacityBar(
                  //   current: station.currentCapacity,
                  //   total: station.capacity,
                  // ),
                ],
              ),
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
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 20.w,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "${distance.toStringAsFixed(1)}km",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "away",
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.8),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _CapacityChip(
              icon: Icons.electric_bike,
              label: "Total",
              count: totalCapacity,
              color: Colors.white.withOpacity(0.9),
            ),
            SizedBox(width: 12.w),
            _CapacityChip(
              icon: Icons.directions_bike,
              label: "Available",
              count: currentCapacity,
              color: _getCapacityColor(),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCapacityColor() {
    final ratio = currentCapacity / totalCapacity;
    if (ratio > 0.7) return Colors.greenAccent;
    if (ratio > 0.3) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}

class _CapacityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _CapacityChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16.w,
          ),
          SizedBox(width: 4.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$count",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ActionButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20.w,
            ),
          ),
        ),
      ),
    );
  }
}
