class Faq {
  final String id;
  final String question;
  final String answer;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class FaqResponse {
  final bool success;
  final List<Faq> data;
  final String message;

  FaqResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    return FaqResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List).map((item) => Faq.fromJson(item)).toList(),
      message: json['message'] ?? '',
    );
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
