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
  final Rxn<List<UserSubscriptionData>> userSubscriptions =
      Rxn<List<UserSubscriptionData>>();
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

      AppLogger.i('Subscribe response: $response');

      if (response != null) {
        AppLogger.i('Successfully subscribed to plan: $id');
        return true;
      } else {
        final errorMsg = response['message'] ?? 'Unknown error occurred';
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

      AppLogger.i('Fetch plans response: $response');

      if (response != null && response['success'] == true) {
        final planResponse = PlanResponse.fromJson(response);
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
        endpoint: ApiConstants.userSubscriptions,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'X-Karma-App': 'dafjcnalnsjn',
        },
      );

      AppLogger.i('Fetch user subscriptions response: $response');

      if (response != null && response['success'] == true) {
        final List<dynamic> subscriptionsList = response['data'];

        if (subscriptionsList.isNotEmpty) {
          final List<UserSubscriptionData> subscriptions = subscriptionsList
              .map((item) {
                final userSubData = item['user_subscriptions'];
                final subData = item['subscriptions'];

                // Check if all required fields have values
                if (subData['name'].toString().isEmpty &&
                    subData['monthly_fee'] == 0 &&
                    userSubData['start_date'].toString().isEmpty) {
                  return null; // Skip invalid subscriptions
                }

                return UserSubscriptionData(
                  tableName: subData['TableName'] ?? '',
                  id: subData['id'] ?? '',
                  monthlyFee: (subData['monthly_fee'] ?? 0.0).toDouble(),
                  discount: (subData['discount'] ?? 0.0).toDouble(),
                  name: subData['name'] ?? '',
                  stationId: subData['station_id'] ?? '',
                  bikeType: subData['bike_type'] ?? '',
                  type: subData['type'] ?? '',
                  securityDeposit:
                      (subData['security_deposit'] ?? 0.0).toDouble(),
                  startDate: userSubData['start_date'] ?? '',
                  endDate: userSubData['end_date'] ?? '',
                  subscriptionStatus: _determineSubscriptionStatus(
                    userSubData['start_date'] ?? '',
                    userSubData['end_date'] ?? '',
                  ),
                );
              })
              .whereType<UserSubscriptionData>()
              .toList(); // Filter out null values

          if (subscriptions.isNotEmpty) {
            userSubscriptions.value = subscriptions;
            AppLogger.i(
                'Successfully fetched ${subscriptions.length} valid user subscriptions');
          } else {
            AppLogger.w('No valid user subscriptions found');
            userSubscriptions.value = [];
          }
        } else {
          AppLogger.w('No user subscriptions found in response');
          userSubscriptions.value = [];
        }
      } else {
        final errorMsg =
            response?['message'] ?? 'Failed to fetch user subscriptions';
        throw Exception(errorMsg);
      }
    } catch (e) {
      AppLogger.e('Error fetching user subscriptions: $e');
      errorMessage.value =
          'Failed to load user subscriptions. Please try again.';
      userSubscriptions.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  String _determineSubscriptionStatus(String startDate, String endDate) {
    if (startDate.isEmpty || endDate.isEmpty) return 'Unknown';

    try {
      final startParts = startDate.split('/');
      final endParts = endDate.split('/');

      if (startParts.length != 3 || endParts.length != 3) return 'Unknown';

      final startDateTime = DateTime(
        int.parse(startParts[2]), // year
        int.parse(startParts[1]), // month
        int.parse(startParts[0]), // day
      );

      final endDateTime = DateTime(
        int.parse(endParts[2]), // year
        int.parse(endParts[1]), // month
        int.parse(endParts[0]), // day
      );

      final now = DateTime.now();

      if (now.isBefore(startDateTime)) return 'Pending';
      if (now.isAfter(endDateTime)) return 'Expired';
      return 'Active';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> refreshAvailablePlans() async {
    AppLogger.i('Refreshing available plans data...');
    await fetchAvailablePlans();
  }

  Future<void> refreshUserSubscriptions() async {
    AppLogger.i('Refreshing user subscriptions data...');
    await fetchUserSubscriptions();
  }

  void clearError() {
    errorMessage.value = '';
  }

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
