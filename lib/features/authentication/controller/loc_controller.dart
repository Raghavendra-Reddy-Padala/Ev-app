import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/shared/models/stations/station.dart';

class LocationController extends GetxController {
  Rx<LatLng> initialLocation = const LatLng(17.4065, 78.4772).obs;
  Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  RxBool isLocationReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(locations, (_) => _updateMarkers());
    fetchUserLocation();
  }

  RxList<LatLng> locations = <LatLng>[].obs;
  RxSet<Marker> markers = <Marker>{}.obs;
  Future<void> _updateMarkers() async {
    if (mapController.value == null) return;

    final BitmapDescriptor customIcon = await _getCustomMarker();

    Set<Marker> newMarkers = locations
        .map((latLng) => Marker(
              markerId: MarkerId(latLng.toString()),
              position: latLng,
              icon: customIcon,
            ))
        .toSet();

    markers.assignAll(newMarkers);
  }

  Future<void> markLocations(List<LatLng> locations) async {
    final GoogleMapController? controller = mapController.value;
    if (controller == null) return;

    final BitmapDescriptor customIcon = await _getCustomMarker();

    Set<Marker> newMarkers = locations
        .map((latLng) => Marker(
              markerId: MarkerId(latLng.toString()),
              position: latLng,
              icon: customIcon,
            ))
        .toSet();

    markers.addAll(newMarkers);
    update();
  }

  Future<BitmapDescriptor> _getCustomMarker() async {
    final ByteData data = await rootBundle.load('assets/images/location.png');
    final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 50,
        targetHeight: 50);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(uint8List);
  }

  void goToCustomLocation(LatLng newLocation) {
    mapController.value?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newLocation,
          zoom: 7.0,
        ),
      ),
    );
  }

  Future<void> goToUserLocation() async {
    Location location = Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception("Location services are disabled.");
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception("Location permissions are denied.");
        }
      }

      LocationData locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        final newLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
        mapController.value?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newLocation,
              zoom: 7.0,
            ),
          ),
        );
      } else {
        throw Exception("Unable to fetch location coordinates.");
      }
    } catch (e) {
      AppLogger.e("Error fetching user location: $e");
      throw Exception("Error fetching user location: $e");
    }
  }

  Future<void> fetchUserLocation() async {
    Location location = Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      LocationData locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        initialLocation.value =
            LatLng(locationData.latitude!, locationData.longitude!);
        isLocationReady.value = true;
      }
    } catch (e) {
      AppLogger.e("Error fetching location: $e");
    }
  }

  @override
  void onClose() {
    mapController.value?.dispose();
    super.onClose();
  }
}

// class MapsView extends StatefulWidget {
//   const MapsView({super.key});

//   @override
//   State<MapsView> createState() => _MapsViewState();
// }

// class _MapsViewState extends State<MapsView> {
//   final LocationController locationController = Get.find();
//   final GetNearbyStationsController _nearbyStationsController =
//       Get.find<GetNearbyStationsController>();
//   final Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeMap();
//   }

//   void _initializeMap() async {
//     await locationController.fetchUserLocation();
//     await _fetchStations();

//     ever(_nearbyStationsController.nearbyStations, (stations) {
//       if (mounted) {
//         setState(() {
//           _updateMarkers(stations);
//         });
//       }
//     });
//   }

//   Future<void> _fetchStations() async {
//     await _nearbyStationsController.fetchNearbyStations(
//       locationController.initialLocation.value.latitude,
//       locationController.initialLocation.value.longitude,
//     );
//   }

//   void _updateMarkers(List<Station> stations) {
//     if (!mounted) return;

//     setState(() {
//       _markers.clear();
//       _markers.addAll(
//         stations.map((station) => Marker(
//               markerId: MarkerId(station.id),
//               position: LatLng(
//                 double.parse(station.locationLatitude),
//                 double.parse(station.locationLongitude),
//               ),
//               infoWindow: InfoWindow(
//                 title: station.name,
//                 snippet:
//                     'Capacity: ${station.currentCapacity}/${station.capacity}',
//               ),
//             )),
//       );
//     });
//   }

//   // String _getMapStyle(BuildContext context) {
//   //   return Theme.of(context).brightness == Brightness.dark
//   //       ? MapStyles.customDark
//   //       : MapStyles.customLight;
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (!locationController.isLocationReady.value) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _updateMarkers(_nearbyStationsController.nearbyStations);
//       });
//       return Stack(children: [
//         GoogleMap(
//           initialCameraPosition: CameraPosition(
//             target: locationController.initialLocation.value,
//             zoom: 7,
//           ),
//           myLocationEnabled: true,
//           myLocationButtonEnabled: false,
//           zoomControlsEnabled: false,
//           markers: locationController.markers.toSet(),
//           onMapCreated: (GoogleMapController controller) {
//             locationController.mapController.value = controller;
//             controller.setMapStyle(_getMapStyle(context));
//             _nearbyStationsController.nearbyStations.listen((stations) {
//               locationController.markLocations(
//                 stations
//                     .map((station) => LatLng(
//                           double.parse(station.locationLatitude),
//                           double.parse(station.locationLongitude),
//                         ))
//                     .toList(),
//               );
//             });
//           },
//         ),
//       ]);
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
