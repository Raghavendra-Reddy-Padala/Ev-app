import 'package:intl/intl.dart';

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
  final DateTime startTimestamp;

  StartTrip({
    required this.bikeId,
    required this.stationId,
    required this.startTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'bike_id': bikeId,
      'station_id': stationId,
      'start_timestamp': startTimestamp.toIso8601String(),
    };
  }

  factory StartTrip.fromJson(Map<String, dynamic> json) {
    return StartTrip(
      bikeId: json['bike_id'],
      stationId: json['station_id'],
      startTimestamp: DateTime.parse(json['start_timestamp']),
    );
  }

  String getFormattedStartTimestamp() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(startTimestamp);
  }
}
