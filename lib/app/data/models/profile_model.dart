class InviteCodeResponse {
  final bool success;
  final InviteCodeData data;
  final String message;

  const InviteCodeResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory InviteCodeResponse.fromJson(Map<String, dynamic> json) {
    return InviteCodeResponse(
      success: json['success'] ?? false,
      data: InviteCodeData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class InviteCodeData {
  final String referralCode;

  const InviteCodeData({
    required this.referralCode,
  });

  factory InviteCodeData.fromJson(Map<String, dynamic> json) {
    return InviteCodeData(
      referralCode: json['referral_code'] ?? '',
    );
  }
}

class ReferralBenefitsResponse {
  final bool success;
  final ReferralBenefitsData data;
  final String message;

  const ReferralBenefitsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ReferralBenefitsResponse.fromJson(Map<String, dynamic> json) {
    return ReferralBenefitsResponse(
      success: json['success'] ?? false,
      data: ReferralBenefitsData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ReferralBenefitsData {
  final String description;
  final int discountPercentage;
  final int maxDiscount;

  const ReferralBenefitsData({
    required this.description,
    required this.discountPercentage,
    required this.maxDiscount,
  });

  factory ReferralBenefitsData.fromJson(Map<String, dynamic> json) {
    return ReferralBenefitsData(
      description: json['description'] ?? '',
      discountPercentage: json['discount_percentage'] ?? 0,
      maxDiscount: json['max_discount'] ?? 0,
    );
  }
}
