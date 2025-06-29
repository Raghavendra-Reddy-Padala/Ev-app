import 'dart:convert';
import 'package:bolt_ui_kit/theme/text_themes.dart' show AppTextThemes;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/home/views/plandetialscreen.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/bike/bike_model.dart' as b;
import 'package:mjollnir/shared/models/subscriptions/subscriptions_model.dart';
import 'package:http/http.dart' as http;

class FetchPlans extends GetxController {
  var planResponse = Rxn<PlanResponse>();
  var isLoading = false.obs;
    final LocalStorage localStorage = Get.find<LocalStorage>();

  Future<void> fetchPlan(String bikeId) async {
  try {
    isLoading.value = true;
    final String? authToken = localStorage.getToken();
    print(authToken);
    
    if (authToken == null) {
      throw Exception('Authentication token not found');
    }
    
    final response = await http.get(
      Uri.parse("https://ev.coffeecodes.in/v1/subscriptions/station/$bikeId"),
      headers: {
        'Authorization': 'Bearer $authToken',
        'X-Karma-App': 'dafjcnalnsjn',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      
      // Check if the API response indicates success and has data
      if (jsonData['success'] == true) {
        // Handle null data case
        if (jsonData['data'] != null) {
          planResponse.value = PlanResponse.fromJson(jsonData);
        } else {
          // Handle null data case - you can either:
          // Option 1: Set planResponse to null or a default value
          planResponse.value = null;
          
          // Option 2: Create an empty PlanResponse (if your model supports it)
          // planResponse.value = PlanResponse.empty();
          
          // Option 3: Log the message for debugging
          AppLogger.i("No subscription data available: ${jsonData['message']}");
        }
      } else {
        // API returned success: false
        String errorMessage = jsonData['message'] ?? 'Unknown error occurred';
        throw Exception("API Error: $errorMessage");
      }
    } else {
      throw Exception("Failed to load plan data: ${response.statusCode}");
    }
  } catch (e) {
    AppLogger.e("Error fetching plan: $e");
    // Set planResponse to null on error
    planResponse.value = null;
  } finally {
    isLoading.value = false;
  }
}
}

class PlanType extends StatelessWidget {
  final b.Bike bike;
  const PlanType({super.key, required this.bike});
  
  @override
  Widget build(BuildContext context) {
    final FetchPlans controller = Get.put(FetchPlans());
    controller.fetchPlan(bike.stationId);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            const Header(heading: 'Select Plan'),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (controller.planResponse.value == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'No plans available',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'There are currently no subscription plans\navailable for this bike',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => controller.fetchPlan(bike.id),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.primary),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, 
                                    vertical: 10.h
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.refresh,
                                  color: AppColors.primary,
                                  size: 18.sp,
                                ),
                                label: Text(
                                  'Refresh',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                            
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  PlanResponse planResponse = controller.planResponse.value!;
                  
                  if (planResponse.data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No plans available',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: planResponse.data.map((plan) {
                        return PlanTypeWidget(
                          bike: bike, 
                          planData: plan,
                          planResponse: planResponse,
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
            ),
          ]
        ),
      ),
    );
  }
}

class PlanTypeWidget extends StatelessWidget {
  final PlanResponse planResponse;
  final PlanData planData;
  final b.Bike bike;
  
  const PlanTypeWidget({
    super.key, 
    required this.planResponse, 
    required this.planData,
    required this.bike,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.accent1,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
      ),
      width: ScreenUtil().screenWidth,
      height: 170.h,
      child: Padding(
        padding: EdgeInsets.all(20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      planData.bikeType.toUpperCase(),
                      style: AppTextThemes.bodySmall().copyWith(fontSize: 8.sp),
                    ),
                    SizedBox(
                      width: 90.w,
                      height: 60.h,
                      child: Image.network(
                        "https://toppng.com/uploads/preview/cycle-hd-images-11549761022izaeyhmkgm.png"
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 150.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60.w,
                        height: 60.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Price",
                              style: AppTextThemes.bodySmall().copyWith(
                                color: AppColors.primary,
                                fontSize: 9.sp,
                              ),
                            ),
                            Text(
                              '₹${planData.monthlyFee}${(planData.type == 'instantly') ? '/Hr' : ''}',
                              style: AppTextThemes.bodySmall().copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ]
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: SizedBox(
                          height: 60.h,
                          child: VerticalDivider(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 60.w,
                        height: 60.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Time",
                              style: AppTextThemes.bodySmall().copyWith(
                                color: AppColors.primary,
                                fontSize: 9.sp,
                              ),
                            ),
                            Text(
                              planData.type,
                              style: AppTextThemes.bodySmall().copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(ScreenUtil().screenWidth, 40.h),
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                // Create a temporary PlanResponse with single plan for backwards compatibility
                PlanResponse singlePlanResponse = PlanResponse(
                  success: planResponse.success,
                  data: [planData], // Single plan in array
                  message: planResponse.message,
                  error: planResponse.error,
                );
                
                Get.to(PlanDetailsScreen(
                  planResponse: singlePlanResponse, 
                  bike: bike
                ));
              },
              child: Text(
                (planData.type == 'instantly') ? "Scan" : "Subscribe",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ]
        ),
      )
    );
  }
}