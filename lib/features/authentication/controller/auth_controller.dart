import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/routes/app_routes.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../core/services/image_service.dart';
import '../../../main.dart';
import '../../../shared/components/otp/otp_modal.dart';
import '../../../shared/models/auth/auth_models.dart';

enum AuthState { login, otp, register }

class AuthController extends BaseController {
  final Rxn<User> currentUser = Rxn<User>();

  //Form controllers for login
  final TextEditingController phoneController = TextEditingController();
  // Form controllers for signup
  final RxString storedOtp = ''.obs;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController addressLineController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController inviteCodeController = TextEditingController();
  // Observable values for signup
  final Rx<String> heightUnit = 'cm'.obs;
  final Rx<String> weightUnit = 'kg'.obs;
  final Rx<String> gender = ''.obs;
  final Rx<String> userType = "student".obs;
  final Rx<String?> profileImageUrl = Rx<String?>(null);
  final RxInt currentStep = 1.obs;
  final Rx<AuthState> authState = AuthState.login.obs;
  final RxBool isOtpVerified = false.obs;
  final RxBool isOtpFailed = false.obs;
  final RxInt resendTimer = 0.obs;
  Timer? _resendTimerInstance;

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

  bool validateFinal() {
    if (addressLineController.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty ||
        pincodeController.text.isEmpty ||
        countryController.text.isEmpty) {
      showErrorToast('Please fill in all fields');
      return false;
    }

    return true;
  }

  void validateAndContinue() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        dobController.text.isEmpty ||
        gender.value.isEmpty) {
      showErrorToast('Please fill in all fields');
      return;
    }

    currentStep.value = 2;
    update();
  }

  void validateSecondFormAndContinue() {
    if (emailController.text.isEmpty ||
        heightController.text.isEmpty ||
        weightController.text.isEmpty ||
        (userType.value != "general" &&
            (placeController.text.isEmpty || idController.text.isEmpty))) {
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

Future<void> updateProfileImage(dynamic source) async {
  try {
    if (source is ImageSource) {
      final url = await ImageService.pickAndUploadImage(
        type: ImageType.avatar,
        source: source,
      );
      if (url != null) {
        profileImageUrl.value = url;
      }
    } else if (source is String) {
      profileImageUrl.value = source;
    }
  } catch (e) {
    showErrorToast('Failed to update image: ${e.toString()}');
  }
}
  void completeSignup() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final List<String> dobParts = dobController.text.split('/');
      final String formattedDob =
          '${dobParts[2]}-${dobParts[1]}-${dobParts[0]}';
      final dob = DateTime.parse(formattedDob);
      final age = DateTime.now().year - dob.year;

      final signupRequest = SignupRequest(
        phone: '+91${phoneController.text}',
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        dateOfBirth: formattedDob,
        gender: gender.value,
        height: heightController.text,
        weight: weightController.text,
        type: userType.value,
        email: emailController.text,
        avatar: profileImageUrl.value ?? '',
        employee_id: userType.value == "employee" ? idController.text : '',
        student_id: userType.value == "student" ? idController.text : '',
        college: userType.value == "student" ? placeController.text : '',
        company: userType.value == "employee" ? placeController.text : '',
        otp: storedOtp.value,
        password: '',
        banner: '',
        weightUnit: weightUnit.value,
        heightUnit: heightUnit.value,
        place: userType.value == "general" ? placeController.text : '',
        age: age.toString(),
        points: 0,
        inviteCode: inviteCodeController.text,
        addressLine: addressLineController.text,
        city: cityController.text,
        state: stateController.text,
        pincode: pincodeController.text,
        country: countryController.text,
      );

      final response = await signup(signupRequest);

      if (response != null && response.success) {
        resetSignupData();
        Get.offAllNamed(Routes.HOME);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void showErrorToast(String message) {
    Toast.show(message: message, type: ToastType.error);
  }

  void handleGoogleLogin() {
    showErrorToast('Google login not implemented yet');
  }

  void startResendTimer() {
    resendTimer.value = 30;
    _resendTimerInstance?.cancel();
    _resendTimerInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void handleLogin() async {
    if (phoneController.text.isEmpty || phoneController.text.length != 10) {
      showErrorToast('Please enter a valid phone number');
      return;
    }

    try {
      isLoading.value = true;
      final response = await login(phoneController.text);

      if (response != null && response.success) {
        //authState.value = AuthState.otp;
        startResendTimer();
        OtpBottomSheet.show(Get.context!, this);
      } else {
        showErrorToast('Failed to login. Please try again.');
      }
    } finally {
      isLoading.value = false;
    }
  }

 Future<LoginResponse?> login(String phone) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = {'phone': '+91$phone'};

      final apiResponse = await apiService.post(
        endpoint: ApiConstants.login,
        headers: {
          'Content-Type': 'application/json',
          'X-Karma-App': 'dafjcnalnsjn'
        },
        body: data,
      );
      
     AppLogger.i('Login API Response: $apiResponse');
      
      if (apiResponse != null) {
        final response = LoginResponse.fromJson(apiResponse);
       AppLogger.i('Login Response Success: ${response.success}');
        return response;
      }
      return null;
    } catch (e) {
   AppLogger.e('Login Error: $e');
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
      storedOtp.value = otp;
      
      final data = {
        'phone': '+91$phone',
        'otp': otp,
      };

      final apiResponse = await apiService.post(
        endpoint: ApiConstants.verifyOtp,
        headers: {
          'Content-Type': 'application/json',
          'X-Karma-App': 'dafjcnalnsjn'
        },
        body: data,
      );

    AppLogger.i('OTP Verify API Response: $apiResponse');

      if (apiResponse != null) {
        final response = OtpResponse.fromJson(apiResponse);
      AppLogger.i('Account Exists: ${response.data.accountExists}');
        AppLogger.i('Token: ${response.data.token}');
        
        if (response.success && response.data.token != null) {
          await localStorage.setToken(response.data.token!);
          await localStorage.setLoggedIn(true);
          
          // Verify token was stored
          final storedToken = await localStorage.getToken();
          AppLogger.i('Token stored successfully: $storedToken');
        }
        
        return response;
      }
      return null;
    } catch (e) {
      AppLogger.i('OTP Verify Error: $e');
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
      AppLogger.i('Current token before signup: $token');
      
      final headers = {
        'Content-Type': 'application/json',
        'X-Karma-App': 'dafjcnalnsjn',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };


      final apiResponse = await apiService.post(
        endpoint: ApiConstants.signup,
        headers: headers,
        body: signupRequest.toJson(),
      );


      if (apiResponse != null) {
        final response = SignupResponse.fromJson(apiResponse);
        AppLogger.i('Signup Response Success: ${response.success}');
        AppLogger.i('New Token: ${response.data}');
        
        if (response.success && response.data != null) {
          await localStorage.setToken(response.data);
          await localStorage.setLoggedIn(true);
          
          final storedToken = await localStorage.getToken();
          AppLogger.i('New token stored successfully: $storedToken');
        }
        
        return response;
      }
      return null;
    } catch (e) {
      AppLogger.i('Signup Error: $e');
      handleError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleOtpVerification(String otpValue) async {
    if (otpValue.length != 6) {
      showErrorToast('Please enter a valid 6-digit OTP');
      return;
    }

    try {
      isLoading.value = true;
      final response = await verifyOtp(phoneController.text, otpValue);

      if (response != null && response.success) {
        isOtpVerified.value = true;
        isOtpFailed.value = false;
        //Navigator.of(Get.context!).pop();

        if (!response.data.accountExists) {
          initSignup(phoneController.text);
          Get.toNamed(Routes.REGISTER);
        } else {
          Get.offAllNamed(Routes.HOME);
        }
      } else {
        isOtpFailed.value = true;
        isOtpVerified.value = false;
        showErrorToast('Invalid OTP. Please try again.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() {
    if (resendTimer.value > 0) return;

    handleLogin();
  }

  void goBackToLogin() {
    authState.value = AuthState.login;
    isOtpVerified.value = false;
    isOtpFailed.value = false;
    _resendTimerInstance?.cancel();
  }

void goToPreviousStep() {
  if (currentStep.value > 1) {
    currentStep.value--;
    update();
  }
}
void goToStep(int step) {
  if (step >= 1 && step <= 3) {
    currentStep.value = step;
    update();
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
    addressLineController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
    inviteCodeController.dispose();
    super.onClose();
  }
}
