class LoginRequestModel {
  final String phone;

  LoginRequestModel({required this.phone});

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }
}

class LoginResponse {
  final bool success;
  final Data data;
  final String message;

  LoginResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      data: Data.fromJson(json['data']),
      message: json['message'],
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

class Data {
  final bool accountExists;
  final bool? testPhone;
  final String? token;

  Data({
    required this.accountExists,
    this.testPhone,
    this.token,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      accountExists: json['account_exists'],
      testPhone: json['test_phone'] ?? false,
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_exists': accountExists,
      'test_phone': testPhone ?? false,
      'token': token ?? ''
    };
  }
}

class OtpResponse {
  final bool success;
  final Data data;
  final String message;

  OtpResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'],
      data: Data.fromJson(json['data']),
      message: json['message'],
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

class SignupRequest {
  final String phone;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String height;
  final String weight;
  final String type;
  final String email;
  final String avatar;
  final String employee_id;
  final String student_id;
  final String college;
  final String company;
  final String otp;
  final String password;
  final String banner;
  final String weightUnit;
  final String heightUnit;
  final String place;
  // New fields
  final String age;
  final int points;
  final String inviteCode;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final String country;

  SignupRequest({
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.type,
    required this.email,
    required this.avatar,
    required this.employee_id,
    required this.student_id,
    required this.college,
    required this.company,
    required this.otp,
    required this.password,
    required this.banner,
    required this.weightUnit,
    required this.heightUnit,
    required this.place,
    // New fields
    required this.age,
    required this.points,
    required this.inviteCode,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'height': height,
        'weight': weight,
        'type': type,
        'email': email,
        'avatar': avatar,
        'employee_id': employee_id,
        'student_id': student_id,
        'college': college,
        'company': company,
        'otp': otp,
        'password': password,
        'banner': banner,
        'weight_unit': weightUnit,
        'height_unit': heightUnit,
        'place': place,
        // New fields
        'age': age,
        'points': points,
        'invite_code': inviteCode,
        'address_line': addressLine,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
      };
}

class SignupResponse {
  final bool success;
  final String data;
  final String message;

  SignupResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      success: json['success'],
      data: json['data'] ?? "",
      message: json['message'],
    );
  }
}
