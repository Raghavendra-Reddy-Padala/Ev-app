import 'dart:convert';

import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/main.dart';

import '../../../core/storage/local_storage.dart';

class FollowController extends GetxController {
  RxBool isLoading = false.obs;
  final RxMap<String, bool> followedUsers = <String, bool>{}.obs;
  final RxMap<String, bool> loadingUsers =
      <String, bool>{}.obs; 
  final LocalStorage localStorage = Get.find<LocalStorage>();

  Future<void> followUser(String userId) async {
    try {
      loadingUsers[userId] = true; 
      final response =
          await apiService.post(endpoint: 'user/follow/$userId', headers: {
        'Authorization': 'Bearer ${localStorage.getToken()}',
        'X-Karma-App': 'dafjcnalnsjn'
      });

      print('Response: $response');

      Map<String, dynamic> responseData;
      if (response is Map) {
        responseData = Map<String, dynamic>.from(response);
      } else if (response is String) {
        responseData = jsonDecode(response);
      } else {
        responseData = {'success': false, 'message': 'Invalid response format'};
      }

      print('Parsed response: $responseData');

      if (responseData['success'] == true) {
        followedUsers[userId] = true;
        showSuccessDialog();
      } else {
        Toast.show(
            message: responseData['message'] ?? 'Already following this user',
            type: ToastType.info);
      }
    } catch (e) {
      print('Error following user: $e');
      Toast.show(message: e.toString(), type: ToastType.error);
    } finally {
      loadingUsers[userId] = false;
    }
  }

  bool isUserLoading(String userId) {
    return loadingUsers[userId] ?? false;
  }

  void showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                  size: 50.w,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Success!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'You are now following the user',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  'Great!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
