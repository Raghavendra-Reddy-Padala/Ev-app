import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../models/search/search_result.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final Widget? prefix;
  final Widget? suffix;
  final List<SearchResult>? searchResults;
  final ValueChanged<SearchResult>? onResultTap;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    required this.onChanged,
    this.onClear,
    this.prefix,
    this.suffix,
    this.searchResults,
    this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    final RxBool showResults =
        RxBool(searchResults != null && searchResults!.isNotEmpty);

    return Obx(() {
      final bool showResultsList = showResults.value &&
          searchResults != null &&
          searchResults!.isNotEmpty;

      return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12.r),
                bottom: Radius.circular(showResultsList ? 0 : 12.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: (value) {
                onChanged(value);
                showResults.value =
                    searchResults != null && searchResults!.isNotEmpty;
              },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16.sp,
                ),
                prefixIcon:
                    prefix ?? Icon(Icons.search, color: AppColors.primary),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          controller.clear();
                          if (onClear != null) onClear!();
                          showResults.value = false;
                        },
                      )
                    : suffix,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              ),
            ),
          ),
          if (showResultsList) _buildSearchResults(),
        ],
      );
    });
  }

  Widget _buildSearchResults() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      constraints: BoxConstraints(maxHeight: 300.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        shrinkWrap: true,
        itemCount: searchResults!.length,
        itemBuilder: (context, index) {
          final result = searchResults![index];
          return ListTile(
            leading: result.icon ??
                Icon(
                  result.isUser ? Icons.person : Icons.place,
                  color: AppColors.primary,
                ),
            title: Text(
              result.title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: result.subtitle != null
                ? Text(
                    result.subtitle!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  )
                : null,
            trailing: result.trailing,
            onTap: () {
              if (onResultTap != null) {
                onResultTap!(result);
              }
            },
          );
        },
      ),
    );
  }
}
