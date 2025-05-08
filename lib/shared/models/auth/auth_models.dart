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
  final bool testPhone;

  Data({
    required this.accountExists,
    required this.testPhone,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      accountExists: json['account_exists'],
      testPhone: json['test_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_exists': accountExists,
      'test_phone': testPhone,
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
  final String otp;
  final String email;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String password;
  final String type;
  final String employee_id;
  final String company;
  final String college;
  final String student_id;
  final String height;
  final String weight;
  final String gender;
  final String avatar;
  final String banner;
  final String weightUnit;
  final String heightUnit;
  SignupRequest({
    required this.phone,
    required this.otp,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.password,
    required this.type,
    required this.college,
    required this.company,
    required this.employee_id,
    required this.student_id,
    required this.height,
    required this.weight,
    required this.gender,
    required this.avatar,
    required this.banner,
    required this.weightUnit,
    required this.heightUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'password': password,
      'type': type,
      'employee_id': employee_id,
      'company': company,
      'college': college,
      'student_id': student_id,
      'height': height,
      'weight': weight,
      'gender': gender,
      'avatar': avatar,
      'banner': banner,
      'weight_unit': weightUnit,
      'height_unit': heightUnit,
    };
  }
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
