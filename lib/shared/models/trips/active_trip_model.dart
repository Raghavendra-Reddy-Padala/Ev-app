class ActiveTripResponse {
  final String id;
  final double caloriesTrip;
  final double distanceKm;
  final double speedKmh;
  final double carbonFootprintKg;
  final double highestSpeed;
  final LongestRide longestRide;
  final double maxElevationM;
  final double totalCalories;
  final double totalTimeHours;
  final int totalTrips;

  ActiveTripResponse({
    required this.id,
    required this.caloriesTrip,
    required this.distanceKm,
    required this.speedKmh,
    required this.carbonFootprintKg,
    required this.highestSpeed,
    required this.longestRide,
    required this.maxElevationM,
    required this.totalCalories,
    required this.totalTimeHours,
    required this.totalTrips,
  });

  factory ActiveTripResponse.fromJson(Map<String, dynamic> json) {
    return ActiveTripResponse(
      id: json['id']?.toString() ?? '',
      caloriesTrip: (json['calories_trip'] ?? 0).toDouble(),
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      speedKmh: (json['speed_kmh'] ?? 0).toDouble(),
      carbonFootprintKg: (json['carbon_footprint_kg'] ?? 0).toDouble(),
      highestSpeed: (json['highest_speed'] ?? 0).toDouble(),
      longestRide: LongestRide.fromJson(json['longest_ride'] ?? {}),
      maxElevationM: (json['max_elevation_m'] ?? 0).toDouble(),
      totalCalories: (json['total_calories'] ?? 0).toDouble(),
      totalTimeHours: (json['total_time_hours'] ?? 0).toDouble(),
      totalTrips: (json['total_trips'] ?? 0).toInt(),
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
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      durationHours: (json['duration_hours'] ?? 0).toDouble(),
    );
  }
}
