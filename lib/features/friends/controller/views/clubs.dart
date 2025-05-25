import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/theme/app_theme.dart';
import 'package:mjollnir/features/account/controllers/user_controller.dart';
import 'package:mjollnir/features/friends/controller/groups_controller.dart';
import 'package:mjollnir/shared/components/friends/group_card.dart';
import 'package:mjollnir/shared/models/group/group_models.dart';

class ClubList extends StatelessWidget {
  const ClubList({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();
    groupController.getAlreadyJoinedGroups();
    // groupController.allGroups
    final double cardWidth = ScreenUtil().screenWidth / 2 - 30.w;
    final FilterController filterController = Get.find<FilterController>();
    
    return Obx(() {
      if (groupController.allGroups.value == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      final sortedGroups = filterController.sortGroups(
        List.from(groupController.allGroups.value ?? []),
      );
      
      if (sortedGroups.isEmpty) {
        return  Center(
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
                          style: AppTextThemes.bodyMedium()
                              .copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
      }

      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(
          sortedGroups.length,
          (index) {
            var club = sortedGroups[index];
            return SizedBox(
              width: cardWidth,
              height: 140.h,
              child: ClubCard(club: club),
            );
          },
        ),
      );
    });
  }
}

class ClubCard extends StatelessWidget {
  final Group club;
  const ClubCard({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<GroupController>();

    return GestureDetector(
      onTap: () {
        // NavigationService.pushTo(
        //   GroupUserPage(name: club.name, id: club.id),
        // );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 8,
        color: AppColors.lightSurface,
        child: Padding(
          padding: EdgeInsets.all(10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClubHeader(club: club),
              SizedBox(width: 10.h),
              StatsRow(club: club),
              JoinButton(club: club),
            ],
          ),
        ),
      ),
    );
  }
}

class ClubHeader extends StatelessWidget {
  final Group club;
  const ClubHeader({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 5),
        CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.accent,
          backgroundImage: const AssetImage('assets/images/club.png'),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: ScreenUtil().screenWidth / 2 - 105.w,
              height: 15.h,
              child: Text(
                club.name,
                style: AppTextThemes.bodyMedium()
                    .copyWith(fontSize: 11.sp, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 1.0),
              child: SizedBox(
                width: 80.w,
                height: 20.w,
                child: Text(
                  club.description,
                  style: AppTextThemes.bodySmall().copyWith(
                    fontSize: 7.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatsRow extends StatelessWidget {
  final Group club;
  const StatsRow({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    final FilterController filterController = Get.find<FilterController>();
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        String currentFilter = filterController.selectedValue.value;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatItem(
              label: 'Pts', 
              value: club.aggregatedData?.totalPoints ?? club.totalTrips,
              isHighlighted: currentFilter == 'Pts',
            ),
            _StatItem(
              label: 'Km', 
              value: (club.aggregatedData?.totalKm ?? club.totalDistance).toStringAsFixed(1),
              isHighlighted: currentFilter == 'Km',
            ),
            _StatItem(
              label: 'speed', 
              value: (club.aggregatedData?.totalCarbon ?? (club.averageSpeed/1000)).toStringAsFixed(1),
              isHighlighted: currentFilter == 'Carbon',
            ),
          ],
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool isHighlighted;
  
  const _StatItem({
    required this.label, 
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Text(
            label.toString(),
            style: AppTextThemes.bodySmall().copyWith(
              fontSize: 9.sp,
              color: isHighlighted ? AppColors.primary : Colors.black,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value.toString(),
            style: AppTextThemes.bodySmall().copyWith(
              fontSize: 9.sp,
              color: isHighlighted ? AppColors.accent : Colors.grey.shade700,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}
class JoinButton extends StatelessWidget {
  final Group club;
  const JoinButton({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    final userId =  Get.find<UserController>().userData.value?.data.uid;
    final isCreator = club.createdBy == userId;
    return Obx(() {   
      final isJoined = groupController.joined_groups
          .any((joined) => joined.id.toString() == club.id);
      
      ButtonStyle buttonStyle = ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        fixedSize: WidgetStateProperty.all(Size(130.w, 20.w)),
        backgroundColor: WidgetStateProperty.all(
          isCreator ? Colors.blue : (isJoined ? Colors.grey : AppColors.accent),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      String buttonText = isCreator ? 'My Club' : (isJoined ? 'Already Joined' : 'Join');

      return ElevatedButton(
        onPressed: isJoined || isCreator
            ? null
            : () async {
                await groupController.joinGroup(club.id);
                groupController.getAlreadyJoinedGroups();
              },
        style: buttonStyle,
        child: Center(
          child: Text(
            buttonText,
            style: AppTextThemes.bodySmall().copyWith(
              fontSize: 12.sp,
              color: AppColors.lightBackground,
            ),
          ),
        ),
      );
    });
  }
}