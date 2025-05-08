class Bike {
  String id;
  String frameNumber;
  String name;
  String stationId;
  int topSpeed;
  int range;
  int timeToStation;

  Bike({
    required this.id,
    required this.frameNumber,
    required this.name,
    required this.stationId,
    required this.topSpeed,
    required this.range,
    required this.timeToStation,
  });

  factory Bike.fromMap(Map<String, dynamic> map) {
    return Bike(
      id: map['id'],
      frameNumber: map['frame_number'],
      name: map['name'],
      stationId: map['station_id'],
      topSpeed: map['top_speed'],
      range: map['range'],
      timeToStation: map['time_to_station'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frame_number': frameNumber,
      'name': name,
      'station_id': stationId,
      'top_speed': topSpeed,
      'range': range,
      'time_to_station': timeToStation,
    };
  }
}

class BikesResponseModel {
  bool success;
  List<Bike> data;
  String message;

  BikesResponseModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory BikesResponseModel.fromMap(Map<String, dynamic> map) {
    return BikesResponseModel(
      success: map['success'],
      data: List<Bike>.from(map['data']?.map((x) => Bike.fromMap(x))),
      message: map['message'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': List<dynamic>.from(data.map((x) => x.toMap())),
      'message': message,
    };
  }
}
