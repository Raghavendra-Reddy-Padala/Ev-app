import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../indicators/loading_indicator.dart';
import '../badges/text_badges.dart';

class UserHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double distance;
  final int trips;
  final int followers;
  final VoidCallback? onProfileTap;

  const UserHeader({
    Key? key,
    required this.name,
    this.avatarUrl,
    required this.distance,
    required this.trips,
    required this.followers,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(),
          SizedBox(width: 12.w),
          Expanded(child: _buildUserDetails()),
          _buildProfileButton(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: onProfileTap,
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
      width: 75.w,
      height: 36.h,
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

  Widget _buildProfileButton() {
    return IconButton(
      onPressed: onProfileTap,
      icon: Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.primary,
        size: 24.w,
      ),
      padding: EdgeInsets.zero,
    );
  }
}
