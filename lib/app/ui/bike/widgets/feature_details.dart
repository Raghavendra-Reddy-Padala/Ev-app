import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BikeFeatureDetail extends StatelessWidget {
  final String feature;
  final String value;

  const BikeFeatureDetail(
      {super.key, required this.feature, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          feature,
          style: CustomTextTheme.bodyMediumP.copyWith(
            color: EVColors.primary,
          ),
        ),
        Text(
          value,
          style: CustomTextTheme.bodyMediumPBold.copyWith(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
