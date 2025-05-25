import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/main.dart';
import 'package:mjollnir/shared/models/subscriptions/subscriptions_model.dart';
import 'package:intl/intl.dart';

class SubscriptionController extends GetxController {
  final LocalStorage localStorage = Get.find<LocalStorage>();

  final RxBool isLoading = false.obs;
  final Rxn<List<PlanData>> availablePlans = Rxn<List<PlanData>>();
  final Rxn<List<UserSubscriptionModel>> userSubscriptions =
      Rxn<List<UserSubscriptionModel>>();
  final RxString errorMessage = ''.obs;

  /// Get authentication token
  Future<String?> getToken() async {
    try {
      return localStorage.getToken();
    } catch (e) {
      AppLogger.e('Error getting token: $e');
      return null;
    }
  }

  Future<bool> subscribe({required String id}) async {
    final DateTime now = DateTime.now();
    final String startDate = DateFormat('dd/MM/yyyy').format(now);
    final DateTime endDate = DateTime(now.year, now.month + 1, now.day);
    final String formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate);

    try {
      isLoading.value = true;
      errorMessage.value = '';

      AppLogger.i('Attempting to subscribe to plan: $id');

      final String? authToken = await getToken();
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await apiService.post(
        endpoint: ApiConstants.subscriptions,
        body: {
          "subscription_id": id,
          "start_date": startDate,
          "end_date": formattedEndDate
        },
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb2xsZWdlIjoiIiwiZW1haWwiOiIiLCJlbXBsb3llZV9pZCI6IiIsImV4cCI6MTc1MDc4MTg4MywiZ2VuZGVyIjoiIiwibmFtZSI6IiIsInBob25lIjoiKzkxOTAzMjMyMzA5NSIsInVpZCI6ImdfOXhrdDRlZDEifQ.f2EWnxtudDgLiyvkRU01MA6jPf5r5n_T4zDZ7CYTz78',
          'Content-Type': 'application/json',
        },
      );

      AppLogger.i('Subscribe response: ${response?.data}');

      if (response != null &&
          response.statusCode == 200 &&
          response.data['message'] == 'success') {
        AppLogger.i('Successfully subscribed to plan: $id');
        return true;
      } else {
        final errorMsg = response?.data['message'] ?? 'Unknown error occurred';
        AppLogger.e('Failed to subscribe: $errorMsg');
        errorMessage.value = errorMsg;
        return false;
      }
    } catch (e) {
      AppLogger.e('Error occurred during subscription: $e');
      errorMessage.value = 'Failed to subscribe. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAvailablePlans() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      AppLogger.i('Fetching available subscription plans...');

      final String? authToken = await getToken();
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await apiService.get(
        endpoint: ApiConstants.subscriptions,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'X-Karma-App': 'dafjcnalnsjn',
        },
      );

      AppLogger.i('Fetch plans response: ${response?.data}');

      if (response != null &&
          response.statusCode == 200 &&
          response.data['success'] == true) {
        final planResponse = PlanResponse.fromJson(response.data);
        availablePlans.value = planResponse.data;

        AppLogger.i(
            'Successfully fetched ${availablePlans.value?.length} subscription plans');
      } else {
        final errorMsg =
            response?.data['message'] ?? 'Failed to fetch subscription plans';
        throw Exception(errorMsg);
      }
    } catch (e) {
      AppLogger.e('Error fetching subscription plans: $e');
      errorMessage.value =
          'Failed to load subscription plans. Please try again.';
      availablePlans.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserSubscriptions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      AppLogger.i('Fetching user subscriptions...');

      final String? authToken = await getToken();
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await apiService.get(
        endpoint:
            ApiConstants.subscriptions, // You'll need to add this endpoint
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb2xsZWdlIjoiIiwiZW1haWwiOiIiLCJlbXBsb3llZV9pZCI6IiIsImV4cCI6MTc1MDc4MTg4MywiZ2VuZGVyIjoiIiwibmFtZSI6IiIsInBob25lIjoiKzkxOTAzMjMyMzA5NSIsInVpZCI6ImdfOXhrdDRlZDEifQ.f2EWnxtudDgLiyvkRU01MA6jPf5r5n_T4zDZ7CYTz78',
          'Content-Type': 'application/json',
          'X-Karma-App': 'dafjcnalnsjn',
        },
      );

      AppLogger.i('Fetch user subscriptions response: ${response?.data}');

      if (response != null &&
          response.statusCode == 200 &&
          response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'];

        if (dataList.isNotEmpty) {
          userSubscriptions.value = dataList
              .map((item) => UserSubscriptionModel.fromJson(item))
              .toList();

          AppLogger.i(
              'Successfully fetched ${userSubscriptions.value?.length} user subscriptions');
        } else {
          AppLogger.w('No user subscription data found in response');
          userSubscriptions.value = [];
        }
      } else {
        final errorMsg =
            response?.data['message'] ?? 'Failed to fetch user subscriptions';
        throw Exception(errorMsg);
      }
    } catch (e) {
      AppLogger.e('Error fetching user subscriptions: $e');
      errorMessage.value =
          'Failed to load user subscriptions. Please try again.';
      userSubscriptions.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh subscription data
  Future<void> refreshAvailablePlans() async {
    AppLogger.i('Refreshing available plans data...');
    await fetchAvailablePlans();
  }

  /// Refresh user subscriptions
  Future<void> refreshUserSubscriptions() async {
    AppLogger.i('Refreshing user subscriptions data...');
    await fetchUserSubscriptions();
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Check if available plans are loaded
  bool get hasAvailablePlans =>
      availablePlans.value != null && availablePlans.value!.isNotEmpty;

  /// Check if user subscriptions are loaded
  bool get hasUserSubscriptions =>
      userSubscriptions.value != null && userSubscriptions.value!.isNotEmpty;

  /// Get available plans count
  int get availablePlansCount => availablePlans.value?.length ?? 0;

  /// Get user subscriptions count
  int get userSubscriptionsCount => userSubscriptions.value?.length ?? 0;
}
