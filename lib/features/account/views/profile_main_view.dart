import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/views/editprofile.dart';
import 'package:mjollnir/shared/components/profile/user_progress_card.dart';
import 'package:mjollnir/shared/components/profile/invite_friends.dart';
import 'package:mjollnir/shared/components/indicators/loading_indicator.dart';
import 'package:mjollnir/shared/components/states/empty_state.dart';
import 'package:mjollnir/shared/constants/colors.dart' show AppColors;
import '../../../shared/components/activity/activity_graph.dart';
import '../controllers/profile_controller.dart';
import '../controllers/user_controller.dart'; // Add this import

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
  late final UserController userController; // Add UserController

  _ProfileContent({required this.controller}) {
    // Initialize UserController
    userController = Get.put(UserController());
  }

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
            icon:
                Icon(Icons.account_circle_sharp, size: 64.w, color: Colors.red),
            buttonText: 'Profile',
            onButtonPressed: controller.refreshProfile,
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            _buildCompactProfileHeader(),
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

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                _buildBannerContainer(user),
                _buildInfoContainer(user),
              ],
            ),
            _buildOverlapProfilePicture(user),
          ],
        ),
      );
    });
  }

  Widget _buildBannerContainer(user) {
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
      child: Stack(
        children: [
          Container(
            height: 160.h,
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
                  ]),
              image: DecorationImage(
                image: NetworkImage(
                  user.banner! ??
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
                onTap: () => Get.to(() => EditProfileView()),
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
              child: SizedBox(
                height: 32.h,
                width: 32.w,
                child: IconButton(
                  onPressed: () => Get.to(() => EditProfileView()),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 16.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlapProfilePicture(user) {
    return Positioned(
      top: 100.h,
      left: 24.w,
      child: GestureDetector(
        onTap: () => _showFullProfileImage(user),
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
            backgroundImage:
                user.avatar != null ? NetworkImage(user.avatar!) : null,
            backgroundColor: Colors.grey[300],
            child: user.avatar == null
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

  void _showFullProfileImage(user) {
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
                  child: user.avatar != null
                      ? Image.network(
                          user.avatar!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 300.w,
                              height: 300.w,
                              color: Colors.grey[200],
                              child: Center(
                                child: LoadingIndicator(
                                  type: LoadingType.circular,
                                  size: LoadingSize.medium,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                  '${user.firstName} ${user.lastName}',
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

  Widget _buildInfoContainer(user) {
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
          SizedBox(height: 45.h),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 200, 0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade400),
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMinimalStat(
                  icon: Icons.route_outlined,
                  value: user.distance.toInt().toString(),
                  label: 'Distance',
                  color: Colors.blue[600]!,
                  onTap: null, 
                ),
                _buildVerticalDivider(),
                _buildMinimalStat(
                  icon: Icons.map_outlined,
                  value: user.trips.toString(),
                  label: 'Trips',
                  color: Colors.green[600]!,
                  onTap: null, 
                ),
                _buildVerticalDivider(),
                _buildMinimalStat(
                  icon: Icons.people_outline,
                  value: user.followers.toString(),
                  label: 'Followers',
                  color: Colors.orange[600]!,
                  onTap: () {
                    userController.showFollowersList();
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
    Widget statWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 18.w,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
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
