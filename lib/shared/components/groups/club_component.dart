import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../features/account/controllers/user_controller.dart';
import '../../../features/friends/controller/groups_controller.dart';
import '../../../features/menubar/group_detailed_page.dart';
import '../../constants/colors.dart';
import '../../models/group/group_models.dart';
import '../friends/group_card.dart';

class ClubComponent extends StatelessWidget {
  final AllGroup? allGroup;
  final GroupData? groupData;

  const ClubComponent({
    this.allGroup,
    this.groupData,
    super.key,
  }) : assert(
          (allGroup != null) != (groupData != null),
          'Either allGroup or groupData must be provided, but not both',
        );

  // Helper method to get unified data
  _UnifiedGroupData get _data {
    if (allGroup != null) {
      return _UnifiedGroupData.fromAllGroup(allGroup!);
    } else {
      final groupController = Get.find<GroupController>();
      final groupDetails = groupController.userGroupDetails[groupData!.id];
      return _UnifiedGroupData.fromGroupData(groupData!, groupDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => GroupDetailPage(
              allGroup: allGroup,
              groupData: groupData,
            ));
      },
      child: Container(
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
                child: ClubHeader(data: _data),
              ),

              // Stats Section
              Expanded(
                flex: 3,
                child: StatsRow(data: _data),
              ),

              // Button Section
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: JoinButton(
                    data: _data,
                    isUserGroup: groupData != null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Unified data class to handle both AllGroup and GroupData
class _UnifiedGroupData {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final int memberCount;
  final bool isMember;
  final bool isCreator;
  final String lastActivity;
  final double totalDistance;
  final int totalTrips;
  final double averageSpeed;
  final AggregatedData? aggregatedData;

  _UnifiedGroupData({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.memberCount,
    required this.isMember,
    required this.isCreator,
    required this.lastActivity,
    required this.totalDistance,
    required this.totalTrips,
    required this.averageSpeed,
    this.aggregatedData,
  });

  factory _UnifiedGroupData.fromAllGroup(AllGroup group) {
    return _UnifiedGroupData(
      id: group.id,
      name: group.name,
      description: group.description,
      createdBy: group.createdBy,
      memberCount: group.memberCount,
      isMember: group.isMember,
      isCreator: group.isCreator,
      lastActivity: group.lastActivity,
      totalDistance: group.totalDistance,
      totalTrips: group.totalTrips,
      averageSpeed: group.averageSpeed,
      aggregatedData: group.aggregatedData,
    );
  }

  factory _UnifiedGroupData.fromGroupData(
      GroupData group, GroupDetails? details) {
    final userId = Get.find<UserController>().userData.value?.data.uid;

    return _UnifiedGroupData(
      id: group.id,
      name: group.name,
      description: group.description,
      createdBy: group.createdBy,
      memberCount: 0, // Default values since GroupData doesn't have these
      isMember: true, // Assuming user is member of their groups
      isCreator: group.createdBy == userId,
      lastActivity: group.createdAt,
      totalDistance: 0.0, // Default values
      totalTrips: 0,
      averageSpeed: 0.0,
      aggregatedData: details?.aggregatedData,
    );
  }
}

class ClubHeader extends StatelessWidget {
  final _UnifiedGroupData data;

  const ClubHeader({
    required this.data,
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
                data.name,
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
                data.description,
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
  final _UnifiedGroupData data;

  const StatsRow({
    required this.data,
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
                value: (data.aggregatedData?.totalPoints ?? data.totalTrips)
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
                value: (data.aggregatedData?.totalKm ?? data.totalDistance)
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
                value: (data.aggregatedData?.totalCarbon ??
                        (data.averageSpeed / 1000))
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
  final _UnifiedGroupData data;
  final bool isUserGroup;

  const JoinButton({
    required this.data,
    required this.isUserGroup,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    final userController = Get.find<UserController>();
    
    return Obx(() {
      final userId = userController.userData.value?.data.uid;
      final isCreator = data.createdBy == userId;
      
      // Access the reactive variables within Obx
      final joinedGroupsList = groupController.joined_groups.value;
      final allGroupsList = groupController.allGroups.value;
      
      // Check if user is joined using multiple methods
      final isJoinedFromList = joinedGroupsList.any((joined) => 
        joined.id.toString() == data.id || joined.id == data.id);
      
      final isJoinedFromAllGroups = allGroupsList.any((group) => 
        group.id == data.id && group.isMember);
      
      final isJoined = data.isMember || isJoinedFromList || isJoinedFromAllGroups;

      Color backgroundColor;
      Color textColor;
      String buttonText;
      bool isEnabled;

      if (isUserGroup || isCreator) {
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
                  final success = await groupController.joinGroup(data.id);
                  if (success) {
                    // Show success message
                    Get.snackbar(
                      'Success',
                      'Successfully joined the group!',
                      backgroundColor: Colors.green.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  } else {
                    // Show error message
                    Get.snackbar(
                      'Error',
                      'Failed to join the group. Please try again.',
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  }
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
                    : (isCreator || isUserGroup
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