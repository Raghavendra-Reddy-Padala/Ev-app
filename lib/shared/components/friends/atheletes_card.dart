import 'package:bolt_ui_kit/bolt_kit.dart' as BoltKit;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../features/friends/controller/follow_controller.dart';
import '../../constants/colors.dart';
import '../../models/user/user_model.dart';

class UserLeaderboardItem extends StatelessWidget {
  final User item;
  final FollowController followController;
  final int? rank;

  const UserLeaderboardItem({
    Key? key,
    required this.item,
    required this.followController,
    this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Rank indicator (optional)
            if (rank != null) ...[
              _buildRankIndicator(),
              SizedBox(width: 12.w),
            ],

            // Avatar with online indicator
            _buildAvatar(),
            SizedBox(width: 12.w),

            // User info
            Expanded(
              child: _buildUserInfo(),
            ),

            _buildPointsSection(),
            SizedBox(width: 16.w),

            _buildFollowButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRankIndicator() {
    Color rankColor = _getRankColor();
    IconData rankIcon = _getRankIcon();

    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: rankColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: rankColor.withOpacity(0.3), width: 1),
      ),
      child: rank! <= 3
          ? Icon(rankIcon, color: rankColor, size: 18.sp)
          : Center(
              child: Text(
                rank.toString(),
                style: BoltKit.AppTextThemes.bodySmall().copyWith(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 22.r,
            backgroundColor: Colors.grey[200],
            backgroundImage: item.avatar.isNotEmpty
                ? NetworkImage(item.avatar)
                : const AssetImage('assets/images/default_pfp.png')
                    as ImageProvider,
          ),
        ),
        // Online indicator (optional)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${item.firstName} ${item.lastName}',
          style: BoltKit.AppTextThemes.bodyMedium().copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Icon(
              Icons.directions_walk_rounded,
              size: 12.sp,
              color: Colors.grey[600],
            ),
            SizedBox(width: 4.w),
            Text(
              '${item.trips} trips',
              style: BoltKit.AppTextThemes.bodySmall().copyWith(
                color: Colors.grey[600],
                fontSize: 11.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.people_outline_rounded,
              size: 12.sp,
              color: Colors.grey[600],
            ),
            SizedBox(width: 4.w),
            Text(
              '${item.followers} followers',
              style: BoltKit.AppTextThemes.bodySmall().copyWith(
                color: Colors.grey[600],
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPointsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green.withOpacity(0.1),
            AppColors.green.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars_rounded,
            color: AppColors.green,
            size: 16.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            item.points.toString(),
            style: BoltKit.AppTextThemes.bodyMedium().copyWith(
              color: AppColors.green,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
  return Obx(() {
    bool isFollowed = followController.followedUsers[item.uid] ?? false;
    bool isLoading = followController.isUserLoading(item.uid); 

    if (isLoading) {
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: SizedBox(
            width: 18.w,
            height: 18.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: isFollowed
          ? Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            )
          : GestureDetector(
              onTap: () => followController.followUser(item.uid),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.grey[600],
                  size: 18.sp,
                ),
              ),
            ),
    );
  });
}

  Color _getRankColor() {
    if (rank == null) return Colors.grey;
    switch (rank!) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getRankIcon() {
    switch (rank!) {
      case 1:
        return Icons.workspace_premium_rounded;
      case 2:
        return Icons.military_tech_rounded;
      case 3:
        return Icons.emoji_events_rounded;
      default:
        return Icons.numbers_rounded;
    }
  }
}
