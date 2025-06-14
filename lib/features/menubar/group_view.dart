import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/components/groups/club_component.dart';

import '../../shared/components/header/header.dart';
import '../../shared/constants/colors.dart';
import '../../shared/models/group/group_models.dart';
import '../friends/controller/groups_controller.dart';
import 'groups_view_all.dart';

class GroupView extends StatelessWidget {
  const GroupView({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupController.fetchUserGroups();
      groupController.fetchJoinedGroups();
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40.h),
        child: Header(heading: 'Groups'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await groupController.fetchUserGroups();
            await groupController.fetchJoinedGroups();
          },
          child: Obx(() {
            final bool isLoading = groupController.isLoading.value;
            final bool hasOwnedGroups = groupController.userGroups.isNotEmpty;
            final bool hasJoinedGroups =
                groupController.joinedGroups.isNotEmpty;

            if (isLoading) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }
            if (!hasOwnedGroups && !hasJoinedGroups) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no-data.png',
                            width: 120.w,
                            height: 120.h,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "You haven't joined or created any groups yet",
                            style: AppTextThemes.bodyMedium().copyWith(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasOwnedGroups) ...[
                      _buildSectionHeader("Owned Groups"),
                      SizedBox(height: 10.h),
                      _buildGroupsGrid(
                        groups: groupController.userGroups,
                        isOwnedGroups: true,
                      ),
                    ],
                    if (hasOwnedGroups && hasJoinedGroups)
                      SizedBox(height: 24.h),
                    if (hasJoinedGroups) ...[
                      _buildSectionHeader("Joined Groups"),
                      SizedBox(height: 10.h),
                      _buildGroupsGrid(
                        groups: groupController.joinedGroups,
                        isOwnedGroups: false,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextThemes.bodyMedium().copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: () {
              final GroupController groupController = Get.find();
              Get.to(
                () => GroupViewAllScreen(
                  title: title,
                  groups: title == "Owned Groups"
                      ? groupController.userGroups
                      : groupController.joinedGroups,
                  isOwnedGroups: title == "Owned Groups",
                ),
              );
            },
            child: Text(
              'View All',
              style: AppTextThemes.bodySmall().copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsGrid({
    required List<dynamic> groups,
    required bool isOwnedGroups,
  }) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      alignment: WrapAlignment.start,
      children: groups.map((group) {
        if (isOwnedGroups) {
          return SizedBox(
            width: 170.w,
            height: 160.h,
            child: ClubComponent(groupData: group as GroupData),
          );
        } else {
          if (group is AllGroup) {
            return SizedBox(
              width: 170.w,
              height: 160.h,
              child: ClubComponent(allGroup: group),
            );
          } else if (group is GroupData) {
            return SizedBox(
              width: 170.w,
              height: 160.h,
              child: ClubComponent(groupData: group),
            );
          }
          return const SizedBox();
        }
      }).toList(),
    );
  }
}
