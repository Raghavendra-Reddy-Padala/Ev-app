import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/components/groups/club_component.dart';

import '../../shared/components/header/header.dart';
import '../friends/controller/groups_controller.dart';

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
        child: Obx(() => SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOwnedGroups(groupController),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildOwnedGroups(GroupController groupController) {
    if (groupController.isLoading.value) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Owned Groups:",
              style: AppTextThemes.bodySmall().copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            const CircularProgressIndicator(),
          ],
        ),
      );
    } else if (groupController.userGroups.isEmpty) {
      return _buildEmptyState("Owned Groups:");
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Owned Groups:",
            style: AppTextThemes.bodySmall().copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: groupController.userGroups
                .map((club) => SizedBox(
                      width: 170.w,
                      height: 160.h,
                      child: ClubComponent(groupData: club),
                    ))
                .toList(),
          ),
        ],
      );
    }
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          Text(
            title,
            style: AppTextThemes.bodySmall().copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: 140.w,
            height: 140.h,
            child: Image.asset('assets/images/no-data.png'),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
