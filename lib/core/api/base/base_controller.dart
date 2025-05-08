import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../storage/local_storage.dart';

abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxBool useDummyData = RxBool(false);
  final LocalStorage localStorage = Get.find<LocalStorage>();

  @override
  void onInit() {
    super.onInit();
    _checkDummyDataSetting();
  }

  Future<void> _checkDummyDataSetting() async {
    try {
      useDummyData.value = localStorage.getBool('useDummyData');
    } catch (e) {
      print('Error checking dummy data setting: $e');
      useDummyData.value = kDebugMode;
    }
  }

  void toggleDummyData(bool enable) {
    useDummyData.value = enable;
    localStorage.setBool('useDummyData', enable);
  }

  void resetState() {
    isLoading.value = false;
    errorMessage.value = '';
  }

  void handleError(dynamic error) {
    print('Error: $error');
    errorMessage.value = 'An unexpected error occurred. Please try again.';
    isLoading.value = false;
  }

  Future<T> useApiOrDummy<T>({
    required Future<T> Function() apiCall,
    required T Function() dummyData,
  }) async {
    if (useDummyData.value) {
      await Future.delayed(const Duration(milliseconds: 300));
      return dummyData();
    } else {
      return await apiCall();
    }
  }

  Future<String?> getToken() async {
    return localStorage.getToken();
  }
}
