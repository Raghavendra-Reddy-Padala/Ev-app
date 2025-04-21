import 'package:flutter/material.dart';

class GroupDialogHelper {
  static void showCreateGroupDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final imageKey = GlobalKey<ImagePickerWidgetState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: 500.w,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogHeader(),
                  SizedBox(height: 20.h),
                  ImagePickerWidget(key: imageKey),
                  SizedBox(height: 20.h),
                  _buildNameField(nameController),
                  SizedBox(height: 16.h),
                  _buildDescriptionField(descriptionController),
                  SizedBox(height: 20.h),
                  _buildActionButtons(
                      context, nameController, descriptionController, imageKey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDialogHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EVColors.primary.withOpacity(0.7), EVColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
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

  static Widget _buildNameField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Group Name',
        hintText: 'Enter a name for your group',
        prefixIcon: Icon(Icons.group, color: EVColors.primary),
        labelStyle: const TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: EVColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  static Widget _buildDescriptionField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Group Description',
        hintText: 'Tell others what your group is about',
        prefixIcon: Icon(Icons.description, color: EVColors.primary),
        labelStyle: const TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: EVColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  static Widget _buildActionButtons(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController descriptionController,
      GlobalKey<ImagePickerWidgetState> imageKey) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          _buildCreateButton(
              context, nameController, descriptionController, imageKey),
          SizedBox(height: 10.h),
          _buildCancelButton(context),
        ],
      ),
    );
  }

  static Widget _buildCreateButton(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController descriptionController,
      GlobalKey<ImagePickerWidgetState> imageKey) {
    return ElevatedButton(
      onPressed: () {
        final groupName = nameController.text;
        final groupDescription = descriptionController.text;
        final imageFile = imageKey.currentState?.selectedImage;

        Navigator.pop(context);
        createGroupWithImage(groupName, groupDescription, imageFile, context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: EVColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        minimumSize: const Size(double.infinity, 0), // Full width button
        elevation: 3,
      ),
      child: Text(
        'Create Group',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
      ),
    );
  }

  static Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[700],
        padding: EdgeInsets.symmetric(vertical: 12.h),
        minimumSize: const Size(double.infinity, 0), // Full width button
      ),
      child: Text('Cancel', style: TextStyle(fontSize: 16.sp)),
    );
  }

  static Future<void> createGroupWithImage(String name, String description,
      File? imageFile, BuildContext context) async {
    final GroupController groupController = Get.find();

    try {
      if (imageFile != null) {
        logger.i(
            "Group created with Name: \$name, Description: \$description, and Image: \${imageFile.path}");
      } else {
        logger.i(
            "Group created with Name: \$name and Description: \$description (No image selected)");
      }

      await groupController.createGroup(name, description);

      Future.delayed(const Duration(milliseconds: 300), () {
        groupController.getUserGroups();
        groupController.getAlreadyJoinedGroups();
      });

      Toast.show(
          message: "Group \$name created successfully",
          type: ToastType.success);
    } catch (e) {
      Toast.show(
          message: "Failed to create Group \$name: \$e", type: ToastType.error);
    }
  }
}

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({Key? key}) : super(key: key);

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
      logger.e("Error picking image: \$e");
      Get.snackbar(
        "Error",
        "Failed to pick image. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _showImageSourceOptions(context),
          child: _buildImageContainer(),
        ),
        if (selectedImage != null) _buildChangePhotoButton(),
      ],
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
        border: Border.all(color: EVColors.primary, width: 2),
        image: selectedImage != null
            ? DecorationImage(
                image: FileImage(selectedImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: selectedImage == null ? _buildPlaceholderContent() : null,
    );
  }

  Widget _buildPlaceholderContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 40,
          color: EVColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          "Add Group Photo",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildChangePhotoButton() {
    return TextButton.icon(
      onPressed: () => _showImageSourceOptions(context),
      icon: const Icon(Icons.edit, size: 16),
      label: const Text("Change Photo"),
      style: TextButton.styleFrom(
        foregroundColor: EVColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  "Select Image Source",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: EVColors.primary),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: EVColors.primary),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (selectedImage != null) _buildRemovePhotoOption(context),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRemovePhotoOption(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete, color: Colors.red),
      title: const Text("Remove Photo"),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          selectedImage = null;
        });
      },
    );
  }
}
