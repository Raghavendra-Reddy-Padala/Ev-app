import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/features/friends/controller/follow_controller.dart';
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
                MembersStatisticsSection(groupMembers: groupMembers),
                SizedBox(height: 10.h),
                LeaderboardTable(groupMembers: groupMembers),
                SizedBox(height: 15.h),
                _buildTopPerformerSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopPerformerSection() {
    final sortedMembers = [...groupMembers.members];
    sortedMembers.sort((a, b) => b.kmTraveled.compareTo(a.kmTraveled));
    
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

class LeaderboardTable extends StatelessWidget {
  final GroupMembersDetailsModel groupMembers;

  const LeaderboardTable({super.key, required this.groupMembers});

  void _showUserBottomSheet(BuildContext context, dynamic member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserProfileBottomSheet(member: member),
    );
  }

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
                    onTap: () => _showUserBottomSheet(context, member),
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundImage: member.avatar.isNotEmpty 
                        ? NetworkImage(member.avatar)
                        : null,
                      backgroundColor: const Color.fromRGBO(234, 221, 255, 1),
                      child: member.avatar.isEmpty
                        ? Text(
                            member.firstName[0],
                            style: AppTextThemes.bodyMedium()
                                .copyWith(color: Colors.orange),
                          )
                        : null,
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

class UserProfileBottomSheet extends StatelessWidget {
  final dynamic member;

  const UserProfileBottomSheet({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
      final FollowController followController = FollowController();

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Profile section
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                // Profile picture with green border
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green,
                      width: 3.w,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundImage: member.avatar.isNotEmpty 
                      ? NetworkImage(member.avatar)
                      : null,
                    backgroundColor: const Color.fromRGBO(234, 221, 255, 1),
                    child: member.avatar.isEmpty
                      ? Text(
                          member.firstName[0],
                          style: AppTextThemes.bodyMedium().copyWith(
                            color: Colors.orange,
                            fontSize: 24.sp,
                          ),
                        )
                      : null,
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // User name
                Text(
                  '${member.firstName} ${member.lastName ?? ''}',
                  style: AppTextThemes.bodyMedium().copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 30.h),
                
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      '${member.kmTraveled}',
                      'Distance',
                      'km',
                      Colors.green,
                    ),
                    _buildStatColumn(
                      '${member.points ?? 18}', // Fallback if trips not available
                      'Points',
                      '',
                      Colors.green,
                    ),
                    _buildStatColumn(
                      '${member.carbonFootprint ?? 0}', 
                      'Carbon Saved',
                      '',
                      Colors.grey,
                    ),
                  ],
                ),
                
                SizedBox(height: 30.h),

                
               
                
                
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
followController.followUser(member.uid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Text(
                      'Follow',
                      style: AppTextThemes.bodyMedium().copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatColumn(String value, String label, String unit, Color color) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextThemes.bodyMedium().copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: AppTextThemes.bodySmall().copyWith(
                    fontSize: 16.sp,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextThemes.bodySmall().copyWith(
            color: Colors.grey[600],
            fontSize: 14.sp,
          ),
        ),
      ],
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
            style: AppTextThemes.bodyMedium(),
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
}