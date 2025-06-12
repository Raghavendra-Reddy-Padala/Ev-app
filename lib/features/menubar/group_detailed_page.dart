import 'package:bolt_ui_kit/theme/text_themes.dart' show AppTextThemes;
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Group',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupController.fetchGroupMembersDetails(groupId);
      if (groupData != null) {
        groupController.fetchGroupDetails(groupId);
      }
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildCompactGroupHeader(),
          SizedBox(height: 16.h),
          _buildUserProgressCard(),
          SizedBox(height: 16.h),
          _buildActivityGraph(),
          SizedBox(height: 16.h),
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

  Widget _buildCompactGroupHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              _buildBannerContainer(),
              _buildInfoContainer(),
            ],
          ),
          _buildOverlapGroupPicture(),
        ],
      ),
    );
  }

  Widget _buildBannerContainer() {
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
                  'https://res.cloudinary.com/djyny0qqn/image/upload/v1749388344/ChatGPT_Image_Jun_8_2025_05_27_53_PM_nu0zjs.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlapGroupPicture() {
    return Positioned(
      top: 100.h,
      left: 24.w,
      child: GestureDetector(
        onTap: () => _showFullGroupImage(),
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
            backgroundImage: (allGroup?.avatharurl != null || groupData?.avatarUrl != null)
                ? NetworkImage(allGroup?.avatharurl ?? groupData!.avatarUrl)
                : null,
            backgroundColor: Colors.grey[300],
            child: (allGroup?.avatharurl == null && groupData?.avatarUrl == null)
                ? Icon(
                    Icons.group,
                    size: 40.w,
                    color: Colors.grey[600],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void _showFullGroupImage() {
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
                  child: (allGroup?.avatharurl != null || groupData?.avatarUrl != null)
                      ? Image.network(
                          allGroup?.avatharurl ?? groupData!.avatarUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 300.w,
                              height: 300.w,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
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
                              Icons.group,
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
                            Icons.group,
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
                  groupName,
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

  Widget _buildInfoContainer() {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 24.w),
                    child: Text(
                      groupName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if ((allGroup?.description?.isNotEmpty ?? false) || 
                      (groupData?.description?.isNotEmpty ?? false))
                    Padding(
                      padding: EdgeInsets.only(left: 24.w, top: 4.h),
                      child: Text(
                        allGroup?.description ?? groupData?.description ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                  icon: Icons.people_outline,
                  value: allGroup?.memberCount.toString() ?? '0',
                  label: 'Members',
                  color: Colors.blue[600]!,
                ),
                _buildVerticalDivider(),
                _buildMinimalStat(
                  icon: Icons.route_outlined,
                  value: allGroup?.totalDistance.toStringAsFixed(1) ?? '0.0',
                  label: 'Distance',
                  color: Colors.green[600]!,
                ),
                _buildVerticalDivider(),
                _buildMinimalStat(
                  icon: Icons.travel_explore_rounded,
                  value: allGroup?.totalTrips.toStringAsFixed(1)??"0", // You might want to  activities count to your group model
                  label: 'Trips',
                  color: Colors.orange[600]!,
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
  }) {
    return Column(
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


class _GroupHeaderSection extends StatefulWidget {
  final AllGroup? allGroup;
  final GroupData? groupData;

  const _GroupHeaderSection({
    this.allGroup,
    this.groupData,
  });

  @override
  _GroupHeaderSectionState createState() => _GroupHeaderSectionState();
}

class _GroupHeaderSectionState extends State<_GroupHeaderSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Hero(
                tag: 'profile_image',
                child: widget.allGroup?.avatharurl != null || 
                       widget.groupData?.avatarUrl != null
                    ? Image.network(
                        widget.allGroup?.avatharurl ?? 
                        widget.groupData!.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primary.withOpacity(0.7),
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 100.sp,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.primary.withOpacity(0.7),
                        child: Icon(
                          Icons.group,
                          color: Colors.white,
                          size: 100.sp,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primary.withOpacity(0.7),
            AppColors.primary.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // Animated profile picture
                    Hero(
                      tag: 'profile_image',
                      child: GestureDetector(
                        onTap: _showProfileDialog,
                        onTapDown: (_) => _animationController.forward(),
                        onTapUp: (_) => _animationController.reverse(),
                        onTapCancel: () => _animationController.reverse(),
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 70.w,
                                height: 70.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: widget.allGroup?.avatharurl != null || 
                                         widget.groupData?.avatarUrl != null
                                      ? Image.network(
                                          widget.allGroup?.avatharurl ?? 
                                          widget.groupData!.avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: AppColors.primary.withOpacity(0.7),
                                              child: Icon(
                                                Icons.group,
                                                color: Colors.white,
                                                size: 30.sp,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: AppColors.primary.withOpacity(0.7),
                                          child: Icon(
                                            Icons.group,
                                            color: Colors.white,
                                            size: 30.sp,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 20.w),
                    
                    // Group info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.allGroup?.name ?? widget.groupData!.name,
                            style: AppTextThemes.bodyLarge().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.sp,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            widget.allGroup?.description ?? widget.groupData!.description,
                            style: AppTextThemes.bodyMedium().copyWith(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 14.sp,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // Stats row
                if (widget.allGroup != null)
                  Row(
                    children: [
                      _EnhancedStatChip(
                        icon: Icons.people,
                        label: 'Members',
                        value: widget.allGroup!.memberCount.toString(),
                      ),
                      SizedBox(width: 12.w),
                      _EnhancedStatChip(
                        icon: Icons.route,
                        label: 'Distance',
                        value: '${widget.allGroup!.totalDistance.toStringAsFixed(1)} km',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _EnhancedStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            '$label: $value',
            style: AppTextThemes.bodySmall().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
