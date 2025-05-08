class Station {
  final String id;
  final String name;
  final String locationLatitude;
  final String locationLongitude;
  final int capacity;
  final int currentCapacity;
  final double distance;

  Station({
    required this.id,
    required this.name,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.capacity,
    required this.currentCapacity,
    required this.distance,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      locationLatitude: json['location_latitude'],
      locationLongitude: json['location_longitude'],
      capacity: json['capacity'],
      currentCapacity: json['current_capacity'],
      distance: json['distance'] ?? 5.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location_latitude': locationLatitude,
      'location_longitude': locationLongitude,
      'capacity': capacity,
      'current_capacity': currentCapacity,
      'distance': distance,
    };
  }
}

class GetNearbyStationsResponse1 {
  final String status;
  final List<Station> data;

  GetNearbyStationsResponse1({
    required this.status,
    required this.data,
  });

  factory GetNearbyStationsResponse1.fromJson(Map<String, dynamic> json) {
    return GetNearbyStationsResponse1(
      status: json['status'],
      data: List<Station>.from(
        json['data'].map((station) => Station.fromJson(station)),
      ),
    );
  }
}

class GetNearbyStationsResponse {
  final bool success;
  final List<Station> stations;
  final String message;

  GetNearbyStationsResponse({
    required this.success,
    required this.stations,
    required this.message,
  });

  factory GetNearbyStationsResponse.fromJson(Map<String, dynamic> json) {
    return GetNearbyStationsResponse(
      success: json['success'],
      stations: (json['data'] as List)
          .map((stationJson) => Station.fromJson(stationJson))
          .toList(),
      message: json['message'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': stations.map((station) => station.toMap()).toList(),
      'message': message,
    };
  }
}
