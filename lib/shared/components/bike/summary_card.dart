import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';

class SummaryCard extends StatelessWidget {
  final RideDetails rideDetails;
  final TripDetails tripDetails;

  const SummaryCard({
    super.key,
    required this.rideDetails,
    required this.tripDetails,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.accent1,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: RideDetailsSection(details: rideDetails),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: TripDetailsCard(details: tripDetails),
          ),
        ],
      ),
    );
  }
}

class RideDetails {
  final String type;
  final String bikeImage;
  final double price;
  final String rideId;
  final String frameNumber;
  final String duration;
  final String calories;
  final String status;

  const RideDetails({
    required this.type,
    required this.bikeImage,
    required this.price,
    required this.rideId,
    required this.frameNumber,
    required this.duration,
    required this.calories,
    required this.status,
  });
}

class RideDetailsSection extends StatelessWidget {
  final RideDetails details;

  const RideDetailsSection({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBasicInfo(),
        SizedBox(width: 15.w),
        Expanded(child: _buildDetailedInfo()),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          details.type,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: 80.w,
          height: 48.h,
          child: Image.asset(
            details.bikeImage,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 10.h),
        // Text(
        //   '₹${details.price}',
        //   style: TextStyle(
        //     fontSize: 22.sp,
        //     fontWeight: FontWeight.w700,
        //     color: AppColors.primary,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDetailedInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(),
        Divider(height: 20.h),
        _buildStatsRow(),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoItem(
          title: 'Ride ID',
          value: details.rideId,
          titleColor: Colors.grey[600]!,
        ),
        _InfoItem(
          title: 'Frame number',
          value: details.frameNumber,
          titleColor: Colors.black87,
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoItem(
          title: 'Duration',
          value: details.duration,
          titleColor: Colors.black87,
        ),
        _InfoItem(
          title: 'Calories',
          value: details.calories,
          titleColor: Colors.black87,
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final Color titleColor;

  const _InfoItem({
    required this.title,
    required this.value,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: titleColor,
          ),
        ),
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

class TripDetails {
  final String pickupTime;
  final String dropTime;
  final String pickupLocation;
  final String dropLocation;

  const TripDetails({
    required this.pickupTime,
    required this.dropTime,
    required this.pickupLocation,
    required this.dropLocation,
  });
}

class TripDetailsCard extends StatelessWidget {
  final TripDetails details;

  const TripDetailsCard({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          _buildLocationIndicators(),
          SizedBox(width: 16.w),
          Expanded(child: _buildTripInfo()),
        ],
      ),
    );
  }

  Widget _buildLocationIndicators() {
    return Column(
      children: [
        Icon(Icons.circle_outlined, size: 16.w, color: Colors.green),
        Container(
          width: 2.w,
          height: 40.h,
          color: Colors.grey[300],
        ),
        Icon(Icons.circle_outlined, size: 16.w, color: Colors.red),
      ],
    );
  }

  Widget _buildTripInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationDetail(
          'Bike Pick up - ${details.pickupTime}',
          details.pickupLocation,
        ),
        _buildSwapIcon(),
        _buildLocationDetail(
          'Bike drop - ${details.dropTime}',
          details.dropLocation,
        ),
      ],
    );
  }

  Widget _buildLocationDetail(String title, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          location,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSwapIcon() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Divider(thickness: 1),
        ),
        Positioned(
          right: 24.w,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.swap_vert, size: 24.w),
          ),
        ),
      ],
    );
  }
}
