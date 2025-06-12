import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/features/friends/views/individualuser.dart';
import 'package:mjollnir/shared/components/activity/activity_widget.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/group/group_models.dart';

class MemberDetailPage extends StatefulWidget {
  final GroupMembersDetailsModel groupMembers;
  final String name;

  const MemberDetailPage({super.key, required this.groupMembers, required this.name});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  bool isActivityExpanded = true;
  String selectedTimeFilter = 'All Time';
  final List<String> timeFilters = ['All Time', 'This Week', 'This Month', 'Today'];

  final List<List<LatLng>> pathPointsList = [

    [
      LatLng(37.7749, -122.4194),
      LatLng(37.7849, -122.4094),
      LatLng(37.7949, -122.3994),
    ],
    [
      LatLng(34.0522, -118.2437),
      LatLng(34.0622, -118.2537),
      LatLng(34.0722, -118.2637),
    ],
    [
      LatLng(40.7128, -74.0060),
      LatLng(40.7228, -74.0160),
      LatLng(40.7328, -74.0260),
    ],
    [
      LatLng(51.5074, -0.1278),
      LatLng(51.5174, -0.1378),
      LatLng(51.5274, -0.1478),
    ],
    [
      LatLng(48.8566, 2.3522),
      LatLng(48.8666, 2.3622),
      LatLng(48.8766, 2.3722),
    ],
    [
      LatLng(35.6895, 139.6917),
      LatLng(35.6995, 139.7017),
      LatLng(35.7095, 139.7117),
    ],
    [
      LatLng(-33.8688, 151.2093),
      LatLng(-33.8588, 151.1993),
      LatLng(-33.8488, 151.1893),
    ],
    [
      LatLng(55.7558, 37.6173),
      LatLng(55.7658, 37.6273),
      LatLng(55.7758, 37.6373),
    ],
  ];
  
 
  
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Header(heading: widget.name),
                SizedBox(height: 16.h),
                
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.offwhite,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                DropdownButton<String>(
                                  value: selectedTimeFilter,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                                  items: timeFilters.map((String filter) {
                                    return DropdownMenuItem<String>(
                                      value: filter,
                                      child: Text(filter),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedTimeFilter = newValue!;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    isActivityExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isActivityExpanded = !isActivityExpanded;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: isActivityExpanded ? null : 0,
                          child: isActivityExpanded
                              ? Column(
                                  children: List.generate(
                                    widget.groupMembers.members.length,
                                    (index) {
                                      final randomIndex = Random().nextInt(pathPointsList.length);
                                      final member = widget.groupMembers.members[index];
                                      
                                      return  GestureDetector(
  onTap: () {
    Get.to(() => IndividualUserPage(
      uid: member.uid,
      trips: member.points,
      followers: member.carbonFootprint.toInt(),
      avatharurl: member.avatar,
      name: member.firstName,
      distance: member.kmTraveled.toString(),
      points: member.points
    ));
  },
  child: Container(
    margin: EdgeInsets.only(bottom: 16.h),
    decoration: BoxDecoration(
      color: AppColors.accent1,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 24.h),
          child: ActivityWidget(
            pathPoints: pathPointsList[randomIndex],
            trip: null,
          ),
        ),
        Positioned(
          top: 8.h,
          left: 16.w,
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(234, 221, 255, 1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                member.avatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color.fromRGBO(234, 221, 255, 1),
                  child: Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
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