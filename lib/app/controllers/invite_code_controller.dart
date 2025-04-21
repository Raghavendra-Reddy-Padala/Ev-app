class InviteCodeController extends GetxController {
  final InviteCodeService _inviteCodeService;
  final SharedPreferencesService _prefsService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString referralCode = ''.obs;
  final Rx<ReferralBenefitsData?> benefits = Rx<ReferralBenefitsData?>(null);

  final String androidAppUrl =
      'https://play.google.com/store/apps/details?id=com.Mjollnir.bikeapp';
  final String iosAppUrl = 'https://apps.apple.com/app/Mjollnir/id69696969';

  InviteCodeController(this._inviteCodeService)
      : _prefsService = Get.find<SharedPreferencesService>();

  @override
  void onInit() {
    super.onInit();
    fetchReferralCode();
    fetchReferralBenefits();
  }

  void handleUnauthorized() {
    NavigationService.pushReplacementTo(const LoginMainView());
  }

  Future<void> fetchReferralCode() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      String? authToken = _prefsService.getToken();
      if (authToken == null) {
        handleUnauthorized();
        return;
      }

      final response = await _inviteCodeService.getReferralCode(authToken);
      _handleCodeResponse(response);
    } on DioException catch (dioError) {
      _handleError(dioError);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleCodeResponse(Response response) {
    if (response.statusCode == 200) {
      final inviteResponse = InviteCodeResponse.fromJson(response.data);

      if (inviteResponse.success) {
        referralCode.value = inviteResponse.data.referralCode;
      } else {
        errorMessage.value = inviteResponse.message;
      }
    } else if (response.statusCode == 401) {
      handleUnauthorized();
    } else {
      errorMessage.value = 'Failed to fetch referral code. Please try again.';
    }
  }

  Future<void> fetchReferralBenefits() async {
    try {
      String? authToken = _prefsService.getToken();

      if (authToken == null) {
        return;
      }

      final response = await _inviteCodeService.getReferralBenefits(authToken);
      _handleBenefitsResponse(response);
    } on DioException catch (dioError) {
      logger.e(dioError);
    } catch (e) {
      logger.e(e);
    }
  }

  void _handleBenefitsResponse(Response response) {
    if (response.statusCode == 200) {
      final benefitsResponse = ReferralBenefitsResponse.fromJson(response.data);

      if (benefitsResponse.success) {
        benefits.value = benefitsResponse.data;
      }
    } else if (response.statusCode == 401) {
      handleUnauthorized();
    }
  }

  Future<void> copyReferralCode() async {
    if (referralCode.value.isEmpty) {
      await fetchReferralCode();
    }

    if (referralCode.value.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: referralCode.value));

      AdvancedBubbleNotification.show(
        Get.context!,
        "Invite code copied: \${referralCode.value}",
        type: MessageType.success,
      );
    }
  }

  Future<void> shareReferralCode() async {
    if (referralCode.value.isEmpty) {
      await fetchReferralCode();
    }

    if (referralCode.value.isNotEmpty) {
      final String shareMessage = _createShareMessage();

      try {
        await Share.share(shareMessage);
      } catch (e) {
        logger.e('Error sharing referral code: \$e');

        AdvancedBubbleNotification.show(
          Get.context!,
          "Couldn't share the referral code. Please try again.",
          type: MessageType.error,
        );
      }
    }
  }

  String _createShareMessage() {
    String benefitsText = '';

    if (benefits.value != null && benefits.value!.description.isNotEmpty) {
      benefitsText = '\n\n\${benefits.value!.description}';
    }

    return 'Join me on the Mjollnir Bike Rental App! '
        'Use my referral code \${referralCode.value} to get special benefits.'
        '\$benefitsText\n\nDownload the app here:\n\n'
        'Android: \$androidAppUrl\niOS: \$iosAppUrl';
  }

  Future<bool> validateReferralCode(String code) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      String? authToken = _prefsService.getToken();
      if (authToken == null) {
        return false;
      }

      final response =
          await _inviteCodeService.validateReferralCode(authToken, code);
      return _handleValidationResponse(response);
    } on DioException catch (dioError) {
      _handleError(dioError);
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool _handleValidationResponse(Response response) {
    if (response.statusCode == 200) {
      final bool result = response.data['success'] ?? false;

      if (!result) {
        errorMessage.value =
            response.data['message'] ?? 'Invalid referral code';
      }

      return result;
    } else if (response.statusCode == 401) {
      handleUnauthorized();
      return false;
    } else {
      errorMessage.value =
          'Failed to validate referral code. Please try again.';
      return false;
    }
  }

  void _handleError(dynamic error) {
    logger.e(error);
    errorMessage.value = 'An unexpected error occurred';
  }
}
