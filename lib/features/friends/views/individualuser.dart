
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/features/account/controllers/profile_controller.dart';
import 'package:mjollnir/features/friends/controller/follow_controller.dart';
import 'package:mjollnir/features/friends/controller/individualusertripscontroller.dart';
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
    Get.put(FollowController());
    Get.put(IndividualUserFollowersController()); 
    Get.put(IndividualUserTripsController());
    
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
                distance: "$distance km",
                points: points,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UI extends StatefulWidget {
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

  @override
  State<_UI> createState() => _UIState();
}

class _UIState extends State<_UI> {
  late IndividualUserTripsController tripsController;

  @override
  void initState() {
    super.initState();
    tripsController = Get.find<IndividualUserTripsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tripsController.fetchUserTrips(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = (widget.points / 100).floor() + 1;
    final nextLevelPoints = currentLevel * 100;

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
            level: widget.points,
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
          _buildTripsSection(),
        ],
      ),
    );
  }

  Widget _buildTripsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Trips',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Obx(() {
              if (tripsController.isLoading.value) {
                return SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }
              return GestureDetector(
                onTap: () => tripsController.refreshTrips(widget.uid),
                child: Icon(
                  Icons.refresh,
                  size: 20.w,
                  color: AppColors.primary,
                ),
              );
            }),
          ],
        ),
        SizedBox(height: 16.h),
        
        // Trips Content
        Obx(() => _buildTripsContent()),
      ],
    );
  }

  Widget _buildTripsContent() {
    if (tripsController.isLoading.value) {
      return _buildLoadingState();
    }
    
    if (tripsController.hasError) {
      return _buildErrorState();
    }
    
    if (!tripsController.hasTrips) {
      return _buildEmptyState();
    }
    
    return _buildTripsList();
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading trips...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48.w,
            color: Colors.red[400],
          ),
          SizedBox(height: 12.h),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            tripsController.errorMessage.value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => tripsController.refreshTrips(widget.uid),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.route_outlined,
              size: 40.w,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No trips yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${widget.name} hasn\'t taken any trips yet.\nCheck back later!',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Start your cycling journey today! 🚴‍♀️',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList() {
    return Column(
      children: [
        for (final trip in tripsController.userTrips)
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
            backgroundImage: widget.avatharurl.isNotEmpty
                ? NetworkImage(widget.avatharurl)
                : NetworkImage("https://res.cloudinary.com/djyny0qqn/image/upload/v1749474006/475525-3840x2160-desktop-4k-mjolnir-thor-wallpaper_bl9rvh.jpg"),
            backgroundColor: Colors.grey[300],
            child: widget.avatharurl.isEmpty
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
                  child: widget.avatharurl.isNotEmpty
                      ? Image.network(
                          widget.avatharurl,
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
                  widget.name,
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
  final followersController = Get.find<IndividualUserFollowersController>();
  
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
                  widget.name,
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
                final isFollowed = followController.followedUsers[widget.uid] ?? false;
                final isLoading = followController.isUserLoading(widget.uid);
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: isLoading ? null : () async {
                      if (!isFollowed) {
                        await followController.followUser(widget.uid);
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
                value: widget.distance.toString(),
                label: 'Distance',
                color: Colors.blue[600]!,
              ),
              _buildVerticalDivider(),
              _buildMinimalStat(
                icon: Icons.map_outlined,
                value: widget.trips.toString(),
                label: 'Trips',
                color: Colors.green[600]!,
              ),
              _buildVerticalDivider(),
              _buildMinimalStat(
                icon: Icons.people_outline,
                value: widget.followers.toString(),
                label: 'Followers',
                color: Colors.orange[600]!,
                onTap: () {
                  followersController.showUserFollowersList(uid: widget.uid, userName: widget.name);
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