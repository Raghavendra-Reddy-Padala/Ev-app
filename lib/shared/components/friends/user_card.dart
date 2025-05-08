import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';
import '../indicators/loading_indicator.dart';

class UserCard extends StatelessWidget {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int points;
  final double distance;
  final int trips;
  final int followers;
  final bool isFollowing;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.points,
    required this.distance,
    required this.trips,
    required this.followers,
    this.isFollowing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final FollowController followController = Get.find<FollowController>();

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          _buildAvatar(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildInfoBadge(
                        "${distance.toStringAsFixed(1)} Km",
                        AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      _buildInfoBadge(
                        "$trips Trips",
                        AppColors.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _buildInfoBadge(
                    "$followers Followers",
                    Colors.black,
                    large: true,
                  ),
                ],
              ),
            ),
          ),

          // Follow button or indicator
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Obx(() {
              final bool currentlyFollowing =
                  followController.followedUsers[userId] ?? isFollowing;
              final bool isLoading =
                  followController.isProcessingUser.value == userId;

              if (isLoading) {
                return SizedBox(
                  width: 30.w,
                  height: 30.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              return currentlyFollowing
                  ? Icon(
                      Icons.check_circle,
                      color: AppColors.green,
                      size: 30.w,
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.person_add,
                        color: AppColors.primary,
                        size: 26.w,
                      ),
                      onPressed: () => followController.followUser(userId),
                    );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: CircleAvatar(
        radius: 32.r,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: const AssetImage('assets/images/default_pfp.png'),
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl!,
                  placeholder: (context, url) => LoadingIndicator(
                    type: LoadingType.circular,
                    size: LoadingSize.small,
                    color: AppColors.primary,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 35.w,
                    color: Colors.grey,
                  ),
                  width: 64.w,
                  height: 64.w,
                  fit: BoxFit.cover,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildInfoBadge(String text, Color color, {bool large = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12.w : 8.w,
        vertical: large ? 6.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: large ? 12.sp : 10.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
