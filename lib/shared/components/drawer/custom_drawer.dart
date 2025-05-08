import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';
import '../buttons/app_button.dart';
import '../pickers/image_picker.dart';

class CustomDrawer extends StatelessWidget {
  final List<DrawerOption> options;
  final VoidCallback onCreateGroup;
  final VoidCallback onInviteFriends;

  const CustomDrawer({
    Key? key,
    required this.options,
    required this.onCreateGroup,
    required this.onInviteFriends,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...options.map((option) => _buildOptionItem(option)).toList(),
              SizedBox(height: 16.h),
              _buildCreateGroupCard(),
              SizedBox(height: 16.h),
              _buildInviteFriendsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(DrawerOption option) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.accent1,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ListTile(
        leading: Icon(
          option.icon,
          color: AppColors.primary,
        ),
        title: Text(
          option.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.w),
        onTap: option.onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  Widget _buildCreateGroupCard() {
    return AppCard(
      onTap: onCreateGroup,
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_add,
              color: AppColors.primary,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create a Group",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Connect with friends and ride together",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.w,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteFriendsCard() {
    return AppCard(
      onTap: onInviteFriends,
      backgroundColor: AppColors.accent1,
      child: Row(
        children: [
          Image.asset(
            'assets/images/add_friend.png',
            width: 40.w,
            height: 40.w,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Invite Friends',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Icon(
            Icons.share,
            size: 24.w,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class DrawerOption {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  DrawerOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

// Create Group Dialog
class CreateGroupDialog extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<ImagePickerWidgetState> imagePickerKey = GlobalKey();
  final Function(String name, String description, File? image) onSubmit;

  CreateGroupDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 500.w,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              SizedBox(height: 24.h),
              ImagePickerWidget(key: imagePickerKey),
              SizedBox(height: 24.h),
              _buildGroupNameField(),
              SizedBox(height: 16.h),
              _buildGroupDescriptionField(),
              SizedBox(height: 24.h),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.7), AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          'Create New Group',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupNameField() {
    return TextFormField(
      controller: nameController,
      decoration: InputDecoration(
        labelText: 'Group Name',
        hintText: 'Enter a name for your group',
        prefixIcon: Icon(Icons.group, color: AppColors.primary),
        labelStyle: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildGroupDescriptionField() {
    return TextFormField(
      controller: descriptionController,
      decoration: InputDecoration(
        labelText: 'Group Description',
        hintText: 'Tell others what your group is about',
        prefixIcon: Icon(Icons.description, color: AppColors.primary),
        labelStyle: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: 3,
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        AppButton(
          text: "Create Group",
          onPressed: () {
            final groupName = nameController.text;
            final groupDescription = descriptionController.text;
            final imageFile = imagePickerKey.currentState?.selectedImage;

            if (groupName.isEmpty) {
              Get.snackbar(
                'Error',
                'Group name cannot be empty',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }

            Navigator.pop(context);
            onSubmit(groupName, groupDescription, imageFile);
          },
          type: ButtonType.primary,
          fullWidth: true,
        ),
        SizedBox(height: 12.h),
        AppButton(
          text: "Cancel",
          onPressed: () => Navigator.pop(context),
          type: ButtonType.outline,
          fullWidth: true,
        ),
      ],
    );
  }
}
