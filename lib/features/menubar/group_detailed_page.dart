import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/profile_controller.dart';
import 'package:mjollnir/features/menubar/memberdetailpage.dart';
import 'package:mjollnir/shared/components/activity/activity_graph.dart';
import 'package:mjollnir/shared/components/groups/groupmemberpage.dart';
import 'package:mjollnir/shared/components/profile/user_progress_card.dart';

import '../../shared/components/header/header.dart';
import '../../shared/constants/colors.dart';
import '../../shared/models/group/group_models.dart';
import '../friends/controller/groups_controller.dart';

class GroupDetailPage extends StatelessWidget {
  final AllGroup? allGroup;
  final GroupData? groupData;

  const GroupDetailPage({
    this.allGroup,
    this.groupData,
    super.key,
  }) : assert(
          (allGroup != null) != (groupData != null),
          'Either allGroup or groupData must be provided, but not both',
        );

  String get groupId => allGroup?.id ?? groupData!.id;
  String get groupName => allGroup?.name ?? groupData!.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40.h),
        child: Header(heading: groupName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _GroupDetailUI(
                allGroup: allGroup,
                groupData: groupData,
                controller: ProfileController(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupDetailUI extends StatelessWidget {
  final AllGroup? allGroup;
  final GroupData? groupData;
  final ProfileController controller;

  const _GroupDetailUI({
    required this.controller,
    this.allGroup,
    this.groupData,
  });

  String get groupId => allGroup?.id ?? groupData!.id;
  String get groupName => allGroup?.name ?? groupData!.name;

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find();

    // Fetch member details when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupController.fetchGroupMembersDetails(groupId);
      if (groupData != null) {
        // Also fetch group details for GroupData
        groupController.fetchGroupDetails(groupId);
      }
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),

          _GroupHeaderSection(
            allGroup: allGroup,
            groupData: groupData,
          ),

          SizedBox(height: 16.h),

        
          _buildUserProgressCard(),

          SizedBox(height: 16.h),

      
          _buildActivityGraph(),

          SizedBox(height: 20.h),

          Column(
            children: [
              _GroupMembersRow(groupId: groupId, groupName: groupName),
              SizedBox(height: 16.h),
              _GroupActivityRow(groupId: groupId, groupName: groupName),
            ],
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

Widget _buildUserProgressCard() {
  return Obx(() {
    final user = ProfileController().userData.value?.data;
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
    final summary = ProfileController().tripSummary.value;

    return ActivityGraphWidget(
      tripSummary: summary,
      onDateRangeChanged: (dateRange) {},
    );
  });
}

class _GroupHeaderSection extends StatelessWidget {
  final AllGroup? allGroup;
  final GroupData? groupData;

  const _GroupHeaderSection({
    this.allGroup,
    this.groupData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage:  NetworkImage ( allGroup?.avatharurl ?? groupData!.avatarUrl 
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allGroup?.name ?? groupData!.name,
                      style: AppTextThemes.bodyLarge().copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      allGroup?.description ?? groupData!.description,
                      style: AppTextThemes.bodyMedium().copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (allGroup != null)
            Row(
              children: [
                _StatChip(
                  label: 'Members',
                  value: allGroup!.memberCount.toString(),
                ),
                SizedBox(width: 12.w),
                _StatChip(
                  label: 'Total Distance',
                  value: '${allGroup!.totalDistance.toStringAsFixed(1)} km',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '${label}: ${value}',
        style: AppTextThemes.bodySmall().copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class _GroupActivityRow extends StatelessWidget {
  final String groupId;
  final String groupName;

  const _GroupActivityRow({
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find();

    return Obx(() {
      if (groupController.isLoading.value) {
        return _buildLoadingRow('Activity');
      }

      if (groupController.errorMessage.value.isNotEmpty) {
        return _buildErrorRow('Activity', groupController.errorMessage.value);
      }

      final memberDetails = groupController.groupMembersDetails.value;
      if (memberDetails == null || memberDetails.members.isEmpty) {
        return _buildEmptyRow('Activity');
      }

      final displayedMembers = memberDetails.members.take(3).toList();

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.primary.withOpacity(0.1),
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activity',
              style: AppTextThemes.bodyMedium().copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Row(
                  children: displayedMembers.map((member) {
                    return Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: member.avatar.isNotEmpty
                            ? NetworkImage(member.avatar)
                            : null,
                        child: member.avatar.isEmpty
                            ? Icon(Icons.person, size: 18.sp)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    Get.to(() => MemberDetailPage(
                      groupMembers: memberDetails,
                      name: groupName,
                    ));
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingRow(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.primary.withOpacity(0.1),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextThemes.bodyMedium().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildErrorRow(String title, String error) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.red.withOpacity(0.1),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextThemes.bodyMedium().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              'Error: $error',
              style: AppTextThemes.bodySmall().copyWith(
                color: Colors.red,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRow(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.primary.withOpacity(0.1),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextThemes.bodyMedium().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'No data available',
            style: AppTextThemes.bodySmall().copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupMembersRow extends StatelessWidget {
  final String groupId;
  final String groupName;

  const _GroupMembersRow({
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find();

    return Obx(() {
      if (groupController.isLoading.value) {
        return _buildLoadingRow('Members');
      }

      if (groupController.errorMessage.value.isNotEmpty) {
        return _buildErrorRow('Members', groupController.errorMessage.value);
      }

      final memberDetails = groupController.groupMembersDetails.value;

      // Debug print to see what data you're getting
      print('Member details: $memberDetails');
      print('Members list: ${memberDetails?.members}');

      if (memberDetails == null) {
        print('memberDetails is null');
        return _buildEmptyRow('Members');
      }

      if (memberDetails.members.isEmpty) {
        print('memberDetails.members is empty');
        return _buildEmptyRow('Members');
      }

      final displayedMembers = memberDetails.members.take(3).toList();
      print('Displayed members: $displayedMembers');

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.primary.withOpacity(0.1),
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Members',
              style: AppTextThemes.bodyMedium().copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Row(
                  children: displayedMembers.map((member) {
             

                    return Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundColor: Colors.orange,
                        backgroundImage:
                            (member.avatar != null && member.avatar!.isNotEmpty)
                                ? NetworkImage(member.avatar!)
                                : null,
                        child: (member.avatar == null || member.avatar!.isEmpty)
                            ? Text(
                                _getInitial(member),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    Get.to(() => GroupMembersPage(
                          groupMembers: memberDetails,
                          name:
                              "${memberDetails.members[0].firstName} ${memberDetails.members[0].lastName}",
                        ));
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _getInitial(dynamic member) {
    // Try different ways to access the first name
    try {
      // Method 1: If your model has firstName property
      if (member.firstName != null && member.firstName.isNotEmpty) {
        return member.firstName[0].toUpperCase();
      }
    } catch (e) {
      print('Error accessing firstName: $e');
    }

    try {
      // Method 2: If your model has first_name property
      if (member.first_name != null && member.first_name.isNotEmpty) {
        return member.first_name[0].toUpperCase();
      }
    } catch (e) {
      print('Error accessing first_name: $e');
    }

    try {
      // Method 3: If member is a Map
      if (member is Map &&
          member['first_name'] != null &&
          member['first_name'].toString().isNotEmpty) {
        return member['first_name'].toString()[0].toUpperCase();
      }
    } catch (e) {
      print('Error accessing map first_name: $e');
    }

    // Fallback
    return 'U';
  }

  Widget _buildLoadingRow(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.primary.withOpacity(0.1),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextThemes.bodyMedium().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildErrorRow(String title, String error) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.red.withOpacity(0.1),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextThemes.bodyMedium().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              'Error: $error',
              style: AppTextThemes.bodySmall().copyWith(
                color: Colors.red,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRow(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.primary.withOpacity(0.1),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextThemes.bodyMedium().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'No data available',
            style: AppTextThemes.bodySmall().copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
