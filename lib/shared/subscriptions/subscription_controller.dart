import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/shared/models/subscriptions/subscriptions_model.dart';
import 'package:intl/intl.dart';


class SubscriptionController extends GetxController {
  final Dio _dio = Dio();
  final LocalStorage localStorgae = Get.find<LocalStorage>();
  final String _baseUrl = 'https://ev.coffeecodes.in/v1/user_subscription/get';
  final RxBool isLoading = false.obs;
  final Rxn<List<UserSubscriptionModel>> subscription =
      Rxn<List<UserSubscriptionModel>>();

  Future<bool> subscribe({required String id}) async {
    final DateTime now = DateTime.now();
    final String startDate = DateFormat('dd/MM/yyyy').format(now);
    final DateTime endDate = DateTime(now.year, now.month + 1, now.day);
    final String formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate);
    const String url = 'https://ev.coffeecodes.in/v1/user_subscription/create';
    final Map<String, String> body = {
      "subscription_id": id,
      "start_date": startDate,
      "end_date": formattedEndDate
    };
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${localStorgae.getToken()}',
        },
        body: body,
      );
      AppLogger.i(response.body);
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['message'] == 'success') {
        // showSuccessAnimation();
        return true;
      } else {
       AppLogger.e('Failed to subscribe: ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.e('Error occurred: $e');
      isLoading.value = false;
    } finally {
      isLoading.value = false;
      return false;
    }
  }

  Future<void> fetchSubscription() async {
    isLoading.value = true;
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${localStorgae.getToken()}',
          },
        ),
      );
      AppLogger.i(response.data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'];

        if (dataList.isNotEmpty) {
          subscription.value = dataList
              .map((item) => UserSubscriptionModel.fromJson(item))
              .toList();
        } else {
          throw Exception('No subscription data found.');
        }
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch subscription.');
      }
    } catch (e) {
      AppLogger.e('Error fetching subscription: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
