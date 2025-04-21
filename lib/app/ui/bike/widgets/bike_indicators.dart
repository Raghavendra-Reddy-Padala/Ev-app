import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BikeIndicators {
  static Widget buildPercentIndicator(BikeMetricsController controller) {
    return Container(
      height: 60.h,
      width: 180.w,
      decoration: _createBoxDecoration(),
      child: Obx(
        () => LinearPercentIndicator(
          width: 180.w,
          animation: true,
          lineHeight: 60.h,
          animationDuration: 2000,
          barRadius: Radius.circular(ScreenUtil().screenHeight * 0.01),
          percent: _convertToPercent(controller.batteryPercentage.value),
          backgroundColor: EVColors.grey1,
          padding: EdgeInsets.zero,
          center: Text(
            controller.batteryPercentage.value,
            style: CustomTextTheme.headlineMediumP.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          progressColor: EVColors.green,
        ),
      ),
    );
  }

  static double _convertToPercent(String batteryString) {
    try {
      final value = double.parse(batteryString.replaceAll('%', '').trim());
      return value / 100;
    } catch (e) {
      return 0.0;
    }
  }

  static BoxDecoration _createBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      boxShadow: [
        BoxShadow(color: EVColors.shadowColor),
        BoxShadow(
          color: EVColors.offwhite,
          spreadRadius: 0.0,
          blurRadius: 0.0,
        ),
      ],
    );
  }
}

class BikeInfoCards {
  static Widget buildSimpleCard(String text) {
    return Container(
      height: 60.w,
      width: 316.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(color: EVColors.shadowColor),
          BoxShadow(
            color: EVColors.offwhite,
            spreadRadius: 0.0,
            blurRadius: 0.0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: CustomTextTheme.bodySmallP.copyWith(color: Colors.black),
        ),
      ),
    );
  }

  static Widget buildInfoCard(String value, String label, Function()? onTap,
      [String? unit]) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(ScreenUtil().screenWidth * 0.02),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(color: EVColors.shadowColor),
              BoxShadow(
                color: EVColors.offwhite,
                spreadRadius: 0.0,
                blurRadius: 0.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    value,
                    style: CustomTextTheme.bodyMediumP
                        .copyWith(color: Colors.black),
                  ),
                  SizedBox(width: ScreenUtil().screenWidth * 0.02),
                  if (unit != null)
                    Text(
                      unit,
                      style: CustomTextTheme.bodySmallP
                          .copyWith(color: Colors.black),
                      textAlign: TextAlign.end,
                    ),
                ],
              ),
              Text(
                textAlign: TextAlign.start,
                label,
                style: CustomTextTheme.headlineSmallP
                    .copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: EVColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.arrow_forward,
                size: 16.0,
                color: EVColors.primary,
              ),
            ),
          ),
        )
      ],
    );
  }
}
