import 'package:flutter/material.dart';

class UserSection extends StatelessWidget {
  const UserSection({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    userController.dataFetch();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const UserAvatar(),
          const Expanded(child: UserDetails()),
          SizedBox(width: 8.w),
          const ProfileNavigationButton(),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Obx(() {
        final avatarUrl = userController.userData.value?.data.avatar;
        return Container(
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
          child: _buildAvatarContent(avatarUrl),
        );
      }),
    );
  }

  Widget _buildAvatarContent(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        placeholder: (context, url) => _buildAvatarLoader(),
        errorWidget: (context, url, error) => _buildDefaultAvatar(),
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 38.w,
          backgroundImage: imageProvider,
        ),
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildAvatarLoader() {
    return CircularProgressIndicator(
      color: EVColors.primary,
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 38.w,
      backgroundImage: const AssetImage('assets/images/default_pfp.png'),
    );
  }
}

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Obx(() {
      final userName = userController.userData.value?.data.firstName ?? "User";
      final distance = userController.userData.value?.data.distance ?? 0;
      final trips = userController.userData.value?.data.trips ?? 0;
      final followers = userController.userData.value?.data.followers ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserName(userName),
          SizedBox(height: 6.h),
          _buildStats(distance, trips),
          SizedBox(height: 6.h),
          _buildFollowerChip(followers),
        ],
      );
    });
  }

  Widget _buildUserName(String name) {
    return Text(
      name,
      style: CustomTextTheme.bodyLargePBold.copyWith(
        color: Colors.black,
        fontSize: 18.sp,
        shadows: [
          Shadow(
            blurRadius: 2.0,
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int distance, int trips) {
    return Row(
      children: [
        UserStatBox(
          value: "$distance",
          unit: "km",
          color: EVColors.primary,
        ),
        SizedBox(width: 8.w),
        UserStatBox(
          value: "\$trips",
          unit: "trips",
          color: EVColors.primary,
        ),
      ],
    );
  }

  Widget _buildFollowerChip(int followers) {
    return Container(
      width: 180.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "$followers Followers",
          style: CustomTextTheme.bodySmallI.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}

class UserStatBox extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;

  const UserStatBox({
    super.key,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: CustomTextTheme.bodyMediumPBold.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
            Text(
              unit,
              style: CustomTextTheme.bodySmallI.copyWith(
                color: Colors.white,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileNavigationButton extends StatelessWidget {
  const ProfileNavigationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => NavigationService.pushTo(const Profile()),
      icon: Icon(
        Icons.arrow_forward_ios_rounded,
        color: EVColors.primary,
        size: 30.w,
      ),
      padding: EdgeInsets.zero,
      splashColor: EVColors.primary.withOpacity(0.3),
      highlightColor: EVColors.primary.withOpacity(0.1),
    );
  }
}
