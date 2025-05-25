import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/company/companylogo.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/bike/bike_model.dart';
import 'package:mjollnir/shared/models/subscriptions/subscriptions_model.dart';
import 'package:mjollnir/shared/subscriptions/subscription_controller.dart';

class PlanDetailsScreen extends StatelessWidget {
  final Bike bike;
  final PlanResponse planResponse;
  const PlanDetailsScreen(
      {super.key, required this.planResponse, required this.bike});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: UI(planResponse: planResponse, bike: bike)),
    );
  }
}

class UI extends StatelessWidget {
  final Bike bike;
  final PlanResponse planResponse;
  UI({super.key, required this.planResponse, required this.bike});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const CompanyLogoPadding(),
        Padding(
          padding: EdgeInsets.all(20.h),
          child: Container(
            width: ScreenUtil().screenWidth,
            height: 380.w,
            decoration: BoxDecoration(
              color: AppColors.accent1,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Monthly Unlimited",
                    style:
                        AppTextThemes.bodySmall().copyWith(color: Colors.black),
                  ),
                  SizedBox(height: 15.h),
                  SizedBox(
                    width: 80.w,
                    height: 50.h,
                    child: Image.network(
                        "https://toppng.com/uploads/preview/cycle-hd-images-11549761022izaeyhmkgm.png"),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    "MANUAL",
                    style: AppTextThemes.bodyMedium()
                        .copyWith(color: Colors.black),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    bike.frameNumber,
                    style: AppTextThemes.bodyMedium().copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Column(
                    children: [
                      HelperRow(
                          type: "Charges",
                          value: planResponse.data[0].monthlyFee.toString()),
                      const HelperRow(type: "Validity", value: "30 days"),
                      HelperRow(
                          type: "Discount",
                          value: planResponse.data[0].discount.toString()),
                      HelperRow(
                          type: "Security Deposit",
                          value:
                              planResponse.data[0].securityDeposit.toString()),
                    ],
                  ),
                  const Divider(),
                  HelperRow(
                    type: "Total",
                    value: (planResponse.data[0].monthlyFee -
                            planResponse.data[0].discount +
                            planResponse.data[0].securityDeposit)
                        .toStringAsFixed(2),
                  ),
                  SizedBox(
                    height: 10.h * 0.2,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
            width: ScreenUtil().screenWidth - 40.w,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () async {
                final SubscriptionController subs = Get.find();
                final ok = await subs.subscribe(id: planResponse.data[0].id);
                if (ok) {
                  Get.dialog(
                    AlertDialog(
                      title: const Text("Success"),
                      content: const Text("Subscription successful!"),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                ),
              ),
              child: Obx(() {
                final SubscriptionController subs = Get.find();
                if (subs.isLoading.value) {
                  return const CircularProgressIndicator(
                    color: Colors.white,
                  );
                } else {
                  return ElevatedButton(onPressed: () {}, child: Text("pay"));
                }
              }),
            )),
        SizedBox(
          height: 30.h,
        ),
      ],
    );
  }
}

class HelperRow extends StatelessWidget {
  final String type;
  final String value;
  const HelperRow({super.key, required this.type, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          type,
          style: AppTextThemes.bodyMedium().copyWith(
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: AppTextThemes.bodyMedium().copyWith(
            color: Colors.black,
          ),
        )
      ],
    );
  }

  ElevatedButton get pay => ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
        ),
        child: const Text(
          "Pay",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
}
