import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/theme.dart';

class BikeFrameWidget extends StatelessWidget {
  final Bike bike;

  const BikeFrameWidget({super.key, required this.bike});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFrameNumberInfo(),
        _buildBikeImage(),
      ],
    );
  }

  Widget _buildFrameNumberInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().screenHeight * 0.01,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Frame Number",
            style: CustomTextTheme.bodySmallP.copyWith(
              color: Colors.grey,
            ),
          ),
          Text(
            bike.frameNumber,
            style: CustomTextTheme.bodyMediumPBold.copyWith(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBikeImage() {
    return SizedBox(
      width: 65.w,
      height: 65.h,
      child: Image.asset(
        AssetsStrings.bike,
      ),
    );
  }
}
