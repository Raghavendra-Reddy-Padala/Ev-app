import 'dart:math';

import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/user_controller.dart';
import 'package:mjollnir/features/friends/controller/follow_controller.dart';
import 'package:mjollnir/features/friends/views/clubs.dart';
import 'package:mjollnir/features/friends/views/individualuser.dart';
import 'package:mjollnir/shared/components/friends/group_card.dart';
import 'package:mjollnir/shared/constants/colors.dart';

import '../../../shared/components/friends/atheletes_card.dart';

class TabControllerX extends GetxController {
  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

class LeaderBoardClubTab extends StatelessWidget {
  final TabControllerX tabControllerX = Get.put(TabControllerX());
  final FilterController filterController = Get.put(FilterController());

  LeaderBoardClubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Container(
            width: ScreenUtil().screenWidth,
            height: 50.w,
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.green, width: 1),
            ),
            child: Row(
              children: [
                _buildTab(
                  context,
                  label: 'Athletes',
                  isSelected: tabControllerX.selectedIndex.value == 0,
                  onTap: () => tabControllerX.changeTab(0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                _buildTab(
                  context,
                  label: 'Groups',
                  isSelected: tabControllerX.selectedIndex.value == 1,
                  onTap: () => tabControllerX.changeTab(1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        CustomDropdown(
          items: const ['Pts', 'Km', 'Carbon'],
          controller: filterController,
        ),
        Obx(() => tabControllerX.selectedIndex.value == 0
            ? const LeaderBoardList()
            : const ClubList()),
      ],
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BorderRadius borderRadius,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50.w,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.green : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextThemes.bodyMedium().copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LeaderBoardList extends StatelessWidget {
  const LeaderBoardList({super.key});

  @override
  Widget build(BuildContext context) {
    final FollowController followController = Get.find();
    final UserController userController = Get.find<UserController>();
    final FilterController filterController = Get.find<FilterController>();
    print(
        "Building LeaderBoardList, has users: ${userController.getAllUsers.value != null}");
    if (userController.getAllUsers.value != null) {
      print("User count: ${userController.getAllUsers.value!.data.length}");
    }

    return Obx(() {
      if (userController.isLoading.value) {
      return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (userController.getAllUsers.value == null ||
          userController.getAllUsers.value!.data.isEmpty) {
        return Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: SizedBox(
                  width: 100.w,
                  height: 100.h,
                  child: Image.asset('assets/images/no-data.png'),
                ),
              ),
              Text(
                'No Users found!',
                style: AppTextThemes.bodyMedium().copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      final sortedUsers = filterController.sortUsers(
        List.from(userController.getAllUsers.value!.data),
      );

      if (sortedUsers.isEmpty) {
        return Center(child: Text("No users match the current filter"));
      }

      return Column(
        children: sortedUsers
            .sublist(
                0,
                min(sortedUsers.length,
                    userController.getAllUsers.value!.data.length % 50))
            .map((item) {
          return InkWell(
            onTap: () {
              Get.to(()=>
                IndividualUserPage(
                  uid: item.uid,
                  trips: item.trips,
                  followers: item.followers,
                  avatharurl: item.avatar,
                  name: item.firstName,
                  distance: item.distance.toInt().toString(),
                  points:item.points

                ),
              );
            },
            child: UserLeaderboardItem(
              item: item,
              followController: followController,
            ),
          );
        }).toList(),
      );
    });
  }
}
