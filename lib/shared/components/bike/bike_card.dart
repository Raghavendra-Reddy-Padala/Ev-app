import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../models/bike/bike_model.dart';

class BikeCard extends StatelessWidget {
  final Bike bike;
  final VoidCallback? onSelectPlan;

  const BikeCard({
    super.key,
    required this.bike,
    this.onSelectPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section with light green background
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F0), // Light green background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Details text
                Text(
                  "Plan Details",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8.h),
                // Plan type and level row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getPlanType(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _getPlanLevel(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content section
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    // Bike image
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Image.network(
                        "https://toppng.com/uploads/preview/cycle-hd-images-11549761022izaeyhmkgm.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    
                    // Location info
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.location_on_outlined,
                        iconColor: AppColors.primary,
                        label: "Location",
                        value: "ORR Track",
                      ),
                    ),
                    
                    // Divider line
                    Container(
                      width: 1,
                      height: 40.h,
                      color: Colors.grey[300],
                      margin: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                    
                    // Time info
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.access_time,
                        iconColor: AppColors.primary,
                        label: "Time",
                        value: "${bike.timeToStation} hr${bike.timeToStation > 1 ? 's' : ''}",
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                // Select a Plan button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: onSelectPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Select a Plan",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanType() {
    if (bike.bikeType.toLowerCase().contains('electric')) {
      return 'Electric & Manual';
    } else {
      return 'Manual';
    }
  }

  String _getPlanLevel() {
    if (bike.topSpeed >= 40 && bike.range >= 100) {
      return 'Premium';
    } else {
      return 'Super';
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: iconColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}