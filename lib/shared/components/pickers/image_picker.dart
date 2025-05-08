import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../../core/utils/logger.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? initialImage;
  final double size;
  final bool isProfilePicture;
  final String? placeholderText;

  const ImagePickerWidget({
    Key? key,
    this.initialImage,
    this.size = 120,
    this.isProfilePicture = true,
    this.placeholderText,
  }) : super(key: key);

  @override
  ImagePickerWidgetState createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      AppLogger.e("Error picking image", error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _showImageSourceOptions(context),
          child: Container(
            width: widget.size.w,
            height: widget.size.w,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: widget.isProfilePicture
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius:
                  !widget.isProfilePicture ? BorderRadius.circular(12.r) : null,
              border: Border.all(color: AppColors.primary, width: 2),
              image: selectedImage != null
                  ? DecorationImage(
                      image: FileImage(selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : widget.initialImage != null
                      ? DecorationImage(
                          image: NetworkImage(widget.initialImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: selectedImage == null && widget.initialImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isProfilePicture
                            ? Icons.person
                            : Icons.add_photo_alternate,
                        size: (widget.size / 3).w,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        widget.placeholderText ??
                            (widget.isProfilePicture
                                ? "Add Profile Photo"
                                : "Add Photo"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        if (selectedImage != null || widget.initialImage != null)
          TextButton.icon(
            onPressed: () => _showImageSourceOptions(context),
            icon: Icon(Icons.edit, size: 16.w),
            label: const Text("Change Photo"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
      ],
    );
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "Select Image Source",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (selectedImage != null || widget.initialImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Remove Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      selectedImage = null;
                    });
                  },
                ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }
}
