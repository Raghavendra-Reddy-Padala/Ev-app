import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme.dart';
import 'trip_details_card.dart';

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
    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(20.w),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          RideDetailsSection(details: rideDetails),
          Divider(height: 20.h),
          TripDetailsCard(details: tripDetails),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: EVColors.offwhite,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: EVColors.shadowColor,
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
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
      children: [
        _buildBasicInfo(),
        SizedBox(width: 15.w),
        Expanded(child: _buildDetailedInfo()),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return SizedBox(
      width: 80.w,
      child: Column(
        children: [
          Text(
            details.type,
            style: CustomTextTheme.bodySmallP.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Image.asset(
            details.bikeImage,
            height: 30.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 10.h),
          _buildPrice(),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Text(
      '₹${details.price}',
      style: CustomTextTheme.headlineLargeP.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDetailedInfo() {
    return Column(
      children: [
        _buildInfoRow(),
        Divider(height: 15.h),
        _buildStatsRow(),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 60.w,
          height: 40.h,
          child: _buildInfoItem(
            'Ride ID',
            details.rideId,
            EVColors.greytext,
          ),
        ),
        SizedBox(
            height: 40.h,
            width: 120.w,
            child: _buildInfoItem(
                'Frame number', details.frameNumber, Colors.black)),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem('Duration', details.duration, Colors.black),
        _buildInfoItem('Calories', details.calories, Colors.black),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value, Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CustomTextTheme.bodySmallP
              .copyWith(color: titleColor, overflow: TextOverflow.ellipsis),
        ),
        Text(
          value,
          style: CustomTextTheme.bodyMediumP.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
