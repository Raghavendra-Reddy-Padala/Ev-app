class ReferralBenefitsData {
  final String description;
  final int discountPercentage;
  final int maxDiscount;
  final String? termsAndConditions;
  final bool isActive;
  final DateTime? expiryDate;

  ReferralBenefitsData({
    required this.description,
    required this.discountPercentage,
    required this.maxDiscount,
    this.termsAndConditions,
    this.isActive = true,
    this.expiryDate,
  });

  factory ReferralBenefitsData.fromJson(Map<String, dynamic> json) {
    return ReferralBenefitsData(
      description: json['description'] ?? '',
      discountPercentage: json['discount_percentage'] ?? 0,
      maxDiscount: json['max_discount'] ?? 0,
      termsAndConditions: json['terms_and_conditions'],
      isActive: json['is_active'] ?? true,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'discount_percentage': discountPercentage,
      'max_discount': maxDiscount,
      'terms_and_conditions': termsAndConditions,
      'is_active': isActive,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}
