import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';
import '../../../shared/models/stations/station.dart';
import '../../../shared/services/dummy_data_service.dart';

class StationController extends BaseController {
  final RxList<Station> stations = <Station>[].obs;
  final RxList<Station> filteredStations = <Station>[].obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final Rxn<LatLng> userLocation = Rxn<LatLng>();
  var nearbyStations = <Station>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    fetchUserLocation();
    fetchAllStations();
  }

  Future<void> fetchUserLocation() async {
    try {
      final loc.Location location = loc.Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          errorMessage.value = "Location services are disabled";
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          errorMessage.value = "Location permissions are denied";
          return;
        }
      }

      final locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        userLocation.value =
            LatLng(locationData.latitude!, locationData.longitude!);
      }
    } catch (e) {
      handleError(e);
    }
  }
Future<void> fetchAllStations() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    await useApiOrDummy(
      apiCall: () async {
        final String? authToken = localStorage.getToken();
        if (authToken == null) {
          throw Exception('Authentication token not found');
        }
        
        final response = await apiService.get(
          endpoint: 'stations/',
          headers: {
            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb2xsZWdlIjoiSk5UVUgiLCJlbWFpbCI6ImNoaW50dUBnbWFpbC5jb20iLCJlbXBsb3llZV9pZCI6IiIsImdlbmRlciI6Ik1hbGUiLCJuYW1lIjoicGFkYWxhIiwicGhvbmUiOiIrOTE5MzQ2OTEzMTQ0IiwidWlkIjoiM3pmdjF5Y2hmbyJ9.wAq_Sul2320GyqTolwABj-ooqGWIF1wTY-F4oARS4q0',
            'Content-Type': 'application/json',
            'X-Karma-App': 'dafjcnalnsjn',
          },
        );

        if (response != null) {
          print('Raw Response data: ${response}');
          
          // Debug: Check the structure of response
          print('Response type: ${response.runtimeType}');
          print('Response keys: ${response.keys}');
          
          try {
            final stationResponse = GetMultipleStationsResponse.fromJson(response);
            print('Parsed stations count: ${stationResponse.stations.length}');
            
            if (stationResponse.success) {
              stations.clear();
              stations.addAll(stationResponse.stations);
              filteredStations.assignAll(stations);
              nearbyStations.assignAll(stations);
              
              print('Stations added to controller: ${stations.length}');
              print('First station: ${stations.isNotEmpty ? stations.first.name : 'No stations'}');
              
              _updateMarkers();
              return true;
            } else {
              errorMessage.value = stationResponse.message;
              print('API returned success: false, message: ${stationResponse.message}');
              return false;
            }
          } catch (parseError) {
            print('Error parsing response: $parseError');
            print('Response structure: $response');
            throw parseError;
          }
        }
        print('Response is null');
        return false;
      },
      dummyData: () {
        print('Using dummy data');
        final dummyData = DummyDataService.getStationsResponse();
        print('Dummy data: $dummyData');
        
        final stationResponse = GetMultipleStationsResponse.fromJson(dummyData);
        stations.assignAll(stationResponse.stations);
        filteredStations.assignAll(stationResponse.stations);
        nearbyStations.assignAll(stationResponse.stations);
        _updateMarkers();
        return true;
      },
    );
  } catch (e) {
    print('Error in fetchAllStations: $e');
    print('Stack trace: ${StackTrace.current}');
    handleError(e);
  } finally {
    isLoading.value = false;
  }
}
  Future<void> fetchNearbyStations(double lat, double lon) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = localStorage.getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: 'stations/get_nearby?lat=$lat&lon=$lon&limit=6',
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
              'X-Karma-App': 'dafjcnalnsjn',
            },
          );

          if (response != null) {
            print('Nearby stations response: ${response}');

            // Check if response['data'] is a list or single object
            if (response['data'] is List) {
              // Handle array of stations
              final stationsList = (response['data'] as List)
                  .map((stationJson) => Station.fromJson(stationJson))
                  .toList();
              stations.assignAll(stationsList);
              nearbyStations.assignAll(stationsList);
              filteredStations.assignAll(stationsList);
            } else {
              // Handle single station response
              final stationResponse = GetStationResponse.fromJson(response);
              if (stationResponse.success) {
                stations.clear();
                stations.add(stationResponse.station);
                nearbyStations.clear();
                nearbyStations.add(stationResponse.station);
                filteredStations.assignAll(stations);
              }
            }
            _updateMarkers();
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getStationsResponse();
          final stationResponse =
              GetMultipleStationsResponse.fromJson(dummyData);
          stations.assignAll(stationResponse.stations);
          nearbyStations.assignAll(stationResponse.stations);
          filteredStations.assignAll(stationResponse.stations);
          _updateMarkers();
          return true;
        },
      );
    } catch (e) {
      print('Error in fetchNearbyStations: $e');
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _updateMarkers() {
    final newMarkers = stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(
          double.parse(station.locationLatitude),
          double.parse(station.locationLongitude),
        ),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: 'Capacity: ${station.currentCapacity}/${station.capacity}',
        ),
      );
    }).toSet();

    markers.value = newMarkers;
  }

  void filterStations(String query) {
    if (query.isEmpty) {
      filteredStations.assignAll(stations);
    } else {
      filteredStations.assignAll(stations.where((station) =>
          station.name.toLowerCase().contains(query.toLowerCase())));
    }
  }

  Future<void> goToLocation(LatLng target) async {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(target));
    }
  }

  Future<void> goToUserLocation() async {
    try {
      if (userLocation.value != null && mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: userLocation.value!,
              zoom: 15.0,
            ),
          ),
        );
      } else {
        await fetchUserLocation();
        if (userLocation.value != null && mapController != null) {
          await mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: userLocation.value!,
                zoom: 15.0,
              ),
            ),
          );
        }
      }
    } catch (e) {
      handleError(e);
    }
  }
}
