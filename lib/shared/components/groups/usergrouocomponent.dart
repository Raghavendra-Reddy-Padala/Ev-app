import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/friends/controller/groups_controller.dart';
import 'package:mjollnir/shared/components/header/arrow.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/group/group_models.dart';

class UserGroupComponent extends StatelessWidget {
  final AllGroup club;
  const UserGroupComponent({required this.club, super.key});

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
        color: AppColors.offwhite,
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: ClubHeader(club: club),
        ),
      ),
    );
  }
}

class ClubHeader extends StatelessWidget {
  final AllGroup club;
  const ClubHeader({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 2.w),
        CircleAvatar(
          radius: 15.r,
          backgroundColor: AppColors.green,
          backgroundImage: const AssetImage('assets/images/club.png'),
        ),
        SizedBox(width: 2.w),
        SizedBox(
          width: 65.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 80.w,
                height: 15.h,
                child: Text(
                  club.name,
                  style: AppTextThemes.bodyMedium().copyWith(
                      fontSize: 11.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 1.0),
                child: Container(
                  width: 80.w,
                  constraints: BoxConstraints(maxHeight: 30.w),
                  child: Text(
                    club.description,
                    style: AppTextThemes.bodyMedium().copyWith(
                      fontSize: 7.sp,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Arrow(left: false, color: AppColors.primary, size: 25.w),
      ],
    );
  }
}
