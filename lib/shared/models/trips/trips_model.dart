import 'package:intl/intl.dart';

class TripSummaryModel {
  final Averages averages;
  final double carbonFootprintKg;
  final double highestSpeed;
  final LongestRide longestRide;
  final double maxElevationM;
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
      maxElevationM: json['max_elevation_m']?.toDouble() ?? 0.0,
      totalCalories: json['total_calories'] ?? 0,
      totalTimeHours: json['total_time_hours']?.toDouble() ?? 0.0,
      totalTrips: json['total_trips'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averages': averages.toJson(),
      'carbon_footprint_kg': carbonFootprintKg,
      'highest_speed': highestSpeed,
      'longest_ride': longestRide.toJson(),
      'max_elevation_m': maxElevationM,
      'total_calories': totalCalories,
      'total_time_hours': totalTimeHours,
      'total_trips': totalTrips,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'calories_trip': caloriesTrip,
      'distance_km': distanceKm,
      'speed_kmh': speedKmh,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'distance_km': distanceKm,
      'duration_hours': durationHours,
    };
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
  final double? fare;

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
    this.fare,
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
      if (fare != null) 'fare': fare,
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
      fare: json['fare']?.toDouble(),
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
  final bool personal;

  StartTrip({
    required this.bikeId,
    required this.stationId,
    required this.personal,
  });

  Map<String, dynamic> toJson() {
    return {
      'bike_id': bikeId,
      'station_id': stationId,
      'personal': personal,
    };
  }

  factory StartTrip.fromJson(Map<String, dynamic> json) {
    return StartTrip(
      bikeId: json['bike_id'],
      stationId: json['station_id'],
      personal: json['personal'] ?? false,
    );
  }
}

// ✅ FIXED: EndTripModel now uses EndTripResponseData
class EndTripModel {
  final bool success;
  final EndTripResponseData? data;  // Changed from EndTripData to EndTripResponseData
  final String message;

  EndTripModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory EndTripModel.fromJson(Map<String, dynamic> json) {
    return EndTripModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? EndTripResponseData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}

// ✅ This wraps both rideSummary and trip
class EndTripResponseData {
  final RideSummaryData? rideSummary;
  final EndTripData? trip;

  EndTripResponseData({
    this.rideSummary,
    this.trip,
  });

  factory EndTripResponseData.fromJson(Map<String, dynamic> json) {
    return EndTripResponseData(
      rideSummary: json['ride_summary'] != null 
          ? RideSummaryData.fromJson(json['ride_summary']) 
          : null,
      trip: json['trip'] != null 
          ? EndTripData.fromJson(json['trip']) 
          : null,
    );
  }
}

// ✅ Contains fare and all ride summary details
class RideSummaryData {
  final String tripId;
  final double duration;
  final double distance;
  final double averageSpeed;
  final double caloriesBurned;
  final double maxElevation;
  final String startTime;
  final String endTime;
  final double carbonOffset;
  final LocationData? startLocation;
  final LocationData? endLocation;
  final BikeDetails? bikeDetails;
  final double fare;

  RideSummaryData({
    required this.tripId,
    required this.duration,
    required this.distance,
    required this.averageSpeed,
    required this.caloriesBurned,
    required this.maxElevation,
    required this.startTime,
    required this.endTime,
    required this.carbonOffset,
    this.startLocation,
    this.endLocation,
    this.bikeDetails,
    required this.fare,
  });

  factory RideSummaryData.fromJson(Map<String, dynamic> json) {
    return RideSummaryData(
      tripId: json['trip_id'] ?? '',
      duration: (json['duration'] ?? 0).toDouble(),
      distance: (json['distance'] ?? 0).toDouble(),
      averageSpeed: (json['average_speed'] ?? 0).toDouble(),
      caloriesBurned: (json['calories_burned'] ?? 0).toDouble(),
      maxElevation: (json['max_elevation'] ?? 0).toDouble(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      carbonOffset: (json['carbon_offset'] ?? 0).toDouble(),
      startLocation: json['start_location'] != null 
          ? LocationData.fromJson(json['start_location']) 
          : null,
      endLocation: json['end_location'] != null 
          ? LocationData.fromJson(json['end_location']) 
          : null,
      bikeDetails: json['bike_details'] != null 
          ? BikeDetails.fromJson(json['bike_details']) 
          : null,
      fare: (json['fare'] ?? 0).toDouble(),
    );
  }
}

class LocationData {
  final String stationName;
  final String latitude;
  final String longitude;

  LocationData({
    required this.stationName,
    required this.latitude,
    required this.longitude,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      stationName: json['station_name'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
    );
  }
}

class BikeDetails {
  final String bikeId;
  final String bikeName;
  final String frameNumber;

  BikeDetails({
    required this.bikeId,
    required this.bikeName,
    required this.frameNumber,
  });

  factory BikeDetails.fromJson(Map<String, dynamic> json) {
    return BikeDetails(
      bikeId: json['bike_id'] ?? '',
      bikeName: json['bike_name'] ?? '',
      frameNumber: json['frame_number'] ?? '',
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