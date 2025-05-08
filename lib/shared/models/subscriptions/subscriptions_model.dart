class PlanResponse {
  final bool success;
  final PlanData data;
  final String message;

  PlanResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    return PlanResponse(
      success: json['success'] ?? false,
      data: PlanData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
    };
  }
}

class PlanData {
  final String tableName;
  final String id;
  final double monthlyFee;
  final double discount;
  final String name;
  final String bikeId;
  final String type;
  final double securityDeposit;

  PlanData({
    required this.tableName,
    required this.id,
    required this.monthlyFee,
    required this.discount,
    required this.name,
    required this.bikeId,
    required this.type,
    required this.securityDeposit,
  });

  factory PlanData.fromJson(Map<String, dynamic> json) {
    return PlanData(
      tableName: json['TableName'] ?? '',
      id: json['id'] ?? '',
      monthlyFee: (json['monthly_fee'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      name: json['name'] ?? '',
      bikeId: json['bike_id'] ?? '',
      type: json['type'] ?? '',
      securityDeposit: (json['security_deposit'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TableName': tableName,
      'id': id,
      'monthly_fee': monthlyFee,
      'discount': discount,
      'name': name,
      'bike_id': bikeId,
      'type': type,
      'security_deposit': securityDeposit,
    };
  }
}

class Subscription {
  final String id;
  final String userId;
  final String subscriptionId;
  final String startDate;
  final String endDate;

  Subscription({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.startDate,
    required this.endDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      subscriptionId: json['subscription_id'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}

class SubscriptionResponse {
  final bool success;
  final Subscription data;
  final String message;

  SubscriptionResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] ?? false,
      data: Subscription.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}
