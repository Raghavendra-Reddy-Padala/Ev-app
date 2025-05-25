import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/authentication/controller/loc_controller.dart';
import 'package:mjollnir/features/home/views/stationsui.dart';
import 'package:mjollnir/features/menubar/faqs.dart';
import 'package:mjollnir/features/menubar/issuespage.dart';
import 'package:mjollnir/features/menubar/subscriptions.dart';
import 'package:mjollnir/shared/components/drawer/custom_drawer.dart';
import 'package:mjollnir/shared/components/search/search_bar.dart';

import '../../menubar/activity.dart';

class HomeMainView extends StatefulWidget {
  const HomeMainView({super.key});

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

  void _handleCreateGroup() {
    showDialog(
      context: context,
      builder: (context) => CreateGroupDialog(
        onSubmit: (name, description, image) {
          // Handle group creation logic here
          Get.snackbar(
            'Success',
            'Group "$name" created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  void _handleInviteFriends() {
    // Add your invite friends logic here
    Get.snackbar(
      'Feature',
      'Invite friends feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  List<DrawerOption> _getDrawerOptions() {
    return [
      DrawerOption(
        title: 'Subscriptions',
        icon: Icons.subscriptions,
        onTap: () {
          Navigator.pop(context);
          Get.to(() => const Subscriptions());
        },
      ),
      DrawerOption(
        title: 'Issues',
        icon: Icons.report_problem,
        onTap: () {
          Navigator.pop(context);
          Get.to(() => const Issues());
        },
      ),
      DrawerOption(
        title: 'FAQ',
        icon: Icons.help_outline,
        onTap: () {
          Navigator.pop(context);
          Get.to(() => FAQ());
        },
      ),
      DrawerOption(
        title: 'Activity',
        icon: Icons.timeline,
        onTap: () {
          Navigator.pop(context);
          Get.to(() => const ActivityMainView());
          // Temporary placeholder
          // Get.snackbar('Info', 'Activity page coming soon!');
        },
      ),
      DrawerOption(
        title: 'My Trips',
        icon: Icons.trip_origin,
        onTap: () {
          Navigator.pop(context);
          // Get.to(() => const MyTrips());
          // Temporary placeholder
          Get.snackbar('Info', 'My Trips page coming soon!');
        },
      ),
      DrawerOption(
        title: 'Groups',
        icon: Icons.group,
        onTap: () {
          Navigator.pop(context);
          // Get.to(() => const GroupView());
          // Temporary placeholder
          Get.snackbar('Info', 'Groups page coming soon!');
        },
      ),
      DrawerOption(
        title: 'Settings',
        icon: Icons.settings,
        onTap: () {
          Navigator.pop(context);
          Get.snackbar('Info', 'Settings page coming soon!');
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.find();
    locationController.fetchUserLocation();
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        options: _getDrawerOptions(),
        onCreateGroup: _handleCreateGroup,
        onInviteFriends: _handleInviteFriends,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const MapsView(),
            Positioned(
              top: 16.0,
              left: 35.0,
              right: 16.0,
              child: CustomSearchBar(
                controller: TextEditingController(),
                hintText: 'Search for stations',
                onChanged: (value) {},
              ),
            ),
            Positioned(
              top: 20.0,
              left: 5.0,
              child: IconButton(
                icon: Icon(Icons.menu, size: 30.w),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            const StationsList(),
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
