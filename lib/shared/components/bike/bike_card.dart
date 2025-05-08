import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../models/bike/bike_model.dart';
import '../buttons/app_button.dart';

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
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.accent1,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              bike.name,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            _BikeInfoRow(bike: bike),
            SizedBox(height: 16.h),
            _BikeFeatures(bike: bike),
            SizedBox(height: 16.h),
            AppButton(
              text: "Select Plan",
              onPressed: onSelectPlan,
              type: ButtonType.primary,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _BikeInfoRow extends StatelessWidget {
  final Bike bike;

  const _BikeInfoRow({required this.bike});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Frame Number",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            Text(
              bike.frameNumber,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 65.w,
          height: 65.h,
          child: Image.asset(Constants.bike),
        ),
      ],
    );
  }
}

class _BikeFeatures extends StatelessWidget {
  final Bike bike;

  const _BikeFeatures({required this.bike});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FeatureItem(
            label: "Top Speed",
            value: "${bike.topSpeed} km/h",
          ),
          _VerticalDivider(),
          _FeatureItem(
            label: "Range",
            value: "${bike.range} km",
          ),
          _VerticalDivider(),
          _FeatureItem(
            label: "Time",
            value: "${bike.timeToStation} hrs",
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String label;
  final String value;

  const _FeatureItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width: 1.w,
      color: AppColors.primary.withOpacity(0.3),
    );
  }
}
