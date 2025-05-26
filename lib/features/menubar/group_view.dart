import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/friends/controller/groups_controller.dart';
import 'package:mjollnir/shared/components/groups/usergrouocomponent.dart';
import 'package:mjollnir/shared/components/header/header.dart';

class GroupView extends StatelessWidget {
  const GroupView({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find();

    groupController.fetchUserGroups();
    groupController.getAlreadyJoinedGroups();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Header(heading: 'User Groups'),
              Padding(
                padding: EdgeInsets.all(15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      print("Rebuilding Joined Groups Obx");
                      print(
                          "Joined groups length: ${groupController.joinedGroups.value?.length}");
                      groupController.getAlreadyJoinedGroups();
                      if (groupController.isLoading.value) {
                        return const CircularProgressIndicator();
                      } else if (groupController.joinedGroups.value == null) {
                        return Column(children: [
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: 100.w,
                            height: 100.h,
                            child: Image.asset('assets/images/no-data.png'),
                          ),
                          SizedBox(height: 20.h)
                        ]);
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Joined Groups:",
                              style: AppTextThemes.bodySmall().copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(
                                groupController.joinedGroups.value?.length ?? 0,
                                (index) {
                                  var club = groupController
                                      .joinedGroups.value?[index];
                                  return SizedBox(
                                    width: 160.w,
                                    height: 80.h,
                                    child: UserGroupComponent(club: club!),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                    SizedBox(height: 20.w),
                    Text(
                      "Owned Groups:",
                      style: AppTextThemes.bodySmall().copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 2.w),
                    Obx(() {
                      if (groupController.isLoading.value) {
                        return const CircularProgressIndicator();
                      } else if (groupController.userGroups.value == null) {
                        return Column(children: [
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: 100.w,
                            height: 100.h,
                            child: Image.asset('assets/images/no-data.png'),
                          ),
                          SizedBox(height: 20.h)
                        ]);
                      } else {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: List.generate(
                            groupController.userGroups.value.length,
                            (index) {
                              var club =
                                  groupController.joinedGroups.value?[index];
                              return SizedBox(
                                width: 160.w,
                                height: 80.h,
                                child: UserGroupComponent(club: club!),
                              );
                            },
                          ),
                        );
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
