import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/views/profile_detials.dart';
import 'package:mjollnir/shared/components/profile/user_header.dart';
import 'package:mjollnir/shared/components/profile/user_progress_card.dart';
import 'package:mjollnir/shared/components/profile/invite_friends.dart';
import 'package:mjollnir/shared/components/indicators/loading_indicator.dart';
import 'package:mjollnir/shared/components/states/empty_state.dart';
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
            _buildProfileHeader(),
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

  Widget _buildProfileHeader() {
    return Obx(() {
      final user = controller.userData.value?.data;
      if (user == null) return const SizedBox();

      return Container(
        height: 165.h,
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: NetworkImage(
              user.banner ??
                  'https://res.cloudinary.com/djyny0qqn/image/upload/v1744564353/account_bg_h0teev.png',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: UserHeader(
          name: '${user.firstName} ${user.lastName}',
          avatarUrl: user.avatar,
          distance: user.distance,
          trips: user.trips,
          followers: user.followers,
          onProfileTap: () => Get.to(()=>Profiledetails()),
        ),
      );
    });
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
