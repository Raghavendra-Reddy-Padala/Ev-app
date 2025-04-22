import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/filter_controller.dart';
import '../../../data/models/social_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme.dart';

class ClubCard extends StatelessWidget {
  final Group club;
  const ClubCard({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<GroupController>();

    return GestureDetector(
      onTap: () => _onCardTap(),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 8,
        color: EVColors.offwhite,
        child: Padding(
          padding: EdgeInsets.all(10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClubHeader(club: club),
              SizedBox(width: 10.h),
              StatsRow(club: club),
              JoinButton(club: club),
            ],
          ),
        ),
      ),
    );
  }

  void _onCardTap() {
    NavigationService.pushTo(
      GroupUserPage(name: club.name, id: club.id),
    );
  }
}

class ClubHeader extends StatelessWidget {
  final Group club;
  const ClubHeader({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 5),
        _buildAvatar(),
        const SizedBox(width: 5),
        _buildClubInfo(),
      ],
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 15,
      backgroundColor: EVColors.green,
      backgroundImage: const AssetImage('assets/images/club.png'),
    );
  }

  Widget _buildClubInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: ScreenUtil().screenWidth / 2 - 105.w,
          height: 15.h,
          child: Text(
            club.name,
            style: CustomTextTheme.bodyMediumPBold
                .copyWith(fontSize: 11.sp, color: Colors.black),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: SizedBox(
            width: 80.w,
            height: 20.w,
            child: Text(
              club.description,
              style: CustomTextTheme.bodySmallP.copyWith(
                fontSize: 7.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                overflow: TextOverflow.clip,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatsRow extends StatelessWidget {
  final Group club;
  const StatsRow({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    final FilterController filterController = Get.find<FilterController>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        String currentFilter = filterController.selectedValue.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatItem(
              label: 'Pts',
              value: club.aggregatedData?.totalPoints ?? club.totalTrips,
              isHighlighted: currentFilter == 'Pts',
            ),
            _StatItem(
              label: 'Km',
              value: (club.aggregatedData?.totalKm ?? club.totalDistance)
                  .toStringAsFixed(1),
              isHighlighted: currentFilter == 'Km',
            ),
            _StatItem(
              label: 'speed',
              value: (club.aggregatedData?.totalCarbon ??
                      (club.averageSpeed / 1000))
                  .toStringAsFixed(1),
              isHighlighted: currentFilter == 'Carbon',
            ),
          ],
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool isHighlighted;

  const _StatItem({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Text(
            label.toString(),
            style: _getTextStyle(isHighlighted),
          ),
          Text(
            value.toString(),
            style: _getValueStyle(isHighlighted),
          )
        ],
      ),
    );
  }

  TextStyle _getTextStyle(bool isHighlighted) {
    return CustomTextTheme.bodySmallXPBold.copyWith(
      fontSize: 9.sp,
      color: isHighlighted ? EVColors.green : Colors.black,
      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
    );
  }

  TextStyle _getValueStyle(bool isHighlighted) {
    return CustomTextTheme.bodySmallXPBold.copyWith(
      fontSize: 9.sp,
      color: isHighlighted ? EVColors.green : Colors.grey.shade700,
      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
    );
  }
}

class JoinButton extends StatelessWidget {
  final Group club;
  const JoinButton({required this.club, super.key});

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    final userId = Get.find<UserController>().userData.value?.data.uid;
    final bool isCreator = club.createdBy == userId;

    return Obx(() {
      final bool isJoined = _isUserJoinedGroup(groupController);

      return ElevatedButton(
        onPressed:
            isJoined || isCreator ? null : () => _joinGroup(groupController),
        style: _getButtonStyle(isCreator, isJoined),
        child: Center(
          child: Text(
            _getButtonText(isCreator, isJoined),
            style: CustomTextTheme.bodySmallPBold.copyWith(
              fontSize: 12.sp,
              color: EVColors.white,
            ),
          ),
        ),
      );
    });
  }

  bool _isUserJoinedGroup(GroupController controller) {
    return controller.joined_groups
        .any((joined) => joined.id.toString() == club.id);
  }

  Future<void> _joinGroup(GroupController controller) async {
    await controller.joinGroup(club.id);
    controller.getAlreadyJoinedGroups();
  }

  ButtonStyle _getButtonStyle(bool isCreator, bool isJoined) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      fixedSize: WidgetStateProperty.all(Size(130.w, 20.w)),
      backgroundColor: WidgetStateProperty.all(
        isCreator ? Colors.blue : (isJoined ? Colors.grey : EVColors.green),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _getButtonText(bool isCreator, bool isJoined) {
    if (isCreator) return 'My Club';
    if (isJoined) return 'Already Joined';
    return 'Join';
  }
}
