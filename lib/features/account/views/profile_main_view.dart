// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/views/profile_detials.dart';
import 'package:mjollnir/shared/components/profile/user_progress_card.dart';
import 'package:mjollnir/shared/components/profile/invite_friends.dart';
import 'package:mjollnir/shared/components/indicators/loading_indicator.dart';
import 'package:mjollnir/shared/components/states/empty_state.dart';
import 'package:mjollnir/shared/constants/colors.dart' show AppColors;
import '../../../shared/components/activity/activity_graph.dart';
import '../controllers/profile_controller.dart';

class ProfileMainView extends StatelessWidget {
  const ProfileMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (controller) => SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _ProfileContent(controller: controller),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileController controller;

  const _ProfileContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.userData.value == null) {
        return SizedBox(
          height: 0.8.sh,
          child: const LoadingIndicator(
            type: LoadingType.circular,
            message: 'Loading profile...',
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty &&
          controller.userData.value == null) {
        return SizedBox(
          height: 0.8.sh,
          child: EmptyState(
            title: 'Load Your Profile',
            subtitle: "Time to get back on track!",
            icon: Icon(Icons.account_circle_sharp, size: 64.w, color: Colors.red),
            buttonText: 'Profile',
            onButtonPressed: controller.refreshProfile,
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
        _buildCompactProfileHeader()  ,
        SizedBox(height: 16.h),
            _buildUserProgressCard(),
            SizedBox(height: 16.h),
            _buildActivityGraph(),
            SizedBox(height: 16.h),
            _buildInviteFriendsCard(),
            SizedBox(height: 32.h),
          ],
        ),
      );
    });
  }
Widget _buildCompactProfileHeader() {
  return Obx(() {
    final user = controller.userData.value?.data;
    if (user == null) return const SizedBox();

    return Column(
      children: [
        // Banner and Image Container
        _buildBannerContainer(user),
        SizedBox(height: 12.h),
        // Name and Stats Container
        _buildInfoContainer(user),
      ],
    );
  });
}

Widget _buildBannerContainer(user) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 8.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Stack(
      children: [
        Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade300,
                Colors.green.shade500,
              ]
            ),
            image: DecorationImage(
              image: NetworkImage(
                'https://res.cloudinary.com/djyny0qqn/image/upload/v1749388344/ChatGPT_Image_Jun_8_2025_05_27_53_PM_nu0zjs.png',

              ),
              fit: BoxFit.fill,
            ),
          ),
        ),
        
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () => Get.to(() => Profiledetails()),
              child: Container(),
            ),
          ),
        ),
        
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Container(
            decoration: BoxDecoration(
              
              
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Container(
              height: 32.h,
              width: 32.w,
              child: IconButton(
              
                onPressed: () => Get.to(() => Profiledetails()),
                icon:  Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 16.w,
                ),
              ),
            ),
          ),
        ),
        
        // Profile Avatar
        Positioned(
          bottom: 20.h, // Moved up to be fully visible within the banner
          left: 0,
          right: 250,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 40.w,
                backgroundImage: user.avatar != null
                    ? NetworkImage(user.avatar!)
                    : null,
                backgroundColor: Colors.black,
                child: user.avatar == null
                    ? Icon(
                        Icons.person_outline,
                        size: 24.w,
                        color: Colors.grey[400],
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoContainer(user) {
  return Container(

    margin: EdgeInsets.symmetric(horizontal: 8.w),
    decoration: BoxDecoration(
      color: AppColors.accent1,
      borderRadius: BorderRadius.circular(16.r),
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
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            // left: 16.w,
            top: 12.h,
             right: 150.w,
            bottom: 12.h,
          ),
          child: Center(
            child: Text(
              '${user.firstName} ${user.lastName}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        
        // Divider
        Container(
          height: 1.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.black,
          ),
        ),
        
        // Stats section
        Container(
          padding: EdgeInsets.all(10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMinimalStat(
                icon: Icons.route_outlined,
                value: user.distance.toString(),
                label: 'Distance',
                color: Colors.blue[600]!,
              ),
              _buildVerticalDivider(),
              _buildMinimalStat(
                icon: Icons.map_outlined,
                value: user.trips.toString(),
                label: 'Trips',
                color: Colors.green[600]!,
              ),
              _buildVerticalDivider(),
              _buildMinimalStat(
                icon: Icons.people_outline,
                value: user.followers.toString(),
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
    decoration: BoxDecoration(
      color: Colors.black,
    ),
  );
}

Widget _buildUserProgressCard() {
  return Obx(() {
    final user = controller.userData.value?.data;
    if (user == null) return const SizedBox();

    final currentLevel = (user.points / 100).floor() + 1;
    final nextLevelPoints = currentLevel * 100;

    return UserProgressCard(
      currentPoints: user.points,
      nextLevelPoints: nextLevelPoints,
      level: currentLevel,
    );
  });
}

Widget _buildActivityGraph() {
  return Obx(() {
    final summary = controller.tripSummary.value;

    return ActivityGraphWidget(
      tripSummary: summary,
      onDateRangeChanged: (dateRange) {},
    );
  });
}

Widget _buildInviteFriendsCard() {
  return Obx(() {
    return InviteFriendsCard(
      referralCode: controller.referralCode.value,
      onCopyCode: controller.copyReferralCode,
      onShare: controller.shareReferralCode,
    );
  });
}
}