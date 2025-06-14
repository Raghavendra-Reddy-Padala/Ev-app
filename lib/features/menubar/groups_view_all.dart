import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/components/groups/club_component.dart';
import 'package:bolt_ui_kit/theme/text_themes.dart';

import '../../shared/components/header/header.dart';
import '../../shared/models/group/group_models.dart';

class GroupViewAllScreen extends StatelessWidget {
  final String title;
  final List<dynamic> groups;
  final bool isOwnedGroups;

  const GroupViewAllScreen({
    Key? key,
    required this.title,
    required this.groups,
    required this.isOwnedGroups,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40.h),
        child: Header(heading: title),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: groups.isEmpty ? _buildEmptyState() : _buildGroupsGrid(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            "No groups found",
            style: AppTextThemes.bodyMedium().copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 170.w / 160.h,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return SizedBox(
          width: 170.w,
          height: 160.h,
          child: isOwnedGroups
              ? ClubComponent(groupData: group as GroupData)
              : (group is AllGroup)
                  ? ClubComponent(allGroup: group)
                  : ClubComponent(groupData: group as GroupData),
        );
      },
    );
  }
}
