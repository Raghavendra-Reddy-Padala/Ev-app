import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mjollnir/core/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:mjollnir/core/api/base/base_controller.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/services/image_service.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';

import '../../../main.dart';
import '../../../shared/models/activity/activity_data_model.dart';
import '../../../shared/models/referrals/referral_model.dart';
import '../../../shared/models/subscriptions/subscriptions_model.dart';
import '../../../shared/models/trips/trips_model.dart';

class ProfileController extends BaseController {
  // User data
  final Rxn<UserDetailsResponse> userData = Rxn<UserDetailsResponse>();
  final Rxn<List<UserSubscriptionModel>> subscriptions =
      Rxn<List<UserSubscriptionModel>>();
  final Rx<ActivityGraphData?> activityGraphData = Rx<ActivityGraphData?>(null);
  final RxString selectedMetric = 'distance'.obs;
  final Rx<DateTimeRange> selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  ).obs;

  // Available metrics for the graph
  final List<String> availableMetrics = [
    'distance',
    'time',
    'calories',
    'trips'
  ];

  // Activity & stats
  final Rxn<TripSummaryModel> tripSummary = Rxn<TripSummaryModel>();
  final RxList<Trip> userTrips = <Trip>[].obs;

  // Invite system
  final RxString referralCode = ''.obs;
  final Rxn<ReferralBenefitsData> referralBenefits =
      Rxn<ReferralBenefitsData>();

  // UI State
  final RxBool isUpdatingProfile = false.obs;
  final RxBool isImageLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeProfile();
    _loadActivityGraphData();
  }

  Future<void> _loadActivityGraphData() async {
    await fetchActivityGraphData(selectedDateRange.value, selectedMetric.value);
  }

  Future<void> fetchActivityGraphData(
      DateTimeRange dateRange, String metric) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await getToken();
      if (token == null) {
        handleTokenExpired();
        return;
      }
      final response = await useApiOrDummy(
        apiCall: () async {
          final formattedStartDate =
              dateRange.start.toIso8601String().split('T')[0];
          final formattedEndDate =
              dateRange.end.toIso8601String().split('T')[0];

          return await apiService.get(
            endpoint:
                '${ApiConstants.activityGraph}?start_date=$formattedStartDate&end_date=$formattedEndDate&metric=$metric',
            headers: {
              'Authorization': 'Bearer $token',
              'X-Karma-App': 'dafjcnalnsjn',
            },
          );
        },
        dummyData: () => _getDummyActivityGraphData(dateRange, metric),
      );

      if (response != null) {
        activityGraphData.value =
            ActivityGraphData.fromJson(response, dateRange, metric);
      }
    } catch (e) {
      handleError(e);
      activityGraphData.value = ActivityGraphData.dummy(dateRange, metric);
    } finally {
      isLoading.value = false;
    }
  }

  void onDateRangeChanged(DateTimeRange newDateRange) {
    selectedDateRange.value = newDateRange;
    fetchActivityGraphData(newDateRange, selectedMetric.value);
  }

  void onMetricChanged(String newMetric) {
    selectedMetric.value = newMetric;
    fetchActivityGraphData(selectedDateRange.value, newMetric);
  }

  Future<void> _initializeProfile() async {
    await Future.wait([
      fetchUserDetails(),
      fetchTripSummary(),
      fetchUserTrips(),
      fetchReferralCode(),
      fetchSubscriptions(),
    ]);
  }

  Future<void> fetchUserDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await getToken();
      if (token == null) {
        handleTokenExpired();
        return;
      }

      final response = await useApiOrDummy(
        apiCall: () => apiService.get(
          endpoint: ApiConstants.userDetails,
          headers: {
            'Authorization': 'Bearer $token',
            'X-Karma-App': 'dafjcnalnsjn'
          },
        ),
        dummyData: () => _getDummyUserData(),
      );

      if (response != null) {
        userData.value = UserDetailsResponse.fromJson(response);
      }
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      isUpdatingProfile.value = true;
      errorMessage.value = '';

      final token = await getToken();
      if (token == null) return;

      final response = await useApiOrDummy(
        apiCall: () => apiService.post(
          endpoint: ApiConstants.updateProfile,
          headers: {
            'Authorization': 'Bearer $token',
            'X-Karma-App': 'dafjcnalnsjn'
          },
          body: profileData,
        ),
        dummyData: () => {'success': true, 'message': 'Profile updated'},
      );

      if (response != null && response['success'] == true) {
        Toast.show(
            message: 'Profile updated successfully', type: ToastType.success);
        await fetchUserDetails();
      }
    } catch (e) {
      handleError(e);
      // Toast.show(message: 'Failed to update profile', type: ToastType.error);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  Future<void> updateProfileImage(ImageSource source) async {
    try {
      isImageLoading.value = true;

      final url = await ImageService.pickAndUploadImage(
        type: ImageType.avatar,
        source: source,
      );

      if (url != null) {
        await updateProfile({'avatar': url});
        Toast.show(message: 'Profile picture updated', type: ToastType.success);
      }
    } catch (e) {
      // Toast.show(message: 'Failed to upload image', type: ToastType.error);
    } finally {
      isImageLoading.value = false;
    }
  }

  Future<void> fetchTripSummary() async {
    try {
      final token = await getToken();
      if (token == null) return;

      final response = await useApiOrDummy(
        apiCall: () => apiService.get(
          endpoint: ApiConstants.tripsSummary,
          headers: {
            'Authorization': 'Bearer $token',
            'X-Karma-App': 'dafjcnalnsjn'
          },
        ),
        dummyData: () => _getDummyTripSummary(),
      );

      if (response != null) {
        tripSummary.value = TripSummaryModel.fromJson(response);
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> fetchUserTrips() async {
    try {
      final token = await getToken();
      if (token == null) return;

      final response = await useApiOrDummy(
        apiCall: () => apiService.get(
          endpoint: ApiConstants.tripsMyTrips,
          headers: {
            'Authorization': 'Bearer $token',
            'X-Karma-App': 'dafjcnalnsjn'
          },
        ),
        dummyData: () => _getDummyTrips(),
      );

      if (response != null && response['data'] != null) {
        userTrips.value = (response['data'] as List)
            .map((trip) => Trip.fromJson(trip))
            .toList();
      }
    } catch (e) {
      handleError(e);
    }
  }

  // Subscriptions
  Future<void> fetchSubscriptions() async {
    try {
      final token = await getToken();
      if (token == null) return;

      final response = await useApiOrDummy(
        apiCall: () => apiService.get(
          endpoint: ApiConstants.userSubscriptions,
          headers: {
            'Authorization': 'Bearer $token',
            'X-Karma-App': 'dafjcnalnsjn'
          },
        ),
        dummyData: () => _getDummySubscriptions(),
      );

      if (response != null && response['data'] != null) {
        subscriptions.value = (response['data'] as List)
            .map((sub) => UserSubscriptionModel.fromJson(sub))
            .toList();
      }
    } catch (e) {
      handleError(e);
    }
  }

  // Referral System
  Future<void> fetchReferralCode() async {
    try {
      final token = await getToken();
      if (token == null) return;

      final response = await useApiOrDummy(
        apiCall: () => apiService.get(
          endpoint: ApiConstants.referralCode,
          headers: {
            'Authorization': 'Bearer $token',
            'X-Karma-App': 'dafjcnalnsjn'
          },
        ),
        dummyData: () => {
          'success': true,
          'data': {'referral_code': 'DEMO123'}
        },
      );

      if (response != null && response['success'] == true) {
        referralCode.value = response['data']['referral_code'] ?? '';
      }
    } catch (e) {
      handleError(e);
    }
  }

  // Future<void> _fetchReferralBenefits() async {
  //   try {
  //     final token = await getToken();
  //     if (token == null) return;

  //     final response = await useApiOrDummy(
  //       apiCall: () => apiService.get(
  //         endpoint: ApiConstants.referralBenefits,
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'X-Karma-App': 'dafjcnalnsjn'
  //         },
  //       ),
  //       dummyData: () => _getDummyReferralBenefits(),
  //     );

  //     if (response != null && response['success'] == true) {
  //       referralBenefits.value =
  //           ReferralBenefitsData.fromJson(response['data']);
  //     }
  //   } catch (e) {
  //     handleError(e);
  //   }
  // }

  Future<void> copyReferralCode() async {
    if (referralCode.value.isEmpty) {
      await fetchReferralCode();
    }

    if (referralCode.value.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: referralCode.value));
      Toast.show(
        message: 'Invite code copied: ${referralCode.value}',
        type: ToastType.success,
      );
    }
  }

  Future<void> shareReferralCode() async {
    if (referralCode.value.isEmpty) {
      await fetchReferralCode();
    }

    if (referralCode.value.isNotEmpty) {
      String benefitsText = '';
      if (referralBenefits.value?.description.isNotEmpty == true) {
        benefitsText = '\n\n${referralBenefits.value!.description}';
      }

      final shareMessage = 'Join me on the EV Bike Rental App! '
          'Use my referral code ${referralCode.value} to get special benefits.'
          '$benefitsText\n\nDownload the app now!';

      try {
        await Share.share(shareMessage);
      } catch (e) {
        // Toast.show(
        //   message: "Couldn't share the referral code. Please try again.",
        //   type: ToastType.error,
        // );
      }
    }
  }

  // Utility Methods
  Future<String?> getToken() async {
    return localStorage.getToken();
  }

  void handleTokenExpired() {
    localStorage.logout();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> logout() async {
    await localStorage.logout();
    userData.value = null;
    subscriptions.value = null;
    tripSummary.value = null;
    userTrips.clear();
    referralCode.value = '';
    referralBenefits.value = null;
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> refreshProfile() async {
    await _initializeProfile();
  }

  // Dummy Data Methods
  Map<String, dynamic> _getDummyUserData() => {
        'success': true,
        'data': {
          'uid': 'user_123',
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'john.doe@example.com',
          'phone': '+1234567890',
          'avatar': 'https://via.placeholder.com/150',
          'banner': 'https://via.placeholder.com/400x200',
          'points': 150,
          'distance': 25.5,
          'trips': 12,
          'followers': 5,
          'type': 'student',
          'college': 'Demo University',
          'date_of_birth': '1995-06-15',
        }
      };

  Map<String, dynamic> _getDummyTripSummary() => {
        'success': true,
        'data': {
          'total_trips': 12,
          'total_calories': 850,
          'highest_speed': 28.5,
          'total_time_hours': 15.5,
          'carbon_footprint_kg': 2.5,
          'averages': {
            'distance_km': 2.1,
            'calories_trip': 71,
            'speed_kmh': 18.2,
          },
          'longest_ride': {
            'distance_km': 8.5,
            'duration_hours': 1.2,
          },
          'max_elevation_m': 150,
        }
      };

  Map<String, dynamic> _getDummyTrips() => {
        'success': true,
        'data': List.generate(
            5,
            (index) => {
                  'id': 'trip_$index',
                  'distance': (index + 1) * 2.5,
                  'duration': (index + 1) * 0.5,
                  'start_timestamp': DateTime.now()
                      .subtract(Duration(days: index))
                      .toIso8601String(),
                  'end_timestamp': DateTime.now()
                      .subtract(Duration(days: index, hours: -1))
                      .toIso8601String(),
                  'average_speed': 18.0 + index,
                  'kcal': (index + 1) * 75.0,
                  'max_elevation': 100 + (index * 20),
                  'path': [],
                })
      };

  Map<String, dynamic> _getDummySubscriptions() => {
        'success': true,
        'data': [
          {
            'user_subscriptions': {
              'id': 'sub_1',
              'start_date': '01/12/2023',
              'end_date': '01/01/2024',
            },
            'subscriptions': {
              'name': 'Basic Plan',
              'monthly_fee': 29.99,
              'security_deposit': 100.00,
              'type': 'monthly',
            }
          }
        ]
      };
}

Map<String, dynamic> _getDummyActivityGraphData(
    DateTimeRange dateRange, String metric) {
  final dummyData = ActivityGraphData.dummy(dateRange, metric);

  return {
    'success': true,
    'data': dummyData.data.entries
        .map((entry) => {
              'value': entry.value,
              'label': dummyData.xLabels[entry.key] ?? '',
            })
        .toList(),
    'total_value': dummyData.totalValue,
    'unit': dummyData.unit,
    'metric': metric,
  };
}
