import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TripDetailsCard extends StatelessWidget {
  final TripDetails details;

  const TripDetailsCard({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: EVColors.white,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            _buildLocationIndicators(),
            SizedBox(width: 10.w),
            Expanded(child: _buildTripInfo()),
          ],
        ),
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
        Icon(Icons.circle_outlined, size: 16.w, color: Colors.green),
      ],
    );
  }

  Widget _buildTripInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationDetail(
          'Bike Pick up Hub - \${details.pickupTime}',
          details.pickupLocation,
          null,
        ),
        _buildSwapIcon(),
        _buildLocationDetail(
          'Bike drop Hub - \${details.dropTime}',
          details.dropLocation,
          null,
        ),
      ],
    );
  }

  Widget _buildLocationDetail(String title, String location, String? date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CustomTextTheme.bodySmallP.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                location,
                softWrap: true,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: CustomTextTheme.bodyMediumP.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (date != null)
          Text(
            date,
            style: CustomTextTheme.bodySmallXPBold.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildSwapIcon() {
    return Stack(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Divider(height: 40, thickness: 1),
        ),
        Positioned(
          right: 10.w,
          child: Container(
            margin: EdgeInsets.all(8.w),
            width: 35.w,
            height: 35.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  spreadRadius: 1.5,
                  offset: Offset(3, 3),
                ),
              ],
            ),
            child: Icon(Icons.swap_vert, size: 20.w),
          ),
        ),
      ],
    );
  }
}
