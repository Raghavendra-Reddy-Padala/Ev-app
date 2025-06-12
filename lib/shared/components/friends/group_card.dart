import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';
import '../../../features/account/controllers/user_controller.dart';
import '../../../features/friends/controller/groups_controller.dart';
import '../../constants/colors.dart';
import '../../models/group/group_models.dart';
import '../buttons/app_button.dart';
import '../cards/app_cards.dart';

class GroupCard extends StatelessWidget {
  final AllGroup group;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();
    final UserController userController = Get.find<UserController>();
    final String? currentUserId = userController.userData.value?.data.uid;
    final bool isCreator = group.createdBy == currentUserId;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupHeader(isCreator),
          SizedBox(height: 8.h),
          _buildGroupDescription(),
          SizedBox(height: 12.h),
          _buildStatsRow(),
          SizedBox(height: 12.h),
          _buildJoinButton(groupController, isCreator),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(bool isCreator) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: AppColors.green.withOpacity(0.2),
          backgroundImage: const AssetImage('assets/images/club.png'),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isCreator)
                Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Created by you',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupDescription() {
    return Text(
      group.description,
      style: TextStyle(
        fontSize: 12.sp,
        color: Colors.grey.shade700,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final currentFilter = Get.find<FilterController>().selectedValue.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Points',
            value: group.aggregatedData?.totalPoints ?? group.totalTrips,
            isHighlighted: currentFilter == 'Pts',
          ),
          _StatItem(
            label: 'Distance',
            value: (group.aggregatedData?.totalKm ?? group.totalDistance)
                .toStringAsFixed(1),
            unit: 'km',
            isHighlighted: currentFilter == 'Km',
          ),
          _StatItem(
            label: 'Carbon Saved',
            value: (group.aggregatedData?.totalCarbon ??
                    (group.averageSpeed / 1000))
                .toStringAsFixed(1),
            unit: 'kg',
            isHighlighted: currentFilter == 'Carbon',
          ),
        ],
      );
    });
  }

  Widget _buildJoinButton(GroupController groupController, bool isCreator) {
    return Obx(() {
      final bool isJoined = groupController.joined_groups
          .any((joined) => joined.toString() == group.id);

      if (isCreator) {
        return AppButton(
          text: 'My Group',
          type: ButtonType.outline,
          onPressed: null, // Disabled
          fullWidth: true,
        );
      }

      if (isJoined) {
        return AppButton(
          text: 'Already Joined',
          type: ButtonType.outline,
          onPressed: null, // Disabled
          fullWidth: true,
        );
      }

      return AppButton(
        text: 'Join Group',
        onPressed: () async {
          await groupController.joinGroup(group.id);
          groupController.getAlreadyJoinedGroups();
        },
        fullWidth: true,
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final dynamic value;
  final String? unit;
  final bool isHighlighted;

  const _StatItem({
    required this.label,
    required this.value,
    this.unit,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
      color: isHighlighted ? AppColors.green : Colors.black87,
    );

    final TextStyle labelStyle = TextStyle(
      fontSize: 10.sp,
      fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
      color: isHighlighted ? AppColors.green : Colors.grey.shade600,
    );

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: valueStyle,
            ),
            if (unit != null) ...[
              SizedBox(width: 2.w),
              Text(
                unit!,
                style: valueStyle.copyWith(
                  fontSize: 10.sp,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: labelStyle,
        ),
      ],
    );
  }
}

class FilterController extends GetxController {
  final RxString selectedValue = 'Pts'.obs;
  void changeFilter(String value) {
    selectedValue.value = value;
  }

  List<User> sortUsers(List<User> users) {
    switch (selectedValue.value) {
      case 'Pts':
        users.sort((a, b) => b.points.compareTo(a.points));
        break;
      case 'followers':
        users.sort((a, b) => b.followers.compareTo(a.followers));
        break;
      case 'Trips':
        users.sort((a, b) => b.trips.compareTo(a.trips));
        break;
    }
    return users;
  }

  List<AllGroup> sortGroups(List<AllGroup> groups ) {
    switch (selectedValue.value) {
      case 'Pts':
        groups.sort((a, b) => (b.aggregatedData?.totalPoints ?? b.totalTrips)
            .compareTo(a.aggregatedData?.totalPoints ?? 0));
        break;
      case 'Km':
        groups.sort((a, b) => (b.aggregatedData?.totalKm ?? b.totalDistance)
            .compareTo(a.aggregatedData?.totalKm ?? 0));
        break;
      case 'Carbon':
        groups.sort((a, b) =>
            (b.aggregatedData?.totalCarbon ?? (b.averageSpeed / 1000))
                .compareTo(a.aggregatedData?.totalCarbon ?? 0));
        break;
     
    }
    return groups;
  }
}

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final FilterController controller;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
           SizedBox(width: 25.w),
          Text('Filter', style: AppTextThemes.bodyLarge()),
                    const SizedBox(width: 10),
      
          const Spacer(),
          Container(
            height: 30.w,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(
              () => DropdownButton<String>(
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(10),
                icon: const Icon(Icons.keyboard_arrow_down),
                style: AppTextThemes.bodySmall().copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                value: controller.selectedValue.value,
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: AppTextThemes.bodySmall().copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) => controller.changeFilter(value!),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().screenWidth * 0.04),
        ],
      ),
    );
  }
}
