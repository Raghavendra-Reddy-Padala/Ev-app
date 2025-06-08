import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/constants/colors.dart' show AppColors;
import 'package:mjollnir/shared/models/group/group_models.dart';

class GroupMembersPage extends StatelessWidget {
  final GroupMembersDetailsModel groupMembers;
  final String name;

  const GroupMembersPage({
    super.key, 
    required this.groupMembers, 
    required this.name
  });

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
                Header(heading: "$name Members"),
                SizedBox(height: 10.h),
                // Members leaderboard table
                LeaderboardTable(groupMembers: groupMembers),
                SizedBox(height: 15.h),
                // Members Statistics section
                MembersStatisticsSection(groupMembers: groupMembers),
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
                          .members[index].firstName,
                      style: AppTextThemes.bodyMedium()
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      '${groupMembers.members[index].kmTraveled} km',
                      style:  AppTextThemes.bodyMedium()
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

class MembersStatisticsSection extends StatelessWidget {
  final GroupMembersDetailsModel groupMembers;

  const MembersStatisticsSection({
    super.key, 
    required this.groupMembers
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total group statistics
    double totalDistance = 0;
    int totalMembers = groupMembers.members.length;
    double averageDistance = 0;
    
    for (var member in groupMembers.members) {
      totalDistance += member.kmTraveled;
    }
    
    if (totalMembers > 0) {
      averageDistance = totalDistance / totalMembers;
    }

    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Statistics',
            style:  AppTextThemes.bodyMedium(),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Total Members', 
                '$totalMembers', 
                Icons.group,
                Colors.blue.shade100
              ),
              _buildStatCard(
                'Total Distance', 
                '${totalDistance.toStringAsFixed(1)} km', 
                Icons.straighten,
                Colors.green.shade100
              ),
              _buildStatCard(
                'Avg Distance', 
                '${averageDistance.toStringAsFixed(1)} km', 
                Icons.trending_up,
                Colors.orange.shade100
              ),
            ],
          ),
          SizedBox(height: 15.h),
          // Top performers section
          _buildTopPerformerSection(),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 5.h),
          Text(
            value,
            style: AppTextThemes.bodyMedium().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: AppTextThemes.bodySmall(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopPerformerSection() {
    // Sort members by distance traveled
    final sortedMembers = [...groupMembers.members];
    sortedMembers.sort((a, b) => b.kmTraveled.compareTo(a.kmTraveled));
    
    // Get top performer
    final topPerformer = sortedMembers.isNotEmpty ? sortedMembers.first : null;
    
    if (topPerformer == null) {
      return SizedBox();
    }
    
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundImage: NetworkImage(topPerformer.avatar),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Performer',
                style: AppTextThemes.bodySmall().copyWith(
                  color: Colors.grey,
                ),
              ),
              Text(
                '${topPerformer.firstName} ${topPerformer.lastName}',
                style: AppTextThemes.bodyMedium(),
              ),
              Text(
                '${topPerformer.kmTraveled} km',
                style: AppTextThemes.bodySmall().copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Spacer(),
          Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 30,
          ),
        ],
      ),
    );
  }
}