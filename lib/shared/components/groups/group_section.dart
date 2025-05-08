import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../features/friends/controller/groups_controller.dart';
import '../../constants/colors.dart';

class GroupProfileHeader extends StatelessWidget {
  final String name;
  final String groupId;
  final String? imageUrl;

  const GroupProfileHeader({
    super.key,
    required this.name,
    required this.groupId,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupController.fetchGroupAggregate(groupId);
    });

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildGroupImage(),
          SizedBox(width: 16.w),
          Expanded(
            child: Obx(() => _buildGroupDetails(groupController)),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupImage() {
    return Container(
      width: 90.w,
      height: 90.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Icon(
              Icons.group_rounded,
              size: 45.w,
              color: Colors.grey[600],
            )
          : null,
    );
  }

  Widget _buildGroupDetails(GroupController groupController) {
    final aggregateData = groupController.groupAggregateData.value;
    final totalKm = aggregateData?.totalKm.toStringAsFixed(1) ?? '0';
    final totalPoints = aggregateData?.totalPoints.toString() ?? '0';
    final membersCount = aggregateData?.noOfUsers.toString() ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _buildMetricBadge(
              "$totalKm km",
              AppColors.primary,
            ),
            SizedBox(width: 8.w),
            _buildMetricBadge(
              "$totalPoints points",
              AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _buildMetricBadge(
          "$membersCount Members",
          Colors.black,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildMetricBadge(String text, Color color, {bool isWide = false}) {
    return Container(
      constraints: isWide ? BoxConstraints(minWidth: 120.w) : null,
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        textAlign: isWide ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}
