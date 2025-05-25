import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../features/account/controllers/user_controller.dart';
import '../../../features/friends/controller/groups_controller.dart';
import '../../constants/colors.dart';
import '../../models/group/group_models.dart';
import '../friends/group_card.dart';

class ClubComponent extends StatelessWidget {
  final Group club;

  const ClubComponent({
    required this.club,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Expanded(
              flex: 3,
              child: ClubHeader(club: club),
            ),

            // Stats Section
            Expanded(
              flex: 3,
              child: StatsRow(club: club),
            ),

            // Button Section
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: JoinButton(club: club),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClubHeader extends StatelessWidget {
  final Group club;

  const ClubHeader({
    required this.club,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: const AssetImage('assets/images/club.png'),
          ),
        ),

        SizedBox(width: 8.w),

        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Club Name
              Text(
                club.name,
                style: AppTextThemes.bodyMedium().copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 2.h),

              // Club Description
              Text(
                club.description,
                style: AppTextThemes.bodySmall().copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatsRow extends StatelessWidget {
  final Group club;

  const StatsRow({
    required this.club,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final FilterController filterController = Get.find<FilterController>();

    return Obx(() {
      String currentFilter = filterController.selectedValue.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _StatItem(
                label: 'Pts',
                value: (club.aggregatedData?.totalPoints ?? club.totalTrips)
                    .toString(),
                isHighlighted: currentFilter == 'Pts',
              ),
            ),
            Container(
              height: 20.h,
              width: 1,
              color: AppColors.primary.withOpacity(0.2),
            ),
            Expanded(
              child: _StatItem(
                label: 'Km',
                value: (club.aggregatedData?.totalKm ?? club.totalDistance)
                    .toStringAsFixed(1),
                isHighlighted: currentFilter == 'Km',
              ),
            ),
            Container(
              height: 20.h,
              width: 1,
              color: AppColors.primary.withOpacity(0.2),
            ),
            Expanded(
              child: _StatItem(
                label: 'Speed',
                value: (club.aggregatedData?.totalCarbon ??
                        (club.averageSpeed / 1000))
                    .toStringAsFixed(1),
                isHighlighted: currentFilter == 'Carbon',
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _StatItem({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextThemes.bodySmall().copyWith(
            fontSize: 8.sp,
            color: isHighlighted ? AppColors.primary : Colors.black54,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextThemes.bodySmall().copyWith(
            fontSize: 10.sp,
            color: isHighlighted ? AppColors.primary : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class JoinButton extends StatelessWidget {
  final Group club;

  const JoinButton({
    required this.club,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    final userId = Get.find<UserController>().userData.value?.data.uid;
    final isCreator = club.createdBy == userId;

    return Obx(() {
      final isJoined = groupController.joined_groups
          .any((joined) => joined.id.toString() == club.id);

      Color backgroundColor;
      Color textColor;
      String buttonText;
      bool isEnabled;

      if (isCreator) {
        backgroundColor = AppColors.primary.withOpacity(0.15);
        textColor = AppColors.primary;
        buttonText = 'My Club';
        isEnabled = false;
      } else if (isJoined) {
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green.shade700;
        buttonText = 'Joined';
        isEnabled = false;
      } else {
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        buttonText = 'Join';
        isEnabled = true;
      }

      return SizedBox(
        width: double.infinity,
        height: 28.h,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () async {
                  await groupController.joinGroup(club.id);
                  groupController.getAlreadyJoinedGroups();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            disabledBackgroundColor: backgroundColor,
            elevation: isEnabled ? 1 : 0,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
              side: BorderSide(
                color: isEnabled
                    ? Colors.transparent
                    : (isCreator
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3)),
                width: 1,
              ),
            ),
          ),
          child: Text(
            buttonText,
            style: AppTextThemes.bodyMedium().copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    });
  }
}
