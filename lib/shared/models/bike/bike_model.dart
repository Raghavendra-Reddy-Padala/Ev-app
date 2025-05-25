class Bike {
  String id;
  String frameNumber;
  String name;
  String stationId;
  int topSpeed;
  int range;
  int timeToStation;
  String bikeType;
  List<String>? images;

  Bike({
    required this.id,
    required this.frameNumber,
    required this.name,
    required this.stationId,
    required this.topSpeed,
    required this.range,
    required this.timeToStation,
    required this.bikeType,
    this.images,
  });

  factory Bike.fromJson(Map<String, dynamic> map) {
    return Bike(
      id: map['id'] ?? '',
      frameNumber: map['frame_number'] ?? '',
      name: map['name'] ?? '',
      stationId: map['station_id'] ?? '',
      topSpeed: map['top_speed'] ?? 0,
      range: map['range'] ?? 0,
      timeToStation: map['time_to_station'] ?? 0,
      bikeType: map['bike_type'] ?? '',
      images: map['images'] != null ? List<String>.from(map['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frame_number': frameNumber,
      'name': name,
      'station_id': stationId,
      'top_speed': topSpeed,
      'range': range,
      'time_to_station': timeToStation,
      'bike_type': bikeType,
      'images': images,
    };
  }
}

// Single bike response model for your current API
class BikeResponseModel {
  bool success;
  Bike data;
  String message;
  dynamic error;

  BikeResponseModel({
    required this.success,
    required this.data,
    required this.message,
    this.error,
  });

  factory BikeResponseModel.fromMap(Map<String, dynamic> map) {
    return BikeResponseModel(
      success: map['success'] ?? false,
      data: Bike.fromJson(map['data']),
      message: map['message'] ?? '',
      error: map['error'],
    );
  }
}

// Multiple bikes response model (for future use)
class BikesResponseModel {
  bool success;
  List<Bike> data;
  String message;
  dynamic error;

  BikesResponseModel({
    required this.success,
    required this.data,
    required this.message,
    this.error,
  });

  factory BikesResponseModel.fromMap(Map<String, dynamic> map) {
    return BikesResponseModel(
      success: map['success'] ?? false,
      data: List<Bike>.from(map['data']?.map((x) => Bike.fromJson(x)) ?? []),
      message: map['message'] ?? '',
      error: map['error'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
      'message': message,
      'error': error,
    };
  }
}