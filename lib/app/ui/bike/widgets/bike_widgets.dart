import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BikeWidget extends StatelessWidget {
  final Bike bike;

  const BikeWidget({super.key, required this.bike});

  @override
  Widget build(BuildContext context) {
    return _BikeCardContent(bike: bike);
  }
}

class _BikeCardContent extends StatelessWidget {
  final Bike bike;

  const _BikeCardContent({required this.bike});

  @override
  Widget build(BuildContext context) {
    final ElevatedButtons elevatedButtons = ElevatedButtons();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        width: ScreenUtil().screenWidth,
        height: 260.w,
        decoration: BoxDecoration(
          color: EVColors.accent1,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBikeTitle(),
              BikeFrameWidget(bike: bike),
              _buildFeaturesContainer(),
              SizedBox(height: 10.w),
              _buildSelectPlanButton(elevatedButtons),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBikeTitle() {
    return Text(
      bike.name,
      style: CustomTextTheme.bodyMediumPBold.copyWith(color: Colors.black),
    );
  }

  Widget _buildFeaturesContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.sp),
        color: Colors.white,
      ),
      child: BikeFeatureWidget(bike: bike),
    );
  }

  Widget _buildSelectPlanButton(ElevatedButtons elevatedButtons) {
    return SizedBox(
      width: 340.w,
      height: 50.w,
      child: ElevatedButton(
        onPressed: () => NavigationService.pushTo(PlanType(bike: bike)),
        style: elevatedButtons.selectPlan.style,
        child: elevatedButtons.selectPlan.child,
      ),
    );
  }
}
