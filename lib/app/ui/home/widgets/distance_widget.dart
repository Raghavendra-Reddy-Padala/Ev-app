import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/theme.dart';

class DistanceWidget extends StatelessWidget {
  final int distance;

  const DistanceWidget({super.key, required this.distance});

  @override
  Widget build(BuildContext context) {
    final Texts texts = Texts();

    return SizedBox(
      width: 65.h,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDistanceIcon(),
              texts.distance,
              Text(
                "$distance Km",
                style: CustomTextTheme.bodySmallXPBold
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildDistanceIcon() {
    return SizedBox(
      width: 20.w,
      height: 20.w,
      child: Image.asset(
        AssetsStrings.distance,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDivider() {
    return SizedBox(
      height: 60.h,
      child: const VerticalDivider(
        color: Colors.white,
      ),
    );
  }
}
