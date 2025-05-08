class User {
  String uid;
  String firstName;
  String lastName;
  String email;
  String avatar;
  int points;
  bool following;
  int trips;
  double distance;
  int followers;

  User({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatar,
    required this.points,
    this.following = false,
    this.trips = 0,
    this.distance = 0.0,
    this.followers = 1,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      avatar: json['avatar'],
      points: json['points'] ?? 0,
      following: json['following'] ?? false,
      trips: json['trips'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      followers: json['followers'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'trips': trips,
      'distance': distance,
      'followers': followers,
    };
  }
}

class TripLocation {
  final double latitude;
  final double longitude;

  TripLocation({required this.latitude, required this.longitude});

  factory TripLocation.fromJson(List<dynamic> json) {
    return TripLocation(
      latitude: json[0],
      longitude: json[1],
    );
  }
}

class TripLocationsResponse {
  final bool success;
  final List<TripLocation> data;
  final String message;

  TripLocationsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory TripLocationsResponse.fromJson(Map<String, dynamic> json) {
    return TripLocationsResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((location) => TripLocation.fromJson(location))
          .toList(),
      message: json['message'],
    );
  }
}

class PathPoint {
  final double lat;
  final double long;
  final DateTime? timestamp;
  final double elevation;

  PathPoint({
    required this.lat,
    required this.long,
    this.timestamp,
    required this.elevation,
  });

  factory PathPoint.fromJson(Map<String, dynamic> json) {
    return PathPoint(
      lat: (json['lat'] ?? 0).toDouble(),
      long: (json['long'] ?? 0).toDouble(),
      timestamp: DateParsingUtils.parseFlexibleDateTime(json['timestamp']),
      elevation: (json['elevation'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'long': long,
      'timestamp': timestamp?.toIso8601String() ?? '',
      'elevation': elevation,
    };
  }
}

class Trip {
  final String id;
  final String userId;
  final String bikeId;
  final String stationId;
  final DateTime? startTimestamp;
  final DateTime? endTimestamp;
  final double distance;
  final double duration;
  final double averageSpeed;
  final List<PathPoint> path;
  final int maxElevation;
  final double kcal;

  Trip({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.stationId,
    this.startTimestamp,
    this.endTimestamp,
    required this.distance,
    required this.duration,
    required this.averageSpeed,
    required this.path,
    required this.maxElevation,
    required this.kcal,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    print("Raw start_timestamp: ${json['start_timestamp']}");
    print("Raw end_timestamp: ${json['end_timestamp']}");

    DateTime? startTime =
        DateParsingUtils.parseFlexibleDateTime(json['start_timestamp']);
    DateTime? endTime =
        DateParsingUtils.parseFlexibleDateTime(json['end_timestamp']);

    print("Parsed start_timestamp: $startTime");
    print("Parsed end_timestamp: $endTime");

    List<PathPoint> pathPoints = [];
    if (json['path'] != null) {
      try {
        pathPoints = (json['path'] as List<dynamic>)
            .map((point) => PathPoint.fromJson(point as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print("Error parsing path: $e");
      }
    }

    return Trip(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      bikeId: json['bike_id'] ?? '',
      stationId: json['station_id'] ?? '',
      startTimestamp:
          DateParsingUtils.parseFlexibleDateTime(json['start_timestamp']),
      endTimestamp:
          DateParsingUtils.parseFlexibleDateTime(json['end_timestamp']),
      distance: (json['distance'] ?? 0).toDouble(),
      duration: (json['duration'] ?? 0).toDouble(),
      averageSpeed: (json['average_speed'] ?? 0).toDouble(),
      path: pathPoints,
      maxElevation: json['max_elevation'] ?? 0,
      kcal: (json['kcal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bike_id': bikeId,
      'station_id': stationId,
      'start_timestamp': startTimestamp?.toIso8601String() ?? '',
      'end_timestamp': endTimestamp?.toIso8601String() ?? '',
      'distance': distance,
      'duration': duration,
      'average_speed': averageSpeed,
      'path': path.map((point) => point.toJson()).toList(),
      'max_elevation': maxElevation,
      'kcal': kcal,
    };
  }
}

class TripsResponse {
  final bool success;
  final List<Trip> data;
  final String message;

  TripsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory TripsResponse.fromJson(Map<String, dynamic> json) {
    try {
      return TripsResponse(
        success: json['success'] ?? false,
        data: json['data'] != null
            ? (json['data'] as List).map((trip) => Trip.fromJson(trip)).toList()
            : [],
        message: json['message'] ?? '',
      );
    } catch (e) {
      print("Error parsing TripsResponse: $e");
      return TripsResponse(
        success: false,
        data: [],
        message: "Error parsing data: $e",
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((trip) => trip.toJson()).toList(),
      'message': message,
    };
  }
}

class DateParsingUtils {
  static DateTime? parseFlexibleDateTime(dynamic dateString) {
    if (dateString == null) return null;
    if (dateString is DateTime) return dateString;
    if (dateString.toString().isEmpty) return null;

    try {
      print("Attempting to parse date: $dateString");
      return DateTime.parse(dateString.toString());
    } catch (_) {
      try {
        if (dateString.toString().contains(' ')) {
          final converted = dateString.toString().replaceFirst(' ', 'T');
          try {
            return DateTime.parse(converted);
          } catch (_) {}
        }

        final regexBasic = RegExp(r'(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})');
        final matchBasic = regexBasic.firstMatch(dateString.toString());
        if (matchBasic != null) {
          final dateTimePart = matchBasic.group(1);
          return DateTime.parse(dateTimePart!.replaceAll(' ', 'T'));
        }
        final regexWithOffset = RegExp(
            r'(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})(.\d+)?([+-]\d{2}:\d{2})?');
        final matchWithOffset =
            regexWithOffset.firstMatch(dateString.toString());
        if (matchWithOffset != null) {
          final dateTimePart =
              matchWithOffset.group(1)?.replaceAll(' ', 'T') ?? '';
          final fractionPart = matchWithOffset.group(2) ?? '';
          final offsetPart = matchWithOffset.group(3) ?? '';
          return DateTime.parse('$dateTimePart$fractionPart$offsetPart');
        }
      } catch (e) {
        print("Advanced parsing failed for date: $dateString - $e");
      }
    }

    print("All parsing methods failed for date: $dateString - using null");
    return null;
  }

  static String formatDateSafe(DateTime? dateTime,
      {String defaultValue = 'N/A'}) {
    if (dateTime == null) return defaultValue;
    try {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return defaultValue;
    }
  }
}

class TimeTravelData {
  final DateTime date;
  final String dayOfWeek;
  final double timeTravelled;

  TimeTravelData(
      {required this.date,
      required this.dayOfWeek,
      required this.timeTravelled});

  factory TimeTravelData.fromJson(Map<String, dynamic> json) {
    return TimeTravelData(
      date: DateTime.parse(json['date']),
      dayOfWeek: json['day_of_week'],
      timeTravelled: json['time_travelled'],
    );
  }
}

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

class GetAllUsersResponse {
  bool success;
  List<User> data;
  String message;

  GetAllUsersResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory GetAllUsersResponse.fromJson(Map<String, dynamic> json) {
    var userList = json['data'] as List;
    List<User> users = userList.map((user) => User.fromJson(user)).toList();

    return GetAllUsersResponse(
      success: json['success'],
      data: users,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((user) => user.toJson()).toList(),
      'message': message,
    };
  }
}
