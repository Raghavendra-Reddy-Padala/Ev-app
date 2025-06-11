import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/main.dart';
import 'package:mjollnir/shared/models/faq/faq_model.dart';
class FaqController extends GetxController {
  final RxList<Faq> faqs = <Faq>[].obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<bool> expandedStates = <bool>[].obs;

  

  Future<void> fetchFaqs() async {
    // Prevent multiple simultaneous calls
    if (isLoading.value) return;
    
    String? authToken = Get.find<LocalStorage>().getToken();
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final response = await apiService.get(
        endpoint: ApiConstants.faq,
        headers: {
          'Authorization': 'Bearer $authToken',
          'X-Karma-App': 'dafjcnalnsjn',
        },
      ).timeout(Duration(seconds: 30)); // Add timeout
      
      Map<String, dynamic> jsonData;
      
      if (response is Map<String, dynamic>) {
        jsonData = response;
      } else if (response is String) {
        jsonData = jsonDecode(response);
      } else {
        throw Exception('Unknown response type: ${response.runtimeType}');
      }
          
      final faqResponse = FaqResponse.fromJson(jsonData);
      if (faqResponse.success) {
        faqs.assignAll(faqResponse.data.data);
        // Initialize expanded states once
        expandedStates.assignAll(List.filled(faqResponse.data.data.length, false));
        AppLogger.i('Successfully loaded ${faqResponse.data.data.length} FAQs');
      } else {
        errorMessage.value = faqResponse.message.isNotEmpty 
            ? faqResponse.message 
            : 'Failed to load FAQs';
      }
    } on TimeoutException {
      errorMessage.value = 'Request timed out. Please check your connection.';
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching FAQs: $e');
      AppLogger.e('Stack trace: $stackTrace');
      errorMessage.value = 'An error occurred while fetching FAQs: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleExpansion(int index) {
    if (index < expandedStates.length) {
      expandedStates[index] = !expandedStates[index];
    }
  }

  Future<void> refreshFaqs() async {
    await fetchFaqs();
  }
}