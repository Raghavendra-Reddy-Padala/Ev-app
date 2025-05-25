class SubscriptionIds {
  final List<String> subscriptionId;
  final List<String> b2bId;

  SubscriptionIds({
    required this.subscriptionId,
    required this.b2bId,
  });

  factory SubscriptionIds.fromJson(Map<String, dynamic> json) {
    return SubscriptionIds(
      subscriptionId: List<String>.from(json['subscription_id'] ?? []), // Fixed typo here
      b2bId: List<String>.from(json['b2b_id'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subscription_id': subscriptionId,
      'b2b_id': b2bId,
    };
  }
}

class Station {
  final String tableName;
  final String id;
  final String name;
  final String locationLatitude;
  final String locationLongitude;
  final int capacity;
  final int currentCapacity;
  final SubscriptionIds subscriptionIds;
  final double? distance; // Optional since it might not be in the response

  Station({
    required this.tableName,
    required this.id,
    required this.name,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.capacity,
    required this.currentCapacity,
    required this.subscriptionIds,
    this.distance,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      tableName: json['TableName'] ?? '',
      id: json['id'],
      name: json['name'],
      locationLatitude: json['location_latitude'],
      locationLongitude: json['location_longitude'],
      capacity: json['capacity'],
      currentCapacity: json['current_capacity'],
      subscriptionIds: SubscriptionIds.fromJson(json['subscription_ids']),
      distance: json['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'TableName': tableName,
      'id': id,
      'name': name,
      'location_latitude': locationLatitude,
      'location_longitude': locationLongitude,
      'capacity': capacity,
      'current_capacity': currentCapacity,
      'subscription_ids': subscriptionIds.toMap(),
      if (distance != null) 'distance': distance,
    };
  }
}

class GetStationResponse {
  final bool success;
  final Station station;
  final String message;
  final String? error;

  GetStationResponse({
    required this.success,
    required this.station,
    required this.message,
    this.error,
  });

  factory GetStationResponse.fromJson(Map<String, dynamic> json) {
    return GetStationResponse(
      success: json['success'],
      station: Station.fromJson(json['data']),
      message: json['message'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': station.toMap(),
      'message': message,
      'error': error,
    };
  }
}

// If you still need to handle multiple stations, you can create this class
class GetMultipleStationsResponse {
  final bool success;
  final List<Station> stations;
  final String message;
  final String? error;

  GetMultipleStationsResponse({
    required this.success,
    required this.stations,
    required this.message,
    this.error,
  });

  factory GetMultipleStationsResponse.fromJson(Map<String, dynamic> json) {
    List<Station> stationsList = [];
    
    // Handle both single station and multiple stations
    if (json['data'] is List) {
      stationsList = (json['data'] as List)
          .map((stationJson) => Station.fromJson(stationJson))
          .toList();
    } else if (json['data'] is Map<String, dynamic>) {
      stationsList = [Station.fromJson(json['data'])];
    }

    return GetMultipleStationsResponse(
      success: json['success'],
      stations: stationsList,
      message: json['message'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': stations.map((station) => station.toMap()).toList(),
      'message': message,
      'error': error,
    };
  }
}