import 'package:intl/intl.dart';

class TripSummaryModel {
  final Averages averages;
  final double carbonFootprintKg;
  final double highestSpeed;
  final LongestRide longestRide;
  final int maxElevationM;
  final int totalCalories;
  final double totalTimeHours;
  final int totalTrips;

  TripSummaryModel({
    required this.averages,
    required this.carbonFootprintKg,
    required this.highestSpeed,
    required this.longestRide,
    required this.maxElevationM,
    required this.totalCalories,
    required this.totalTimeHours,
    required this.totalTrips,
  });

  factory TripSummaryModel.fromJson(Map<String, dynamic> json) {
    return TripSummaryModel(
      averages: Averages.fromJson(json['averages']),
      carbonFootprintKg: json['carbon_footprint_kg']?.toDouble() ?? 0.0,
      highestSpeed: json['highest_speed']?.toDouble() ?? 0.0,
      longestRide: LongestRide.fromJson(json['longest_ride']),
      maxElevationM: json['max_elevation_m'] ?? 0,
      totalCalories: json['total_calories'] ?? 0,
      totalTimeHours: json['total_time_hours']?.toDouble() ?? 0.0,
      totalTrips: json['total_trips'] ?? 0,
    );
  }
}

class TripMetrics {
  final double speed;
  final double distance;
  final double duration;
  final double calories;
  final double elevation;
  final String batteryPercentage;

  TripMetrics({
    required this.speed,
    required this.distance,
    required this.duration,
    required this.calories,
    required this.elevation,
    required this.batteryPercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'speed': speed,
      'distance': distance,
      'duration': duration,
      'calories': calories,
      'elevation': elevation,
      'battery_percentage': batteryPercentage,
    };
  }

  factory TripMetrics.fromJson(Map<String, dynamic> json) {
    return TripMetrics(
      speed: json['speed']?.toDouble() ?? 0.0,
      distance: json['distance']?.toDouble() ?? 0.0,
      duration: json['duration']?.toDouble() ?? 0.0,
      calories: json['calories']?.toDouble() ?? 0.0,
      elevation: json['elevation']?.toDouble() ?? 0.0,
      batteryPercentage: json['battery_percentage'] ?? '0%',
    );
  }
}

class Averages {
  final int caloriesTrip;
  final double distanceKm;
  final double speedKmh;

  Averages({
    required this.caloriesTrip,
    required this.distanceKm,
    required this.speedKmh,
  });

  factory Averages.fromJson(Map<String, dynamic> json) {
    return Averages(
      caloriesTrip: json['calories_trip'] ?? 0,
      distanceKm: json['distance_km']?.toDouble() ?? 0.0,
      speedKmh: json['speed_kmh']?.toDouble() ?? 0.0,
    );
  }
}

class LongestRide {
  final double distanceKm;
  final double durationHours;

  LongestRide({
    required this.distanceKm,
    required this.durationHours,
  });

  factory LongestRide.fromJson(Map<String, dynamic> json) {
    return LongestRide(
      distanceKm: json['distance_km']?.toDouble() ?? 0.0,
      durationHours: json['duration_hours']?.toDouble() ?? 0.0,
    );
  }
}

class EndTrip {
  final String id;
  final String bikeId;
  final String stationId;
  final DateTime startTimestamp;
  final DateTime endTimestamp;
  final double distance;
  final double duration;
  final double averageSpeed;
  final List<List<double>> path;

  EndTrip({
    required this.id,
    required this.bikeId,
    required this.stationId,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.distance,
    required this.duration,
    required this.averageSpeed,
    required this.path,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bike_id': bikeId,
      'station_id': stationId,
      'start_timestamp': startTimestamp.toIso8601String(),
      'end_timestamp': endTimestamp.toIso8601String(),
      'distance': distance,
      'duration': duration,
      'average_speed': averageSpeed,
      'path': path,
    };
  }

  factory EndTrip.fromJson(Map<String, dynamic> json) {
    return EndTrip(
      id: json['id'],
      bikeId: json['bike_id'],
      stationId: json['station_id'],
      startTimestamp: DateTime.parse(json['start_timestamp']),
      endTimestamp: DateTime.parse(json['end_timestamp']),
      distance: json['distance'].toDouble(),
      duration: json['duration'].toDouble(),
      averageSpeed: json['average_speed'].toDouble(),
      path: json['path'],
    );
  }

  String getFormattedStartTimestamp() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(startTimestamp);
  }

  String getFormattedEndTimestamp() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(endTimestamp);
  }
}

class StartTrip {
  final String bikeId;
  final String stationId;
  //final DateTime startTimestamp;

  StartTrip({
    required this.bikeId,
    required this.stationId,
    //required this.startTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'bike_id': bikeId,
      'station_id': stationId,
      //'start_timestamp': startTimestamp.toIso8601String(),
    };
  }

  factory StartTrip.fromJson(Map<String, dynamic> json) {
    return StartTrip(
      bikeId: json['bike_id'],
      stationId: json['station_id'],
      // startTimestamp: DateTime.parse(json['start_timestamp']),
    );
  }

  // String getFormattedStartTimestamp() {
  //   final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  //   return formatter.format(startTimestamp);
  // }
}

class EndTripModel {
  final bool success;
  final EndTripData? data;
  final String message;

  EndTripModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory EndTripModel.fromJson(Map<String, dynamic> json) {
    return EndTripModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? EndTripData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}

class EndTripData {
  final String id;
  final String userId;
  final String bikeId;
  final String stationId;
  final String startTimestamp;
  final String endTimestamp;
  final double distance;
  final double duration;
  final double averageSpeed;
  final List<dynamic> path;
  final double maxElevation;
  final double kcal;

  EndTripData({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.stationId,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.distance,
    required this.duration,
    required this.averageSpeed,
    required this.path,
    required this.maxElevation,
    required this.kcal,
  });

  factory EndTripData.fromJson(Map<String, dynamic> json) {
    return EndTripData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      bikeId: json['bike_id'] ?? '',
      stationId: json['station_id'] ?? '0',
      startTimestamp: json['start_timestamp'] ?? '',
      endTimestamp: json['end_timestamp'] ?? '',
      distance: json['distance']?.toDouble() ?? 0.0,
      duration: json['duration']?.toDouble() ?? 0.0,
      averageSpeed: json['average_speed']?.toDouble() ?? 0.0,
      path: json['path'] ?? [],
      maxElevation: json['max_elevation']?.toDouble() ?? 0.0,
      kcal: json['kcal']?.toDouble() ?? 0.0,
    );
  }
}
