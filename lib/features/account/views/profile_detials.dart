import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/profile_controller.dart';
import 'package:mjollnir/features/account/views/editprofile.dart';
import 'package:mjollnir/features/authentication/controller/auth_controller.dart';
import 'package:mjollnir/features/authentication/views/login_view.dart';
import 'package:mjollnir/shared/components/header/header.dart';

class Profiledetails extends StatelessWidget {
  const Profiledetails({super.key});

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm Logout"),
              content: Text("Are you sure you want to log out?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Logout"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40.h),
        child: Header(heading: 'Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: const _UI(),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 70.h,
        width: ScreenUtil().screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          onPressed: () async {
            bool shouldLogout = await _showLogoutConfirmationDialog(context);
            if (shouldLogout) {
              authController.logout();
                   !Get.currentRoute.contains('/login');
            }
          },
          child: Text(
            'Logout',
            style: AppTextThemes.bodyMedium().copyWith(
              color: Colors.white,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _UI extends StatelessWidget {
  const _UI();

  @override
  Widget build(BuildContext context) {
    final ProfileController userController = Get.find<ProfileController>();
    userController.fetchUserDetails();

    return Obx(() => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              _buildProfileBanner(userController, context),
              SizedBox(height: 25.h),
              Text(
                "Personal Information",
                style: AppTextThemes.bodyMedium().copyWith(
                  fontSize: 18.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 15.h),
              _buildProfileDetails(userController, context),
              SizedBox(height: 100.h),
            ],
          ),
        ));
  }

  Widget _buildProfileBanner(
      ProfileController userController, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage( "https://res.cloudinary.com/djyny0qqn/image/upload/v1749388344/ChatGPT_Image_Jun_8_2025_05_27_53_PM_nu0zjs.png"),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.primary.withOpacity(1),
        //     offset: const Offset(0, 5),
        //   ),
        // ],
      ),
      child: userController.isLoading.value
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 60.h,
                    width: 60.w,
                    child: CircularProgressIndicator(
                      color: AppColors.lightBackground,
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Loading profile...',
                    style: AppTextThemes.bodyMedium().copyWith(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45.r,
                    backgroundColor: Colors.black,
                    child: userController
                                .userData.value?.data.avatar?.isNotEmpty ==
                            true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(45.r),
                            child: Image.network(
                              userController.userData.value!.data.avatar!,
                              fit: BoxFit.cover,
                              height: 90.r,
                              width: 90.r,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/user_img.png',
                                  height: 90.r,
                                  width: 90.r,
                                  fit: BoxFit.cover,
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          )
                        : Image.asset(
                            'assets/images/user_img.png',
                            height: 65.r,
                            width: 65.r,
                          ),
                  ),
                ),
                Spacer(),
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         userController.userData.value?.data.firstName
                //                     ?.isNotEmpty ==
                //                 true
                //             ? userController.userData.value!.data.firstName!
                //             : "User",
                //         style: AppTextThemes.bodyMedium().copyWith(
                //           fontSize: 24.sp,
                //           color: Colors.black,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       SizedBox(height: 5.h),
                //       Text(
                //         userController.userData.value?.data.email?.isNotEmpty ==
                //                 true
                //             ? userController.userData.value!.data.email!
                //             : "user@example.com",
                //         style: AppTextThemes.bodySmall().copyWith(
                //           fontSize: 14.sp,
                //           color: Colors.black,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => EditProfileView());
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileDetails(
      ProfileController userController, BuildContext context) {
    if (userController.isLoading.value) {
      return Container(
        height: ScreenUtil().screenHeight * 0.3,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 10.h),
            Text(
              'Fetching user details...',
              style: AppTextThemes.bodySmall().copyWith(color: Colors.black),
            ),
          ],
        ),
      );
    } else if (userController.userData.value == null) {
      return Container(
        height: ScreenUtil().screenHeight * 0.3,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48.r),
            SizedBox(height: 15.h),
            Text(
              'Unable to load data',
              style: AppTextThemes.bodyMedium().copyWith(
                color: Colors.red,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
              onPressed: () => userController.fetchUserDetails(),
              label: Text(
                'Retry',
                style: AppTextThemes.bodyMedium().copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      final userData = userController.userData.value!.data;
      final displayFields = <Map<String, dynamic>>[];

      if (userData.email.isNotEmpty) {
        displayFields.add({
          'key': 'Name',
          'value': "${userData.firstName} " "${userData.lastName}",
          'icon': Icons.account_circle
        });
      }
      if (userData.phone.isNotEmpty) {
        displayFields.add(
            {'key': 'Phone', 'value': userData.phone, 'icon': Icons.phone});
      }
      if (userData.email.isNotEmpty) {
        displayFields.add(
            {'key': 'Email', 'value': userData.email, 'icon': Icons.email});
      }

      // if (userData.college.isNotEmpty) {
      //   displayFields.add({'key': 'College', 'value': userData.college, 'icon': Icons.school});
      // }
      // if (userData.dateOfBirth.isNotEmpty) {
      //   displayFields.add({'key': 'Date of Birth', 'value': userData.dateOfBirth, 'icon': Icons.calendar_today});
      // }
      if (userData.type.isNotEmpty) {
        displayFields.add(
            {'key': 'Type', 'value': userData.type, 'icon': Icons.category});
      }
      // if (userData.studentId.isNotEmpty) {
      //   displayFields.add({'key': 'Student ID', 'value': userData.studentId, 'icon': Icons.badge});
      // }
      // if (userData.employeeId?.isNotEmpty == true) {
      //   displayFields.add({'key': 'Employee ID', 'value': userData.employeeId!, 'icon': Icons.badge});
      // }
      // if (userData.company?.isNotEmpty == true) {
      //   displayFields.add({'key': 'Company', 'value': userData.company!, 'icon': Icons.business});
      // }
      // if (userData.age > 0) {
      //   displayFields.add({'key': 'Age', 'value': userData.age.toString(), 'icon': Icons.cake});
      // }
      if (userData.height > 0) {
        displayFields.add({
          'key': 'Height',
          'value': '${userData.height} cm',
          'icon': Icons.height
        });
      }
      if (userData.weight > 0) {
        displayFields.add({
          'key': 'Weight',
          'value': '${userData.weight} kg',
          'icon': Icons.monitor_weight
        });
      }
      // if (userData.points > 0) {
      //   displayFields.add({'key': 'Points', 'value': userData.points.toString(), 'icon': Icons.stars});
      // }
      // if (userData.trips > 0) {gro
      // if (userData.distance > 0) {
      //   displayFields.add({'key': 'Distance', 'value': '${userData.distance} km', 'icon': Icons.route});
      // }
      // if (userData.followers > 0) {
      //   displayFields.add({'key': 'Followers', 'value': userData.followers.toString(), 'icon': Icons.people});
      // }
      if (userData.gender.isNotEmpty) {
        displayFields.add(
            {'key': 'Gender', 'value': userData.gender, 'icon': Icons.group});
      }

      return Column(
        children: [
          for (var field in displayFields)
            _buildDetailCard(
              field['key'] as String,
              field['value'] as String,
              field['icon'] as IconData,
            ),
        ],
      );
    }
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20.r,
          ),
        ),
        title: Text(
          title,
          style: AppTextThemes.bodySmall().copyWith(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: AppTextThemes.bodyMedium().copyWith(
            fontSize: 16.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }
}
