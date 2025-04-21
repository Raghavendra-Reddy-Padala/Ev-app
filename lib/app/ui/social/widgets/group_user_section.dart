import 'package:flutter/material.dart';

class GroupUserSection extends StatelessWidget {
  final String name;
  final String groupId;

  const GroupUserSection(
      {super.key, required this.name, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth * 0.9,
      height: ScreenUtil().screenHeight * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _GroupImage(),
          _GroupDetails(name: name, groupId: groupId),
          SizedBox(width: ScreenUtil().screenWidth * 0.1),
        ],
      ),
    );
  }
}

class _GroupImage extends StatelessWidget {
  const _GroupImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth * 0.3,
      height: ScreenUtil().screenHeight * 0.1,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: Image.asset('assets/images/default_pfp.png'),
    );
  }
}

class _GroupDetails extends StatelessWidget {
  final String name;
  final String groupId;

  const _GroupDetails({required this.name, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();
    final double containerWidth = (ScreenUtil().screenWidth * 0.5) - 35.w;

    // Fetch group data when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupController.fetchGroupAggregate(groupId);
    });

    return Obx(() {
      final aggregateData = groupController.groupAggregateData.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: CustomTextTheme.bodyLargePBold.copyWith(
              color: Colors.black,
            ),
          ),
          _buildMetricsRow(containerWidth, aggregateData),
          const SizedBox(height: 5),
          _buildFollowersRow(containerWidth, aggregateData),
        ],
      );
    });
  }

  Widget _buildMetricsRow(double containerWidth, dynamic aggregateData) {
    return Row(
      children: [
        _ContainerHelper(
          text: "\${aggregateData?.totalKm?.toStringAsFixed(1) ?? '0'} kms",
          color: EVColors.primary,
          width: containerWidth / 2,
        ),
        const SizedBox(width: 5),
        _ContainerHelper(
          text: "\${aggregateData?.totalPoints ?? '0'} points",
          color: EVColors.primary,
          width: containerWidth / 2,
        ),
      ],
    );
  }

  Widget _buildFollowersRow(double containerWidth, dynamic aggregateData) {
    return _FollowerTab(
      text: "\${aggregateData?.noOfUsers ?? '0'} Followers",
      color: Colors.black,
      width: containerWidth,
    );
  }
}

class _ContainerHelper extends StatelessWidget {
  final Color color;
  final String text;
  final double width;

  const _ContainerHelper(
      {required this.text, required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          ScreenUtil().screenWidth * 0.04,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().screenWidth * 0.02,
        vertical: ScreenUtil().screenWidth * 0.01,
      ),
      child: Text(
        text,
        style: CustomTextTheme.bodySmallI.copyWith(color: Colors.white),
      ),
    );
  }
}

class _FollowerTab extends StatelessWidget {
  final Color color;
  final String text;
  final double width;

  const _FollowerTab(
      {required this.text, required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ScreenUtil().screenWidth * 0.04),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().screenWidth * 0.02,
        vertical: ScreenUtil().screenWidth * 0.01,
      ),
      child: Center(
        child: Text(
          text,
          style: CustomTextTheme.bodySmallI.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
