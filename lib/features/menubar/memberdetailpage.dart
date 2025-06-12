import 'dart:math';
import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/shared/components/activity/activity_widget.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/group/group_models.dart';

class MemberDetailPage extends StatefulWidget {
  final GroupMembersDetailsModel groupMembers;
  final String name;

  const MemberDetailPage(
      {super.key, required this.groupMembers, required this.name});

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

  void _showProfileImage(String imageUrl, String userName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color.fromRGBO(234, 221, 255, 1),
                      child: const Icon(Icons.person, size: 100, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Column(
              children: [
                SizedBox(height: 0.01),
                Header(heading: widget.name),
                SizedBox(height: 10.h),
                SizedBox(
                  child: LeaderboardTable(
                    groupMembers: widget.groupMembers,
                    onProfileTap: _showProfileImage,
                  ),
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
                            Row(
                              children: [
                                DropdownButton<String>(
                                  value: selectedTimeFilter,
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.black),
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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isActivityExpanded = !isActivityExpanded;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      isActivityExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),
                                  ),
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
                                  children: List.generate(widget.groupMembers.members.length, (index) {
                                    final randomIndex = Random().nextInt(pathPointsList.length);
                                    final member = widget.groupMembers.members[index];
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _showProfileImage(member.avatar, member.firstName),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              margin: const EdgeInsets.only(right: 12, top: 8),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color.fromRGBO(234, 221, 255, 1),
                                                  width: 2,
                                                ),
                                              ),
                                              child: ClipOval(
                                                child: Image.network(
                                                  member.avatar,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    color: const Color.fromRGBO(234, 221, 255, 1),
                                                    child: const Icon(Icons.person, color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ActivityWidget(
                                              pathPoints: pathPointsList[randomIndex],
                                              trip: null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
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

class LeaderboardTable extends StatelessWidget {
  final GroupMembersDetailsModel groupMembers;
  final Function(String, String) onProfileTap;

  const LeaderboardTable({
    super.key, 
    required this.groupMembers,
    required this.onProfileTap,
  });

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
                  final member = groupMembers.members[index];
                  return ListTile(
                    minTileHeight: 60,
                    leading: GestureDetector(
                      onTap: () => onProfileTap(member.avatar, member.firstName),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromRGBO(234, 221, 255, 1),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            member.avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color.fromRGBO(234, 221, 255, 1),
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      member.firstName,
                      style: AppTextThemes.bodyMedium()
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      '${member.kmTraveled} km',
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