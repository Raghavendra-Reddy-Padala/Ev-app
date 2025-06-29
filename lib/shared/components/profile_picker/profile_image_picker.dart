import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mjollnir/core/services/image_service.dart';
import '../../constants/colors.dart';
// Import your ImageService here
// import 'path_to_your_image_service.dart';

/// A reusable widget for picking and displaying profile images
class ProfileImagePicker extends StatefulWidget {
  final Rx<String?> imageUrl;
  final Function onImageSelected;
  final double size;
  final bool showLabel;
  final String label;
  final ImageType imageType; // Add this parameter

  const ProfileImagePicker({
    Key? key,
    required this.imageUrl,
    required this.onImageSelected,
    this.size = 120,
    this.showLabel = true,
    this.label = 'Upload Profile Picture',
    this.imageType = ImageType.avatar, // Default to avatar
  }) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  bool _isUploading = false;

  // Predefined avatar images - Cloudinary hosted URLs
  static const Map<String, String> predefinedAvatars = {
    'Avengers': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749474061/475409-3840x2160-desktop-4k-mjolnir-thor-background_sy9bik.jpg',
    'Black Widow': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473989/476112-3840x2160-desktop-4k-valkyrie-thor-wallpaper_wzetqs.jpg',
    'Spider-Man New': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749474051/37391-3840x2160-desktop-4k-venom-background-image_tvehbk.jpg',
    'Spider-Man': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749474048/51983-1920x1080-desktop-full-hd-loki-background_izkwel.jpg',
    'Iron Man': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749474046/79564-3840x2160-desktop-4k-hulk-background-photo_nifdrh.jpg',
    'Thanos': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749474043/453718-1080x1920-iphone-1080p-nanaue-king-shark-wallpaper_aln7m0.jpg',
    'Groot': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749474040/325932-3840x2160-desktop-4k-wonder-woman-movie-background_kidhec.jpg',
    'storm-marvel': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749474028/486909-3840x2160-desktop-4k-tony-stark-iron-man-background-image_bdt1xu.jpg',
    'DeadPool': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749474006/475525-3840x2160-desktop-4k-mjolnir-thor-wallpaper_bl9rvh.jpg',
    'Magneto': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749474000/475892-1125x2436-samsung-hd-heimdall-thor-background_wxvp9u.jpg',
    'Batman': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473994/475857-1125x2436-iphone-hd-hela-thor-wallpaper-photo_ycjt4k.jpg',
    'Joker': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473991/475721-1920x1080-desktop-1080p-hela-thor-wallpaper-photo_ioxzil.jpg',
    'a': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473984/Untitled_design-15_ezndnm.png',
    'b': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473981/Untitled_design-16_ptodd9.png',
    'c': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473978/Untitled_design_pptozx.png',
    'd': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473977/Untitled_design-18_rvjidz.png',
    'e': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473974/Untitled_design-14_jgsuia.png',
    'f': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473971/Untitled_design-10_scipkm.png',
    'g': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473963/Untitled_design-5_cpp6sc.png',
    'h': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473957/Untitled_design-8_qcxsen.png',
    'i': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473960/Untitled_design-9_nddt2w.png',
    'j': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473953/Untitled_design-4_rbjo2r.png',
    'k': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473950/Untitled_design-3_evvd0h.png',
    'l': 'https://res.cloudinary.com/djyny0qqn/image/upload/v1749473947/Untitled_design-2_ams8zg.png'
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Obx(() => GestureDetector(
              onTap: _isUploading ? null : _showImageSourceOptions,
              child: Stack(
                children: [
                  Container(
                    width: widget.size.w,
                    height: widget.size.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: _isUploading
                          ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : _buildProfileImage(),
                    ),
                  ),
                  if (!_isUploading)
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
        if (widget.showLabel) ...[
          SizedBox(height: 8.h),
          Text(
            _isUploading ? 'Uploading...' : widget.label,
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
    if (widget.imageUrl.value != null && widget.imageUrl.value!.isNotEmpty) {
      // Check if it's a predefined avatar (asset image)
      if (widget.imageUrl.value!.startsWith('assets/')) {
        return Image.asset(
          widget.imageUrl.value!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: (widget.size * 0.5).w,
              color: Colors.grey[400],
            );
          },
        );
      } else {
        // Network image
        return Image.network(
          widget.imageUrl.value!,
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
              size: (widget.size * 0.5).w,
              color: Colors.grey[400],
            );
          },
        );
      }
    } else {
      return Icon(
        Icons.person,
        size: (widget.size * 0.5).w,
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
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickAndUploadImage(ImageSource.camera),
                ),
                _buildSourceOption(
                  icon: Icons.image,
                  label: 'Gallery',
                  onTap: () => _pickAndUploadImage(ImageSource.gallery),
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
            color: widget.imageUrl.value == avatarUrl 
                ? AppColors.primary 
                : Colors.grey[300]!,
            width: widget.imageUrl.value == avatarUrl ? 3 : 1,
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
    widget.imageUrl.value = avatarUrl;
    widget.onImageSelected(avatarUrl); // Pass the URL directly
  }

  /// NEW: This method uses ImageService to pick and upload images
  void _pickAndUploadImage(ImageSource source) async {
    try {
      Get.back(); // Close the bottom sheet first
      
      setState(() {
        _isUploading = true;
      });

      // Use your ImageService to pick and upload image
      String? uploadedImageUrl = await ImageService.pickAndUploadImage(
        type: widget.imageType,
        source: source,
      );

      if (uploadedImageUrl != null) {
        // Update the imageUrl with the uploaded URL
        widget.imageUrl.value = uploadedImageUrl;
        // Call the callback with the uploaded URL
        widget.onImageSelected(uploadedImageUrl);
        
        Get.snackbar(
          'Success',
          'Image uploaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to upload image. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  static bool isPredefinedAvatar(String? url) {
    return url != null && predefinedAvatars.containsValue(url);
  }

  static List<String> getAllPredefinedAvatars() {
    return predefinedAvatars.values.toList();
  }
}