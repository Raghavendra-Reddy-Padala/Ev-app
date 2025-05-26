class PlanResponse {
  final bool success;
  final List<PlanData> data; // Changed from PlanData to List<PlanData>
  final String message;
  final String? error;

  PlanResponse({
    required this.success,
    required this.data,
    required this.message,
    this.error,
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    return PlanResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((item) => PlanData.fromJson(item as Map<String, dynamic>))
          .toList(), // Parse the array of plans
      message: json['message'] ?? '',
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((plan) => plan.toJson()).toList(),
      'message': message,
      'error': error,
    };
  }
}

class PlanData {
  final String tableName;
  final String id;
  final double monthlyFee;
  final double discount;
  final String name;
  final String stationId; // Added stationId field
  final String bikeType; // Added bikeType field
  final String type;
  final double securityDeposit;

  PlanData({
    required this.tableName,
    required this.id,
    required this.monthlyFee,
    required this.discount,
    required this.name,
    required this.stationId,
    required this.bikeType,
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
      stationId: json['station_id'] ?? '', // Parse stationId
      bikeType: json['bike_type'] ?? '', // Parse bikeType
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
      'station_id': stationId,
      'bike_type': bikeType,
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

class SubscriptionDetails {
  String id;
  double monthlyFee;
  double discount;
  String name;
  String bikeId;
  String type;
  double securityDeposit;

  SubscriptionDetails({
    required this.id,
    required this.monthlyFee,
    required this.discount,
    required this.name,
    required this.bikeId,
    required this.type,
    required this.securityDeposit,
  });

  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetails(
      id: json['id'],
      monthlyFee: (json['monthly_fee'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      name: json['name'],
      bikeId: json['bike_id'],
      type: json['type'],
      securityDeposit: (json['security_deposit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

class UserSubscriptionModel {
  UserSubscription userSubscription;
  SubscriptionDetails subscriptionDetails;

  UserSubscriptionModel({
    required this.userSubscription,
    required this.subscriptionDetails,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      userSubscription: UserSubscription.fromJson(json['user_subscriptions']),
      subscriptionDetails: SubscriptionDetails.fromJson(json['subscriptions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_subscriptions': userSubscription.toJson(),
      'subscriptions': subscriptionDetails.toJson(),
    };
  }
}

class UserSubscription {
  String id;
  String userId;
  String subscriptionId;
  String startDate;
  String endDate;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.startDate,
    required this.endDate,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['user_id'],
      subscriptionId: json['subscription_id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subscription_id': subscriptionId,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}

class UserSubscriptionData extends PlanData {
  final String startDate;
  final String endDate;
  final String subscriptionStatus;

  UserSubscriptionData({
    required super.tableName,
    required super.id,
    required super.monthlyFee,
    required super.discount,
    required super.name,
    required super.stationId,
    required super.bikeType,
    required super.type,
    required super.securityDeposit,
    required this.startDate,
    required this.endDate,
    required this.subscriptionStatus,
  });

  factory UserSubscriptionData.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionData(
      tableName: json['TableName'] ?? '',
      id: json['id'] ?? '',
      monthlyFee: (json['monthly_fee'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(), // Fixed typo here
      name: json['name'] ?? '',
      stationId: json['station_id'] ?? '',
      bikeType: json['bike_type'] ?? '',
      type: json['type'] ?? '',
      securityDeposit: (json['security_deposit'] ?? 0.0).toDouble(),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      subscriptionStatus: json['status'] ?? '',
    );
  }
}
