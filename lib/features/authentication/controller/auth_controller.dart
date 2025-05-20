import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/services/image_service.dart';
import '../../../main.dart';
import '../../../shared/models/auth/auth_models.dart';

class AuthController extends BaseController {
  final Rxn<User> currentUser = Rxn<User>();

  // Form controllers for signup
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Observable values for signup
  final Rx<String> heightUnit = 'cm'.obs;
  final Rx<String> weightUnit = 'kg'.obs;
  final Rx<String> gender = ''.obs;
  final Rx<String> userType = "student".obs;
  final Rx<String?> profileImageUrl = Rx<String?>(null);
  final RxInt currentStep = 1.obs;

  void initSignup(String phone) {
    phoneController.text = phone;
    currentStep.value = 1;
    resetSignupData();
  }

  void resetSignupData() {
    firstNameController.clear();
    lastNameController.clear();
    dobController.clear();
    placeController.clear();
    emailController.clear();
    idController.clear();
    heightController.clear();
    weightController.clear();
    heightUnit.value = 'cm';
    weightUnit.value = 'kg';
    gender.value = '';
    userType.value = 'student';
    profileImageUrl.value = null;
  }

  void validateAndContinue() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        dobController.text.isEmpty ||
        gender.value.isEmpty ||
        heightController.text.isEmpty ||
        weightController.text.isEmpty) {
      showErrorToast('Please fill in all fields');
      return;
    }

    currentStep.value = 2;
    update();
  }

  void validateSecondFormAndContinue() {
    if (placeController.text.isEmpty ||
        emailController.text.isEmpty ||
        (userType.value != "general" && idController.text.isEmpty)) {
      showErrorToast('Please fill in all fields');
      return;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      showErrorToast('Please enter a valid email address');
      return;
    }
    currentStep.value = 3;
    update();
  }

  Future<void> updateProfileImage() async {
    try {
      final url = await ImageService.pickAndUploadImage(type: ImageType.avatar);
      if (url != null) {
        profileImageUrl.value = url;
      }
    } catch (e) {
      showErrorToast('Failed to upload image: ${e.toString()}');
    }
  }

  void completeSignup() async {
    if (profileImageUrl.value == null) {
      showErrorToast('Please upload a profile picture');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final signupRequest = SignupRequest(
        phone: phoneController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        dateOfBirth: dobController.text,
        gender: gender.value,
        height: '${heightController.text} ${heightUnit.value}',
        weight: '${weightController.text} ${weightUnit.value}',
        type: userType.value,
        //place: placeController.text,
        email: emailController.text,
        avatar: profileImageUrl.value ?? '',
        employee_id: userType.value == "employee" ? idController.text : '',
        student_id: userType.value == "student" ? idController.text : '',
        otp: '',
        password: '',
        banner: '',
        college: '',
        company: '',
        weightUnit: '',
        heightUnit: '',
      );

      final response = await signup(signupRequest);

      if (response != null && response.success) {
        resetSignupData();
        Get.offAllNamed('/main');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void showErrorToast(String message) {
    Toast.show(message: message, type: ToastType.error);
  }

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
            data: Data(
                accountExists: true,
                testPhone: true,
                token: getToken().toString()),
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
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer \$token',
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
        await localStorage.setToken(response.data);
        await localStorage.setLoggedIn(true);
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
        await localStorage.setToken(response.data.token);
        await localStorage.setLoggedIn(true);
      }

      return response;
    } catch (e) {
      handleError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getToken() async {
    return localStorage.getToken();
  }

  Future<void> logout() async {
    await localStorage.logout();
    currentUser.value = null;
    resetSignupData();
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    placeController.dispose();
    emailController.dispose();
    idController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.onClose();
  }
}
