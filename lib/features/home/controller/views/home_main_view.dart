import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/authentication/controller/loc_controller.dart';
import 'package:mjollnir/shared/components/drawer/custom_drawer.dart';
import 'package:mjollnir/shared/components/search/search_bar.dart';

class HomeMainView extends StatefulWidget {

   HomeMainView({super.key});

  @override
  State<HomeMainView> createState() => _HomeMainViewState();
}

class _HomeMainViewState extends State<HomeMainView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      Location location = Location();
      LocationData locationData = await location.getLocation();
      var currentLocation =
          LatLng(locationData.latitude ?? 0, locationData.longitude ?? 0);
      final LocationController locationController = Get.find();
      locationController.initialLocation.value = currentLocation;
    } catch (e) {
      AppLogger.i('Error initializing location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.find();
    locationController.fetchUserLocation();
    return Scaffold(
      key: _scaffoldKey,
      drawer:  CustomDrawer(
        options: [
        ],
        onCreateGroup: () {},
        onInviteFriends: () {},

        
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const MapsView(),
             Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: CustomSearchBar(
                controller: TextEditingController(),
                hintText: 'Search for stations',
                onChanged: (value) {
                },
                
              ),
            ),
            Positioned(
              top: 20.0,
              left: 15.0,
              child: IconButton(
                icon: Icon(Icons.menu, size: 30.w),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            // const StationsList(),
            Positioned(
              right: 5,
              bottom: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: locationController.goToUserLocation,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
