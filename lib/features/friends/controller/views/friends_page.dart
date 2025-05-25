import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/theme/app_theme.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/account/controllers/user_controller.dart';
import 'package:mjollnir/features/friends/controller/groups_controller.dart';
import 'package:mjollnir/shared/constants/colors.dart';

class FriendsPage extends StatelessWidget {
  FriendsPage({super.key});
  final TextEditingController _searchController = TextEditingController();
  final searchController = Get.put(CustomSearchController());
  final List<String> imgList = [
    'assets/company/banner.png',
    'assets/company/banner.png',
    'assets/company/banner.png',
  ];

  void _onSearchChanged(String value) {
    final userController = Get.find<UserController>();
    final groupController = Get.find<GroupController>();

    searchController.search(
      value,
      userController.getAllUsers.value?.data ?? [],
      groupController.allGroups ?? [],
    );
  }

  Future<void> _refreshData(UserController userController) async {
    await userController.getUsers();
    final groupController = Get.find<GroupController>();
    await groupController.allGroups.value;
    AppLogger.i("USERS => ${userController.getAllUsers.value?.toJson()}");
  }

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    final userController = Get.find<UserController>();
    Get.put(FilterController());
    groupController.getAlreadyJoinedGroups();
    final tabControllerX = Get.put(TabControllerX(), permanent: true);
    userController.getUsers();
    groupController.getGroups();
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshData(userController);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: true,
          maintainBottomViewPadding: true,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(10.h),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      SimpleSearchField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                      ),
                      SizedBox(height: 10.w),
                      CarouselWithIndicator(imgList: imgList),
                      SizedBox(height: 10.w),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  tabControllerX: tabControllerX,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                sliver: Obx(
                  () => tabControllerX.selectedIndex.value == 0
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                const Center(child: LeaderBoardList()),
                            childCount: 1,
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const Center(
                              child: ClubList(),
                            ),
                            childCount: 1,
                          ),
                        ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: kBottomNavigationBarHeight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabControllerX tabControllerX;
  _StickyTabBarDelegate({required this.tabControllerX});
  @override
  double get minExtent => 90.h;
  @override
  double get maxExtent => 90.h;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Obx(
            () => Container(
              width: ScreenUtil().screenWidth,
              height: 50.w,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.green, width: 1),
              ),
              child: Row(
                children: [
                  _buildTab(
                    context,
                    label: 'Athletes',
                    isSelected: tabControllerX.selectedIndex.value == 0,
                    onTap: () => tabControllerX.changeTab(0),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  _buildTab(
                    context,
                    label: 'Groups',
                    isSelected: tabControllerX.selectedIndex.value == 1,
                    onTap: () => tabControllerX.changeTab(1),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 7.w,
          ),
          Obx(() {
            final availableItems = tabControllerX.selectedIndex.value == 0
                ? const ['Pts']
                : const ['Pts', 'Km', 'Carbon'];

            final filterController = Get.find<FilterController>();

            if (!availableItems
                .contains(filterController.selectedValue.value)) {
              filterController.selectedValue.value = availableItems[0];
            }

            return SizedBox(
              child: CustomDropdown(
                items: availableItems,
                controller: filterController,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BorderRadius borderRadius,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50.w,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.green : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextThemes.bodySmall().copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
