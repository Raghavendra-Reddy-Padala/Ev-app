import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _preferences?.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }

  Future<void> setDoubleList(String key, List<double> value) async {
    final List<String> stringList = value.map((e) => e.toString()).toList();
    await _preferences?.setStringList(key, stringList);
  }

  List<double> getDoubleList(String key) {
    final List<String>? stringList = _preferences?.getStringList(key);
    if (stringList == null || stringList.isEmpty) {
      return [];
    }
    return stringList.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _preferences?.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getObject(String key) {
    final String? jsonString = _preferences?.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveLocationList(List<List<double>> locations) async {
    String jsonString = jsonEncode(locations);
    await _preferences?.setString('locations', jsonString);
  }

  List<List<double>> getLocationList() {
    String? jsonString = _preferences?.getString('locations');
    if (jsonString == null) return [];

    try {
      List<dynamic> jsonResponse = jsonDecode(jsonString);
      return jsonResponse.map((item) {
        if (item is List) {
          return List<double>.from(item.map((e) => e is double ? e : 0.0));
        }
        return <double>[];
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePathPoints(List<List<double>> points) async {
    List<String> encodedPoints = [];
    for (var point in points) {
      if (point.length >= 2) {
        encodedPoints.add('${point[0]},${point[1]}');
      }
    }

    await _preferences?.setStringList('pathPoints', encodedPoints);
  }

  Future<void> setTime(int seconds) async {
    await _preferences?.setInt('total_duration', seconds);
  }

  int getTime() {
    return _preferences?.getInt('total_duration') ?? 0;
  }

  List<List<double>> getPathPoints() {
    try {
      final List<String>? encodedPoints =
          _preferences?.getStringList('pathPoints');
      if (encodedPoints == null || encodedPoints.isEmpty) return [];

      return encodedPoints.map((point) {
        final parts = point.split(',');
        if (parts.length >= 2) {
          return [double.parse(parts[0]), double.parse(parts[1])];
        }
        return [0.0, 0.0];
      }).toList();
    } catch (e) {
      print("Error getting path points: $e");
      return [];
    }
  }

  Future<void> setToken(String token) async {
    await _preferences?.setString('token', token);
  }

  String? getToken() {
    return _preferences?.getString('token');
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _preferences?.setBool('is_logged_in', isLoggedIn);
  }

  bool isLoggedIn() {
    return _preferences?.getBool('is_logged_in') ?? false;
  }

  Future<void> setBikeSubscribed(bool isSubscribed) async {
    await _preferences?.setBool('bike_subscribed', isSubscribed);
  }

  bool isBikeSubscribed() {
    return _preferences?.getBool('bike_subscribed') ?? false;
  }

  Future<void> setBikeCode(String bikeCode) async {
    await _preferences?.setString('bike_code', bikeCode);
  }

  String? getBikeCode() {
    return _preferences?.getString('bike_code');
  }

  Future<void> setEncodedID(String encodedID) async {
    await _preferences?.setString('encoded_id', encodedID);
  }

  String? getEncodedID() {
    return _preferences?.getString('encoded_id');
  }

  Future<void> setDeviceID(String deviceID) async {
    await _preferences?.setString('device_id', deviceID);
  }

  String? getDeviceID() {
    return _preferences?.getString('device_id');
  }

  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  Future<void> clearAll() async {
    await _preferences?.clear();
  }
}
