import 'package:bolt_ui_kit/bolt_kit.dart' as BoltKit;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/friends/controller/follow_controller.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/group/group_models.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';
import 'package:mjollnir/shared/search/custom_search_controller.dart';

class SimpleSearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const SimpleSearchField({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<CustomSearchController>(
      builder: (searchController) {
        // Determine if we should show results
        final bool showResults = searchController.isSearching.value &&
            searchController.searchResults.isNotEmpty;

        return Container(
          // Add margin around the entire component
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          // Use a Stack to position the results below the search field
          child: Column(
            children: [
              // Search field with adjusted border radius when showing results
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // Only round the top corners when showing results
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10.r),
                    bottom: Radius.circular(showResults ? 0 : 10.r),
                  ),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    if (!showResults)
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: TextStyle(fontSize: 15.sp),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Search users or groups...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    // Add a subtle bottom divider when results are shown
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              // Search results - only visible when searching with results
              if (showResults)
                SearchResultsList(results: searchController.searchResults),
            ],
          ),
        );
      },
    );
  }
}

class SearchResultsList extends StatelessWidget {
  final List<dynamic> results;

  const SearchResultsList({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Container(
      // No top margin since we want to connect directly to search bar
      constraints: BoxConstraints(maxHeight: 300.h),
      decoration: BoxDecoration(
        color: Colors.white,
        // Only round the bottom corners
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(10.r),
        ),
        // Match the border with the search field
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
        // Add shadow at the bottom only
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          return SearchResultItem(item: item);
        },
      ),
    );
  }
}

class SearchResultItem extends StatelessWidget {
  final dynamic item;

  const SearchResultItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isUser = item is User;
    final String name =
        isUser ? (item as User).firstName : (item as AllGroup).name;
    final String type = isUser ? 'User' : 'Group';
    final followController = Get.find<FollowController>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.green.withOpacity(0.1),
          child: Icon(
            isUser ? Icons.person : Icons.group,
            color: AppColors.green,
          ),
        ),
        title: Text(
          name,
          style: BoltKit.AppTextThemes.bodyMedium().copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isUser
            ? Obx(() => followController.isLoading.value
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.green,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.person_add_outlined,
                      color: AppColors.green,
                    ),
                    onPressed: () {
                      followController.followUser(item.uid);
                    },
                  ))
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  type,
                  style: BoltKit.AppTextThemes.bodySmall().copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        onTap: () {
          if (isUser) {
            // NavigationService.pushTo(
            //   IndividualUserPage(
            //     name: (item as User).firstName,
            //     distance: (item as User).points.toString(),
            //   ),
            // );
          } else {
            // NavigationService.pushTo(
            //   GroupUserPage(
            //     name: (item as Group).name,
            //     id: (item as Group).id,
            //   ),
            // );
          }
        },
      ),
    );
  }
}
