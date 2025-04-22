import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/constants.dart';
import 'feature_details.dart';

class BikeFeatureWidget extends StatelessWidget {
  final Bike bike;

  const BikeFeatureWidget({
    super.key,
    required this.bike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().screenHeight * 0.02),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BikeFeatureDetail(
              feature: "Top Speed",
              value: "${bike.topSpeed} km/h",
            ),
            _buildDivider(),
            BikeFeatureDetail(
              feature: "Range",
              value: "${bike.range} km",
            ),
            _buildDivider(),
            BikeFeatureDetail(
              feature: "Time",
              value: "${bike.timeToStation} hrs",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return VerticalDivider(
      color: EVColors.primary,
      thickness: 1,
      width: 10,
    );
  }
}
