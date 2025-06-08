import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  // Predefined avatar images - Cloudinary hosted URLs
  static const Map<String, String> predefinedAvatars = {
        'Avengers':'https://res.cloudinary.com/djyny0qqn/image/upload/v1749273812/icons8-avengers-480_v6dvmf.png',
    'Black Widow': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749272523/icons8-black-widow-480_gogwm9.png',
    'Spider-Man New': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749272532/icons8-spider-man-new-512_ct4cgf.png',
    'Spider-Man': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749272543/icons8-spider-man-500_b60vnv.png',
    'Iron Man': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749272554/icons8-iron-man-480_tt9icn.png',
    'Thanos': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749272612/icons8-thanos-480_m1vszd.png',
    'Groot': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749272621/icons8-groot-480_jg6zgw.png',
    'storm-marvel':'https://res.cloudinary.com/djyny0qqn/image/upload/v1749273781/icons8-storm-marvel-500_kuwc5z.png',
    'DeadPool':'https://res.cloudinary.com/djyny0qqn/image/upload/v1749273788/icons8-deadpool-480_wsac4a.png',
    'Magneto':'https://res.cloudinary.com/djyny0qqn/image/upload/v1749273796/icons8-magneto-480_ljsx5o.png',
    'Batman':'https://res.cloudinary.com/djyny0qqn/image/upload/v1749273801/icons8-batman-144_tpnasu.png',
    'Joker':'https://res.cloudinary.com/djyny0qqn/image/upload/v1749273806/icons8-joker-suicide-squad-240_gyxsg0.png',

  };

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
      // Check if it's a predefined avatar (asset image)
      if (imageUrl.value!.startsWith('assets/')) {
        return Image.asset(
          imageUrl.value!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: (size * 0.5).w,
              color: Colors.grey[400],
            );
          },
        );
      } else {
        // Network image
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
      }
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
              'Select Profile Picture',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Camera and Gallery options
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
            
            SizedBox(height: 20.h),
            
            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'or choose from avatars',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Predefined avatars grid
            Container(
              height: 120.h,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.w,
                  crossAxisSpacing: 8.h,
                  childAspectRatio: 1.0,
                ),
                itemCount: predefinedAvatars.length,
                itemBuilder: (context, index) {
                  String avatarName = predefinedAvatars.keys.elementAt(index);
                  String avatarUrl = predefinedAvatars.values.elementAt(index);
                  return _buildAvatarOption(avatarUrl, avatarName);
                },
              ),
            ),
            
            SizedBox(height: 16.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Builds an avatar option from predefined images
  Widget _buildAvatarOption(String avatarUrl, String avatarName) {
    return GestureDetector(
      onTap: () => _selectPredefinedAvatar(avatarUrl),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: imageUrl.value == avatarUrl 
                ? AppColors.primary 
                : Colors.grey[300]!,
            width: imageUrl.value == avatarUrl ? 3 : 1,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.person,
                  color: Colors.grey[400],
                  size: 30.w,
                ),
              );
            },
          ),
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

  /// Handles selecting a predefined avatar
  void _selectPredefinedAvatar(String avatarUrl) {
    Get.back(); // Close the bottom sheet
    imageUrl.value = avatarUrl;
    onImageSelected(avatarUrl); // Pass the URL directly
  }

  /// Handles picking an image from the specified source
  void _pickImage(ImageSource source) async {
    Get.back(); // Close the bottom sheet
    await onImageSelected(source);
  }

  /// Static method to check if a URL is a predefined avatar
  static bool isPredefinedAvatar(String? url) {
    return url != null && predefinedAvatars.containsValue(url);
  }

  /// Static method to get all predefined avatar URLs
  static List<String> getAllPredefinedAvatars() {
    return predefinedAvatars.values.toList();
  }
}