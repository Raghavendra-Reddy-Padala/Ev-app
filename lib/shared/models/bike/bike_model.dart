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
    try {
      return Bike(
        id: map['id']?.toString() ?? '',
        frameNumber: map['frame_number']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        stationId: map['station_id']?.toString() ?? '',
        topSpeed: int.tryParse(map['top_speed']?.toString() ?? '0') ?? 0,
        range: int.tryParse(map['range']?.toString() ?? '0') ?? 0,
        timeToStation: int.tryParse(map['time_to_station']?.toString() ?? '0') ?? 0,
        bikeType: map['bike_type']?.toString() ?? '',
        images: map['images'] != null ? List<String>.from(map['images']) : null,
      );
    } catch (e) {
      print('Error parsing Bike from JSON: $e');
      print('JSON data: $map');
      rethrow;
    }
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

// Updated response model to handle both single bike and multiple bikes
class BikeResponseModel {
  bool success;
  List<Bike> data; // Changed from single Bike to List<Bike>
  String message;
  dynamic error;

  BikeResponseModel({
    required this.success,
    required this.data,
    required this.message,
    this.error,
  });

  factory BikeResponseModel.fromMap(Map<String, dynamic> map) {
    try {
      List<Bike> bikesList = [];
      
      // Handle both single bike and multiple bikes
      if (map['data'] is List) {
        // Multiple bikes (your current API response)
        final List<dynamic> bikesData = map['data'];
        print('Found ${bikesData.length} bikes in response');
        
        for (var bikeJson in bikesData) {
          try {
            final bike = Bike.fromJson(bikeJson as Map<String, dynamic>);
            bikesList.add(bike);
            print('Parsed bike: ${bike.name} (${bike.id})');
          } catch (e) {
            print('Error parsing individual bike: $e');
            print('Bike data: $bikeJson');
          }
        }
      } else if (map['data'] is Map<String, dynamic>) {
        // Single bike
        bikesList = [Bike.fromJson(map['data'])];
      }

      return BikeResponseModel(
        success: map['success'] ?? false,
        data: bikesList,
        message: map['message'] ?? '',
        error: map['error'],
      );
    } catch (e) {
      print('Error parsing BikeResponseModel: $e');
      print('Map data: $map');
      rethrow;
    }
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