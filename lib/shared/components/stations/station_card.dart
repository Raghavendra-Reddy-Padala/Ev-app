import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primary,
                  AppColors.green,
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B894).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 10.w),
              child: Row(
                children: [
                  _LocationIcon(distance: distance),
                  Container(
                    width: 1,
                    height: 60.h,
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  Expanded(
                    child: _StationInfo(
                      name: station.name,
                      currentCapacity: station.currentCapacity,
                      totalCapacity: station.capacity,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60.h,
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  _ActionButton(onTap: onTap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationIcon extends StatelessWidget {
  final double distance;

  const _LocationIcon({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            size: 24.w,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "${distance.toStringAsFixed(0)} kms",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  icon: Icons.electric_bike,
                  count: totalCapacity,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _InfoBox(
                  icon: Icons.directions_bike,
                  count: currentCapacity,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final int count;

  const _InfoBox({
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18.w,
              ),
              SizedBox(width: 6.w),
              Text(
                "$count",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
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
        color: Colors.white,
        shape: BoxShape.circle,
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
              color: const Color(0xFF00B894),
              size: 16.w,
            ),
          ),
        ),
      ),
    );
  }
}
