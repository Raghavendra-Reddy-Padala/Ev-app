import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../indicators/loading_indicator.dart';

class UserProfileHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double distance;
  final int trips;
  final int followers;

  const UserProfileHeader({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.distance,
    required this.trips,
    required this.followers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildUserAvatar(),
          SizedBox(width: 16.w),
          Expanded(child: _buildUserDetails()),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 90.w,
      height: 90.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
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
    );
  }

  Widget _buildUserDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _buildMetricBadge(
              "${distance.toStringAsFixed(1)} km",
              AppColors.primary,
            ),
            SizedBox(width: 8.w),
            _buildMetricBadge(
              "$trips trips",
              AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _buildMetricBadge(
          "$followers Followers",
          Colors.black,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildMetricBadge(String text, Color color, {bool isWide = false}) {
    return Container(
      constraints: isWide ? BoxConstraints(minWidth: 120.w) : null,
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        textAlign: isWide ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}
