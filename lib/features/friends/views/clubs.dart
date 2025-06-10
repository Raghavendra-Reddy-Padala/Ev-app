import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/friends/controller/groups_controller.dart';
import 'package:mjollnir/shared/components/friends/group_card.dart';
import 'package:mjollnir/shared/components/groups/club_component.dart';
import 'package:mjollnir/shared/models/group/group_models.dart';

class ClubList extends StatelessWidget {
  const ClubList({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();
    final double cardWidth = ScreenUtil().screenWidth / 2 - 30.w;
    final FilterController filterController = Get.find<FilterController>();

    return Obx(() {
      // Fix: Remove .value and add loading/error handling
      if (groupController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }


      if (groupController.allGroups.isEmpty) {
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
                'No Groups found!',
                style: AppTextThemes.bodyMedium().copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      final sortedGroups = filterController.sortGroups(
        List.from(groupController.allGroups),
      );

      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(
          sortedGroups.length,
          (index) {
            var club = sortedGroups[index];
            return SizedBox(
              width: cardWidth,
              height: 160.h,
              child: ClubCard(club: club),
            );
          },
        ),
      );
    });
  }
}

class ClubCard extends StatelessWidget {
  final AllGroup club;
  const ClubCard({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<GroupController>();

    return GestureDetector(
      child: ClubComponent(allGroup: club),
    );
  }
}
