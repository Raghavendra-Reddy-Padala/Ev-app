import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/image_service.dart';
import '../../constants/colors.dart';

/// A reusable widget for picking and displaying profile images
class ProfileImagePicker extends StatelessWidget {
  final Rx<String?> imageUrl;
  final Function onImageSelected;
  final double size;
  final bool showLabel;
  final String label;

  const ProfileImagePicker({
    Key? key,
    required this.imageUrl,
    required this.onImageSelected,
    this.size = 120,
    this.showLabel = true,
    this.label = 'Upload Profile Picture',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Obx(() => GestureDetector(
              onTap: _showImageSourceOptions,
              child: Stack(
                children: [
                  Container(
                    width: size.w,
                    height: size.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: _buildProfileImage(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        if (showLabel) ...[
          SizedBox(height: 8.h),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the profile image widget based on the current imageUrl
  Widget _buildProfileImage() {
    if (imageUrl.value != null && imageUrl.value!.isNotEmpty) {
      return Image.network(
        imageUrl.value!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: (size * 0.5).w,
            color: Colors.grey[400],
          );
        },
      );
    } else {
      return Icon(
        Icons.person,
        size: (size * 0.5).w,
        color: Colors.grey[400],
      );
    }
  }

  /// Shows a bottom sheet with options for selecting an image source
  void _showImageSourceOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: Get.textTheme.titleMedium,
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildSourceOption(
                  icon: Icons.image,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  /// Builds an option button for the image source selector
  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 30.w,
            ),
          ),
          SizedBox(height: 8.h),
          Text(label),
        ],
      ),
    );
  }

  /// Handles picking an image from the specified source
  void _pickImage(ImageSource source) async {
    Get.back(); // Close the bottom sheet
    await onImageSelected(source);
  }
}
