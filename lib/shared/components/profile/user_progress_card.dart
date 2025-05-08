import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';

class UserProgressCard extends StatelessWidget {
  final int currentPoints;
  final int nextLevelPoints;
  final int level;

  const UserProgressCard({
    Key? key,
    required this.currentPoints,
    required this.nextLevelPoints,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progressPercentage = currentPoints / nextLevelPoints;
    final int remainingPoints = nextLevelPoints - currentPoints;

    return AppCard(
      backgroundColor: AppColors.accent1,
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Level icon
          _buildLevelIcon(),
          SizedBox(width: 12.w),

          // Progress section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Level $level",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    // Info button
                    IconButton(
                      onPressed: () => _showLevelInfo(context),
                      icon: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.question_mark,
                          size: 10.w,
                          color: Colors.black,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      iconSize: 18.w,
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Progress bar
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.green.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                  minHeight: 8.h,
                  borderRadius: BorderRadius.circular(10.r),
                ),

                SizedBox(height: 8.h),

                // Points info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$currentPoints points",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "$remainingPoints points to Level ${level + 1}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelIcon() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          "$level",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  void _showLevelInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rider Levels',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelInfoItem('Level 1', '0-10 points', 'Beginner Rider'),
              _buildLevelInfoItem('Level 2', '11-30 points', 'Casual Rider'),
              _buildLevelInfoItem('Level 3', '31-60 points', 'Regular Rider'),
              _buildLevelInfoItem('Level 4', '61-100 points', 'Advanced Rider'),
              _buildLevelInfoItem('Level 5', '101-200 points', 'Pro Rider'),
              _buildLevelInfoItem('Level 6', '200+ points', 'Elite Rider'),
              SizedBox(height: 16.h),
              Text(
                'Earn points by completing rides, inviting friends, and being environmentally conscious!',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelInfoItem(String level, String points, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Center(
              child: Text(
                level.split(' ')[1],
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                points,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
