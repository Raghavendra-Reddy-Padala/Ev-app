import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/profile_controller.dart';
import 'package:mjollnir/shared/components/activity/activity_graph.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/components/profile/user_progress_card.dart';
import 'package:mjollnir/shared/constants/colors.dart' show AppColors;

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
                distance: distance,
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

  @override
  Widget build(BuildContext context) {
    final currentLevel = (points / 100).floor() + 1;
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
        ],
      ),
    );
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
                : null,
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
            padding: const EdgeInsets.fromLTRB(0, 0, 200, 0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
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
                  value: distance,
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
  }) {
    return Column(
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