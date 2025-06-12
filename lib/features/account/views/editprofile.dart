import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/services/image_service.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/account/controllers/profile_controller.dart';
import 'package:mjollnir/main.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/constants/colors.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});
  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorage localStorage = Get.find<LocalStorage>();

  final Map<String, dynamic> _formData = {};
  final ProfileController userController = Get.find<ProfileController>();
  bool _isLoading = false;
  bool _isAvatarLoading = false;
  bool _isBannerLoading = false;

  @override
  void initState() {
    super.initState();
    if (userController.userData.value != null) {
      _formData['first_name'] = userController.userData.value!.data.firstName;
      _formData['last_name'] = userController.userData.value!.data.lastName;
      _formData['date_of_birth'] =
          userController.userData.value!.data.dateOfBirth;

      _formData['email'] = userController.userData.value!.data.email;

      _formData['weight'] = userController.userData.value!.data.weight ?? '';
      _formData['height'] = userController.userData.value!.data.height ?? '';

      _formData['address_line'] =
          userController.userData.value!.data.addressLine ?? '';
      _formData['city'] = userController.userData.value!.data.city ?? '';
      _formData['state'] = userController.userData.value!.data.state ?? '';
      _formData['pincode'] = userController.userData.value!.data.pincode ?? '';
      _formData['country'] = userController.userData.value!.data.country ?? '';
      _formData['avatar'] = userController.userData.value!.data.avatar;
      _formData['banner'] = userController.userData.value!.data.banner ??
          'https://res.cloudinary.com/djyny0qqn/image/upload/v1749388344/ChatGPT_Image_Jun_8_2025_05_27_53_PM_nu0zjs.png';

      _formData['uid'] = userController.userData.value!.data.uid ?? '';
      _formData['phone'] = userController.userData.value!.data.phone ?? '';
      _formData['type'] = userController.userData.value!.data.type ?? '';
      _formData['TableName'] = '';
      _formData['points'] = userController.userData.value!.data.points ?? 0;
      _formData['password'] = 'abcd';
      _formData['employee_id'] =
          userController.userData.value!.data.employeeId ?? '';
      _formData['company'] = userController.userData.value!.data.company ?? '';
      _formData['college'] = userController.userData.value!.data.college ?? '';
      _formData['student_id'] =
          userController.userData.value!.data.studentId ?? '';
      _formData['age'] =
          userController.userData.value!.data.age.toString() ?? '';
      _formData['gender'] = userController.userData.value!.data.gender ?? '';
      _formData['invite_code'] =
          userController.userData.value!.data.inviteCode ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final token = await getToken();
        if (token == null) return;

        final userData = userController.userData.value!.data;

        final Map<String, dynamic> jsonData = {
          'TableName': ' ',
          'uid': userData.uid ?? ' ',
          'password': 'abcd',
          'type': userData.type ?? '  ',
          'employee_id': userData.employeeId ?? '  ',
          'company': userData.company ?? ' ',
          'college': userData.college ?? ' ',
          'student_id': userData.studentId ?? ' ',
          'age': userData.age.toString() ?? '',
          'points': userData.points ?? 0,
          'invite_code': userData.inviteCode ?? '',
          'gender': userData.gender,
          'first_name': _formData['first_name'],
          'last_name': _formData['last_name'],
          'date_of_birth': _formData['date_of_birth'],
          'weight': _formData['weight']?.toString() ?? '',
          'height': _formData['height']?.toString() ?? '',
          'weight_units': _formData['weight_units'] ?? 'kg',
          'height_units': _formData['height_units'] ?? 'cm',
          'address_line': _formData['address_line'] ?? '',
          'city': _formData['city'] ?? '',
          'state': _formData['state'] ?? '',
          'pincode': _formData['pincode'] ?? '',
          'country': _formData['country'] ?? '',
          'avatar': _formData['avatar'] ?? '',
          'banner': _formData['banner'] ?? '',
          'created_at': userData.createdAt ?? '',
        };

        jsonData.removeWhere((key, value) => value == null);

        AppLogger.i(jsonData.toString());
        AppLogger.i('${ApiConstants.baseUrl}/user/update');

        final response = await apiService.post(
          endpoint: 'user/update',
          body: jsonData,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'X-Karma-App': 'dafjcnalnsjn',
          },
        );

        AppLogger.i('Response received');
        AppLogger.i('Response body: ${response.toString()}');

        if (response != null && response['success'] == true) {
          await userController.fetchUserDetails();
          _showSnackBar('Profile updated successfully', Colors.green);
          Navigator.pop(context);
        } else {
          throw Exception(
              'Failed to update profile: ${response?['message'] ?? 'Unknown error'}');
        }
      } catch (e) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
        AppLogger.e(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextThemes.bodySmall().copyWith(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    setState(() {
      _isAvatarLoading = true;
    });

    try {
      final url = await ImageService.pickAndUploadImage(type: ImageType.avatar);
      if (url != null) {
        setState(() {
          _formData['avatar'] = url;
        });
        _showSnackBar('Profile picture updated', AppColors.primary);
      }
    } catch (e) {
      _showSnackBar('Failed to upload avatar: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isAvatarLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadBanner() async {
    setState(() {
      _isBannerLoading = true;
    });

    try {
      final url = await ImageService.pickAndUploadImage(type: ImageType.banner);
      if (url != null) {
        setState(() {
          _formData['banner'] = url;
        });
        _showSnackBar('Banner image updated', AppColors.primary);
      }
    } catch (e) {
      _showSnackBar('Failed to upload banner: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isBannerLoading = false;
      });
    }
  }

  Future<String?> getToken() async {
    return localStorage.getToken();
  }

  Widget _buildTextField(String label, String key,
      {String? initialValue,
      TextInputType? keyboardType,
      bool obscure = false,
      String? suffix}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        initialValue: initialValue ?? _formData[key]?.toString() ?? '',
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          labelStyle: AppTextThemes.bodySmall().copyWith(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.offwhite,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
        style: AppTextThemes.bodyMedium().copyWith(color: Colors.black87),
        validator: (value) {
          if (key == 'email' && (value == null || value.isEmpty)) {
            return 'Email is required';
          }
          if (key == 'first_name' && (value == null || value.isEmpty)) {
            return 'First name is required';
          }
          if (key == 'last_name' && (value == null || value.isEmpty)) {
            return 'Last name is required';
          }
          if (key == 'email' && value != null && value.isNotEmpty) {
            if (!value.contains('@') || !value.contains('.')) {
              return 'Please enter a valid email';
            }
          }
          if (key == 'weight' && value != null && value.isNotEmpty) {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid weight';
            }
          }
          if (key == 'height' && value != null && value.isNotEmpty) {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid height';
            }
          }
          return null;
        },
        onSaved: (value) {
          if (value != null) {
            _formData[key] = value;
          }
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, String key, List<String> options) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: DropdownButtonFormField<String>(
        value: _formData[key]?.toString().isNotEmpty == true
            ? _formData[key].toString()
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextThemes.bodySmall().copyWith(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.offwhite,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
        style: AppTextThemes.bodyMedium().copyWith(color: Colors.black87),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _formData[key] = newValue;
          });
        },
        onSaved: (value) {
          if (value != null) {
            _formData[key] = value;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40.h),
        child: Header(heading: 'Edit Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildBannerWithProfileSection(),
                        SizedBox(height: 90.h),
                        _buildPersonalInfoSection(),
                        SizedBox(height: 24.h),
                        _buildContactInfoSection(),
                        SizedBox(height: 24.h),
                        _buildPhysicalInfoSection(),
                        SizedBox(height: 24.h),
                        _buildAddressInfoSection(),
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: SizedBox(
          height: 56.h,
          width: ScreenUtil().screenWidth,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isLoading ? null : _updateProfile,
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Updating...',
                        style: AppTextThemes.bodyMedium().copyWith(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Update Profile',
                    style: AppTextThemes.bodyMedium().copyWith(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerWithProfileSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner Section
        _buildBannerSection(),
        // Profile Photo Section - Positioned to overlap banner
        Positioned(
          bottom: -60.h, // Half the profile photo height
          left: 0,
          right: 0,
          child: _buildProfilePhotoSection(),
        ),
      ],
    );
  }

  Widget _buildBannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            'Banner Image',
            style: AppTextThemes.bodyLarge().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.offwhite,
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(
                        _formData['banner'] != null &&
                                _formData['banner'].toString().isNotEmpty
                            ? _formData['banner'].toString()
                            : 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749388344/ChatGPT_Image_Jun_8_2025_05_27_53_PM_nu0zjs.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (_isBannerLoading)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isBannerLoading ? null : _pickAndUploadBanner,
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 136.w,
            height: 136.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Profile Photo
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isAvatarLoading
                      ? CircleAvatar(
                          radius: 60.r,
                          backgroundColor: AppColors.offwhite,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        )
                      : CircleAvatar(
                          radius: 60.r,
                          backgroundColor: AppColors.offwhite,
                          backgroundImage: _formData['avatar'] != null &&
                                  _formData['avatar'].toString().isNotEmpty
                              ? NetworkImage(_formData['avatar'].toString())
                              : const AssetImage('assets/images/user_img.png')
                                  as ImageProvider,
                        ),
                ),
                // Camera Icon - Positioned with proper touch handling
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isAvatarLoading ? null : _pickAndUploadAvatar,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Profile Photo',
            style: AppTextThemes.bodyMedium().copyWith(
              color: Colors.black54,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            'Personal Information',
            style: AppTextThemes.bodyLarge().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildTextField('First Name', 'first_name'),
                _buildTextField('Last Name', 'last_name'),
                _buildTextField('Date of Birth (DD/MM/YYYY)', 'date_of_birth'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            'Contact Information',
            style: AppTextThemes.bodyLarge().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildTextField('Email', 'email',
                    keyboardType: TextInputType.emailAddress),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            'Physical Information',
            style: AppTextThemes.bodyLarge().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField('Weight', 'weight',
                          keyboardType: TextInputType.number),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 1,
                      child: _buildDropdownField(
                          'Unit', 'weight_units', ['kg', 'lbs']),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField('Height', 'height',
                          keyboardType: TextInputType.number),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 1,
                      child: _buildDropdownField(
                          'Unit', 'height_units', ['cm', 'ft']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            'Address Information',
            style: AppTextThemes.bodyLarge().copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildTextField('Address Line', 'address_line'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('City', 'city'),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField('State', 'state'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Pincode', 'pincode',
                          keyboardType: TextInputType.number),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField('Country', 'country'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
