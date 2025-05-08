import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';
import '../../../shared/models/auth/auth_models.dart';

class AuthController extends BaseController {
  final Rxn<User> currentUser = Rxn<User>();

  Future<LoginResponse?> login(String phone) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final String authToken = 'ajbkbakweiuy387yeuqqwfahdjhsabd';
      final data = {'phone': phone};

      final response = await useApiOrDummy(apiCall: () async {
        final apiResponse = await apiService.post(
          endpoint: '/v1/auth/login',
          headers: {
            'X-Karma-Admin-Auth': authToken,
            'Content-Type': 'application/json',
          },
          body: data,
        );

        if (apiResponse != null) {
          return LoginResponse.fromJson(apiResponse.data);
        }
        return null;
      }, dummyData: () {
        return LoginResponse(
            success: true,
            data: Data(accountExists: true, testPhone: true),
            message: "Login successful");
      });

      return response;
    } catch (e) {
      handleError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<SignupResponse?> signup(SignupRequest signupRequest) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final String? token = await getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await useApiOrDummy(apiCall: () async {
        final apiResponse = await apiService.post(
            endpoint: '/v1/auth/signup',
            headers: headers,
            body: signupRequest.toJson());

        if (apiResponse != null) {
          return SignupResponse.fromJson(apiResponse.data);
        }
        return null;
      }, dummyData: () {
        return SignupResponse(
            success: true,
            data: "dummy-auth-token-${DateTime.now().millisecondsSinceEpoch}",
            message: "User registered successfully");
      });

      if (response != null && response.success) {
        await _preferences.setToken(response.data);
        await _preferences.setLoggedIn(true);
      }

      return response;
    } catch (e) {
      handleError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<OtpResponse?> verifyOtp(String phone, String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = {
        'phone': phone,
        'otp': otp,
      };

      final response = await useApiOrDummy(apiCall: () async {
        final apiResponse =
            await apiService.post(endpoint: '/v1/auth/verify_otp', body: data);

        if (apiResponse != null) {
          return OtpResponse.fromJson(apiResponse.data);
        }
        return null;
      }, dummyData: () {
        return OtpResponse(
            success: true,
            data: Data(
                accountExists: true,
                testPhone: true,
                token:
                    "dummy-auth-token-${DateTime.now().millisecondsSinceEpoch}"),
            message: "OTP verified successfully");
      });

      if (response != null && response.success) {
        await _preferences.setToken(response.data.token);
        await _preferences.setLoggedIn(true);
      }

      return response;
    } catch (e) {
      handleError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _preferences.logout();
    currentUser.value = null;
  }
}
