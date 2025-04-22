import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/constants.dart';
import '../../../utils/theme.dart';

class SpeedPageWidgets {
  static Widget buildInfoCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(color: EVColors.shadowColor),
          BoxShadow(
            color: EVColors.offwhite,
            spreadRadius: 0.0,
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: CustomTextTheme.bodyMediumPBold.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: ScreenUtil().screenWidth * 0.02),
              _buildUnitText(label),
            ],
          ),
          Text(
            textAlign: TextAlign.start,
            label,
            style: CustomTextTheme.bodyMediumPBold.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildUnitText(String label) {
    return Column(
      children: [
        SizedBox(height: ScreenUtil().screenHeight * 0.01),
        Text(
          label == "Distance" ? "km" : " ",
          style: CustomTextTheme.bodySmallPBold.copyWith(
            fontSize: 18,
            color: Colors.black,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
