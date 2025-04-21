class UserDetailsResponse {
  final bool success;
  final UserDetails data;
  final String message;

  UserDetailsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory UserDetailsResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailsResponse(
      success: json['success'] ?? false,
      data: UserDetails.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': data.toMap(),
      'message': message,
    };
  }
}

class UserDetails {
  final String uid;
  final String phone;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String type;
  final String? employeeId;
  final String? company;
  final String college;
  final String studentId;
  final String avatar;
  final int points;
  final double height;
  final double weight;
  final int age;
  final int trips;
  final double distance;
  final int followers;
  final String? banner;

  UserDetails({
    required this.uid,
    required this.phone,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.type,
    this.employeeId,
    this.company,
    required this.college,
    required this.studentId,
    required this.height,
    required this.age,
    required this.avatar,
    required this.points,
    required this.weight,
    required this.trips,
    required this.distance,
    required this.followers,
    this.banner,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      uid: json['uid'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      type: json['type'] ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      college: json['college'] ?? '',
      studentId: json['student_id']?.toString() ?? '',
      height: _parseInt(json['height']).toDouble(),
      weight: _parseInt(json['weight']).toDouble(),
      points: _parseInt(json['points'], defaultValue: 0),
      avatar: json['avatar'] ?? '',
      age: _parseInt(json['age'], defaultValue: 0),
      trips: _parseInt(json['trips'], defaultValue: 0),
      distance: _parseInt(json['distance'], defaultValue: 0).toDouble(),
      followers: _parseInt(json['followers'], defaultValue: 0),
      banner: json['banner'] ?? '',
    );
  }
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  Map<String, dynamic> toMap() {
    return {
      'UID': uid,
      'Phone': phone,
      'Email': email,
      'First Name': firstName,
      'Last Name': lastName,
      'Date of Birth': dateOfBirth,
      'Type': type,
      if (employeeId != null && employeeId!.isNotEmpty)
        'Employee ID': employeeId,
      if (company != null && company!.isNotEmpty) 'Company': company,
      'College': college,
      'Student ID': studentId,
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

class SubscriptionResponse {
  bool success;
  List<UserSubscriptionModel> data;
  String message;

  SubscriptionResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'],
      data: List<UserSubscriptionModel>.from(
        json['data'].map((x) => UserSubscriptionModel.fromJson(x)),
      ),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
      'message': message,
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
