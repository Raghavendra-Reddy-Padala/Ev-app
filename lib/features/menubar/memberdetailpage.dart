import 'dart:math';
import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:mjollnir/shared/components/activity/activity_widget.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/group/group_models.dart';

class MemberDetailPage extends StatelessWidget {
  final GroupMembersDetailsModel groupMembers;
  final String name;

  const MemberDetailPage(
      {super.key, required this.groupMembers, required this.name});

  @override
  Widget build(BuildContext context) {
    final List<List<LatLng>> pathPointsList = [
      [
        LatLng(37.7749, -122.4194),
        LatLng(37.7755, -122.4189),
        LatLng(37.7762, -122.4180),
        LatLng(37.7773, -122.4165),
        LatLng(37.7785, -122.4145),
        LatLng(37.7849, -122.4094),
      ],
      [
        LatLng(40.7128, -74.0060),
        LatLng(40.7134, -74.0054),
        LatLng(40.7151, -74.0040),
        LatLng(40.7163, -74.0030),
        LatLng(40.7180, -74.0015),
        LatLng(40.7201, -73.9995),
      ],
      [
        LatLng(51.5074, -0.1278),
        LatLng(51.5080, -0.1285),
        LatLng(51.5092, -0.1298),
        LatLng(51.5100, -0.1305),
        LatLng(51.5115, -0.1320),
        LatLng(51.5145, -0.1345),
      ],
      [
        LatLng(48.8566, 2.3522),
        LatLng(48.8570, 2.3530),
        LatLng(48.8582, 2.3550),
        LatLng(48.8594, 2.3565),
        LatLng(48.8607, 2.3580),
        LatLng(48.8622, 2.3600),
      ],
      [
        LatLng(-33.8688, 151.2093),
        LatLng(-33.8695, 151.2105),
        LatLng(-33.8708, 151.2120),
        LatLng(-33.8715, 151.2130),
        LatLng(-33.8723, 151.2145),
        LatLng(-33.8740, 151.2160),
      ],
    ];

    final screenHeight = MediaQuery.of(context).size.height;
    TripsController tripController = Get.find<TripsController>();
                          final trip = tripController.trips[0];


    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Column(
              children: [
                SizedBox(height: 0.01),
                Header(heading: name),
                SizedBox(height: 10.h),
                SizedBox(
                  child: LeaderboardTable(groupMembers: groupMembers),
                ),
                SizedBox(height: 10.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.offwhite,
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.05),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenHeight * 0.005),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(screenHeight * 0.01),
                              child: Text(
                                'Group Recent Activity',
                                style: AppTextThemes.bodySmall()
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            DropdownButton(
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black),
                              items: List.empty(),
                              onChanged: null,
                            ),
                          ],
                        ),
                        ...List.generate(groupMembers.members.length, (index) {
                          final randomIndex =
                              Random().nextInt(pathPointsList.length);
                          return ActivityWidget(
                            pathPoints: pathPointsList[randomIndex],
                            trip: trip,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LeaderboardTable extends StatelessWidget {
  final GroupMembersDetailsModel groupMembers;

  const LeaderboardTable({super.key, required this.groupMembers});

  @override
  Widget build(BuildContext context) {
    double listHeight = groupMembers.members.length * 60;

    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
      ),
      child: Column(
        children: [
          const SizedBox(height: 0.01),
          Row(
            children: [
              SizedBox(width: ScreenUtil().screenWidth * 0.18),
              Text('Name', style: AppTextThemes.bodyMedium()),
              SizedBox(width: ScreenUtil().screenWidth * 0.32),
              Text('Distance', style: AppTextThemes.bodyMedium()),
            ],
          ),
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              itemCount: groupMembers.members.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (index < groupMembers.members.length) {
                  return ListTile(
                    minTileHeight: 60,
                    leading: CircleAvatar(
                      backgroundColor: const Color.fromRGBO(234, 221, 255, 1),
                      child: Text(
                        groupMembers.members[index].firstName[0],
                        style: AppTextThemes.bodyMedium()
                            .copyWith(color: Colors.orange),
                      ),
                    ),
                    title: Text(
                      groupMembers
                          .members[index].firstName, // Accessing member's name
                      style:AppTextThemes.bodyMedium()
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      '${groupMembers.members[index].kmTraveled} km', // Accessing member's distance
                      style: AppTextThemes.bodyMedium()
                          .copyWith(color: Colors.black),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
