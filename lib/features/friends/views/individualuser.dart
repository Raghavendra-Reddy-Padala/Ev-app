import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/features/account/controllers/profile_controller.dart';
import 'package:mjollnir/features/friends/controller/follow_controller.dart';
import 'package:mjollnir/features/friends/views/individualuserfollowerscontrolller.dart';
import 'package:mjollnir/shared/components/activity/activity_graph.dart';
import 'package:mjollnir/shared/components/activity/activity_widget.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/components/profile/user_progress_card.dart';
import 'package:mjollnir/shared/constants/colors.dart' show AppColors;
import 'package:mjollnir/shared/models/user/user_model.dart';

class IndividualUserPage extends StatelessWidget {
  final String name;
  final String distance;
  final int trips;
  final int followers;
  final int points;
  final String avatharurl;
  final String uid;
  
  const IndividualUserPage({
    super.key,
    required this.name,
    required this.trips,
    required this.followers,
    required this.distance,
    required this.avatharurl,
    required this.uid,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    
    // Initialize controllers
    Get.put(FollowController());
    Get.put(IndividualUserFollowersController()); // Initialize the new controller
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Header(heading: name),
              _UI(
                uid: uid,
                trips: trips,
                followers: followers,
                avatharurl: avatharurl,
                name: name,
                distance: "$distance km" ,
                points: points,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UI extends StatelessWidget {
  final String distance;
  final String name;
  final int points;
  final String avatharurl;
  final int trips;
  final int followers;
  final String uid;
  
  const _UI({
    required this.name,
    required this.distance,
    required this.points,
    required this.avatharurl,
    required this.trips,
    required this.followers,
    required this.uid,
  });

  // Generate static trips data with Hyderabad locations
  List<Trip> _generateStaticTrips() {
    return [
      Trip(
        id: '1',
        userId: uid,
        bikeId: 'bike123',
        stationId: 'station1',
        startTimestamp: DateTime.now().subtract(const Duration(days: 2)),
        endTimestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        distance: 8.5,
        duration: 45.2,
        averageSpeed: 11.3,
        maxElevation: 520,
        kcal: 320,
        path: _generateHyderabadPathPoints(17.3850, 78.4867, 0.02), // Starting near Charminar
      ),
      Trip(
        id: '2',
        userId: uid,
        bikeId: 'bike456',
        stationId: 'station2',
        startTimestamp: DateTime.now().subtract(const Duration(days: 5)),
        endTimestamp: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
        distance: 15.2,
        duration: 90.5,
        averageSpeed: 10.1,
        maxElevation: 540,
        kcal: 580,
        path: _generateHyderabadPathPoints(17.4065, 78.4772, 0.03), // Starting near Gachibowli
      ),
      Trip(
        id: '3',
        userId: uid,
        bikeId: 'bike789',
        stationId: 'station3',
        startTimestamp: DateTime.now().subtract(const Duration(days: 7)),
        endTimestamp: DateTime.now().subtract(const Duration(days: 7, hours: 1, minutes: 30)),
        distance: 12.7,
        duration: 75.8,
        averageSpeed: 10.8,
        maxElevation: 510,
        kcal: 450,
        path: _generateHyderabadPathPoints(17.4239, 78.4738, 0.025), // Starting near HITEC City
      ),
    ];
  }

  // Generate random path points around a central Hyderabad location
  List<PathPoint> _generateHyderabadPathPoints(double startLat, double startLng, double range) {
    final random = Random();
    final points = <PathPoint>[];
    
    // Generate 10-20 random points around the starting location
    final pointCount = 3 + random.nextInt(1);
    
    for (int i = 0; i < pointCount; i++) {
      // Add small random variations to the coordinates
      final lat = startLat + (random.nextDouble() * range * 2 - range);
      final lng = startLng + (random.nextDouble() * range * 2 - range);
      
      points.add(PathPoint(
        lat: lat,
        long: lng,
        timestamp: DateTime.now().subtract(Duration(minutes: i * 5)),
        elevation: 500 + random.nextDouble(), // Hyderabad elevation ~500m
      ));
    }
    
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = (points / 100).floor() + 1;
    final nextLevelPoints = currentLevel * 100;
    final staticTrips = _generateStaticTrips();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          _buildCompactProfileHeader(),
          SizedBox(height: 16.h),
          UserProgressCard(
            nextLevelPoints: nextLevelPoints,
            currentPoints: currentLevel,
            level: points,
          ),
          SizedBox(height: 16.h),
          Center(
            child: Obx(() {
              final summary = ProfileController().tripSummary.value;
              return ActivityGraphWidget(
                tripSummary: summary,
                onDateRangeChanged: (dateRange) {},
              );
            }),
          ),
          SizedBox(height: 32.h),
          
          // Recent Trips Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent Trips',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          
          // List of recent trips
          Column(
            children: [
              for (final trip in staticTrips)
                Column(
                  children: [
                    ActivityWidget(
                          pathPoints: _convertToLatLng(trip.path),
                      trip: trip,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

   List<LatLng> _convertToLatLng(List<PathPoint> pathPoints) {
    return pathPoints.map((point) => LatLng(point.lat, point.long)).toList();
  }

  Widget _buildCompactProfileHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              _buildBannerContainer(),
              _buildInfoContainer(),
            ],
          ),
          _buildOverlapProfilePicture(),
        ],
      ),
    );
  }

  Widget _buildBannerContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade300,
              Colors.green.shade500,
            ]
          ),
          image: const DecorationImage(
            image: NetworkImage(
              'https://res.cloudinary.com/djyny0qqn/image/upload/v1749388344/ChatGPT_Image_Jun_8_2025_05_27_53_PM_nu0zjs.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget _buildOverlapProfilePicture() {
    return Positioned(
      top: 70.h,
      left: 24.w,
      child: GestureDetector(
        onTap: () => _showFullProfileImage(),
        child: Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 48.w,
            backgroundImage: avatharurl.isNotEmpty
                ? NetworkImage(avatharurl)
                : NetworkImage("https://res.cloudinary.com/djyny0qqn/image/upload/v1749474006/475525-3840x2160-desktop-4k-mjolnir-thor-wallpaper_bl9rvh.jpg"),
            backgroundColor: Colors.grey[300],
            child: avatharurl.isEmpty
                ? Icon(
                    Icons.person_outline,
                    size: 40.w,
                    color: Colors.grey[600],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void _showFullProfileImage() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20.w),
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: Get.width * 0.9,
                  maxHeight: Get.height * 0.7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: avatharurl.isNotEmpty
                      ? Image.network(
                          avatharurl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 300.w,
                            height: 300.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              size: 100.w,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : Container(
                          width: 300.w,
                          height: 300.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: 100.w,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ),
            ),
            
            Positioned(
              top: 20.h,
              right: 20.w,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24.w,
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black87,
    );
  }

Widget _buildInfoContainer() {
  final followController = Get.find<FollowController>();
  final followersController = Get.find<IndividualUserFollowersController>(); // Get the new controller
  
  return Container(
    decoration: BoxDecoration(
      color: AppColors.accent1,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(16.r),
        bottomRight: Radius.circular(16.r),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        SizedBox(height: 55.h),
        
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Name section
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              // Spacer between name and button
              SizedBox(width: 16.w),
              
              // Follow button - custom container button
              Obx(() {
                final isFollowed = followController.followedUsers[uid] ?? false;
                final isLoading = followController.isUserLoading(uid);
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: isLoading ? null : () async {
                      if (!isFollowed) {
                        await followController.followUser(uid);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isFollowed ? AppColors.accent1 : AppColors.primary,
                        border: isFollowed ? Border.all(color: AppColors.primary, width: 1.5) : null,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: isFollowed ? null : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isFollowed ? AppColors.primary : Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isFollowed ? Icons.check : Icons.person,
                                  size: 14.w,
                                  color: isFollowed ? AppColors.primary : Colors.white,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  isFollowed ? 'Following' : 'Follow',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isFollowed ? AppColors.primary : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        
        SizedBox(height: 16.h),
        
        Container(
          height: 1.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
        ),
        
        Container(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMinimalStat(
                icon: Icons.route_outlined,
                value: distance.toString(),
                label: 'Distance',
                color: Colors.blue[600]!,
              ),
              _buildVerticalDivider(),
              _buildMinimalStat(
                icon: Icons.map_outlined,
                value: trips.toString(),
                label: 'Trips',
                color: Colors.green[600]!,
              ),
              _buildVerticalDivider(),
              _buildMinimalStat(
                icon: Icons.people_outline,
                value: followers.toString(),
                label: 'Followers',
                color: Colors.orange[600]!,
                onTap: () {         followersController.showUserFollowersList(uid: uid, userName:name);
},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  Widget _buildMinimalStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final statWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 20.w,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.transparent,
          ),
          child: statWidget,
        ),
      );
    }
    
    return statWidget;
  }
  

  Widget _buildVerticalDivider() {
    return Container(
      height: 40.h,
      width: 1.w,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
    );
  }
}