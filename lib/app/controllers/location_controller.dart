import 'package:get/get.dart';

class LocationController extends GetxController {
  final Rx<LatLng> initialLocation = const LatLng(17.4065, 78.4772).obs;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final RxBool isLocationReady = false.obs;
  final RxList<LatLng> locations = <LatLng>[].obs;
  final RxSet<Marker> markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    ever(locations, (_) => _updateMarkers());
    fetchUserLocation();
  }

  Future<void> _updateMarkers() async {
    if (mapController.value == null) return;

    final BitmapDescriptor customIcon = await _getCustomMarker();
    final Set<Marker> newMarkers = _createMarkers(customIcon);
    markers.assignAll(newMarkers);
  }

  Set<Marker> _createMarkers(BitmapDescriptor icon) {
    return locations
        .map((latLng) => Marker(
              markerId: MarkerId(latLng.toString()),
              position: latLng,
              icon: icon,
            ))
        .toSet();
  }

  Future<void> markLocations(List<LatLng> newLocations) async {
    final GoogleMapController? controller = mapController.value;
    if (controller == null) return;

    final BitmapDescriptor customIcon = await _getCustomMarker();
    final Set<Marker> newMarkers = newLocations
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
    try {
      final LocationData? locationData = await _checkLocationPermissions();
      if (locationData == null) return;

      if (locationData.latitude != null && locationData.longitude != null) {
        final LatLng newLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
        _animateToLocation(newLocation);
      } else {
        throw Exception("Unable to fetch location coordinates.");
      }
    } catch (e) {
      logger.e("An error occurred while fetching location: \$e");
    }
  }

  // Animate camera to specified location
  void _animateToLocation(LatLng location) {
    mapController.value?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 7.0,
        ),
      ),
    );
  }

  // Fetch user's current location
  Future<void> fetchUserLocation() async {
    try {
      final LocationData? locationData = await _checkLocationPermissions();
      if (locationData == null) return;

      if (locationData.latitude != null && locationData.longitude != null) {
        initialLocation.value =
            LatLng(locationData.latitude!, locationData.longitude!);
        isLocationReady.value = true;
      }
    } catch (e) {
      logger.e("Error fetching location: \$e");
    }
  }

  // Check and request location permissions
  Future<LocationData?> _checkLocationPermissions() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return null;
    }

    return await location.getLocation();
  }

  @override
  void onClose() {
    mapController.value?.dispose();
    super.onClose();
  }
}
