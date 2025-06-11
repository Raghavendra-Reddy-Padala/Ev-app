import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/features/account/controllers/user_controller.dart';
import 'package:mjollnir/features/friends/controller/follow_controller.dart';
import '../../constants/colors.dart';
import '../indicators/loading_indicator.dart';
import '../badges/text_badges.dart';

class UserHeader extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final double distance;
  final int trips;
  final int followers;
  final VoidCallback? onProfileTap;
  final String uid;

  const UserHeader({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.distance,
    required this.trips,
    required this.followers,
    this.onProfileTap,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(context),
          SizedBox(width: 12.w),
          Expanded(child: _buildUserDetails()),
          _buildProfileButton(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => _showUserProfile(context),
      child: Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: avatarUrl!,
                  placeholder: (context, url) => LoadingIndicator(
                    type: LoadingType.circular,
                    size: LoadingSize.small,
                    color: AppColors.primary,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/default_pfp.png',
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/default_pfp.png',
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  void _showUserProfile(BuildContext context) {
        final FollowController followController = FollowController();
        final UserController userController = UserController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              
              // Profile Image
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3.w),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/default_pfp.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // User Name
              Text(
                name,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileStat(
                    title: "Distance",
                    value: "${distance.toStringAsFixed(1)} km",
                  ),
                  _buildProfileStat(
                    title: "Trips",
                    value: "$trips",
                  ),
                  _buildProfileStat(
                    title: "Followers",
                    value: "$followers",
                  ),
                ],
              ),
              
              SizedBox(height: 30.h),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      
              onPressed: () {followController.followUser(uid);
              userController.getAllUsers();
              },
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        "Follow",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat({required String title, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildStatBox(
              value: "${distance.toStringAsFixed(1)}",
              unit: "km",
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            _buildStatBox(
              value: "$trips",
              unit: "trips",
              color: AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextBadge(
          text: "$followers Followers",
          type: BadgeType.neutral,
          size: BadgeSize.medium,
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      width: 50.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: " $unit",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showUserProfile(context),
      icon: Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.primary,
        size: 24.w,
      ),
      padding: EdgeInsets.zero,
    );
  }
}