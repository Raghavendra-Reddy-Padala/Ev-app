import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';

class SignupFormFields {
  static Widget phoneField(TextEditingController controller,
      {bool readOnly = false}) {
    return _buildTextField(
      controller: controller,
      hintText: "9999999999",
      keyboardType: TextInputType.phone,
      prefixText: "+91  ",
      readOnly: readOnly,
    );
  }

  static Widget placeField(TextEditingController controller, String userType) {
    // Only show college dropdown for students
    if (userType == "student") {
      return Builder(builder: (context) {
        final theme = Theme.of(context);

        return SizedBox(
          width: 350.w,
          height: 50.w,
          child: DropdownButtonFormField<String>(
            value: controller.text.isNotEmpty ? controller.text : null,
            onChanged: (value) {
              controller.text = value ?? "";
            },
            items: [
              DropdownMenuItem(
                  value: "JNTUH",
                  child: Text("JNTUH", style: theme.textTheme.bodyMedium)),
              DropdownMenuItem(
                  value: "OU",
                  child: Text("OU", style: theme.textTheme.bodyMedium)),
              DropdownMenuItem(
                  value: "CBIT",
                  child: Text("CBIT", style: theme.textTheme.bodyMedium)),
              DropdownMenuItem(
                  value: "VNR",
                  child: Text("VNR", style: theme.textTheme.bodyMedium)),
              DropdownMenuItem(
                  value: "MGIT",
                  child: Text("MGIT", style: theme.textTheme.bodyMedium)),
              DropdownMenuItem(
                  value: "MVSR",
                  child: Text("MVSR", style: theme.textTheme.bodyMedium)),
              DropdownMenuItem(
                  value: "GITAM",
                  child: Text("GITAM", style: theme.textTheme.bodyMedium)),
              DropdownMenuItem(
                  value: "BITS",
                  child: Text("BITS", style: theme.textTheme.bodyMedium)),
              DropdownMenuItem(
                  value: "IIIT",
                  child: Text("IIIT", style: theme.textTheme.bodyMedium)),
              DropdownMenuItem(
                  value: "VASAVI",
                  child: Text("VASAVI", style: theme.textTheme.bodyMedium)),
            ],
            decoration: _getInputDecoration(hintText: "Select College"),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
        );
      });
    } else if (userType == "employee") {
      return Builder(builder: (context) {
        return _buildTextField(
          controller: controller,
          hintText: "Company Name",
        );
      });
    } else if (userType == "general") {
      return const SizedBox.shrink();
    } else {
      return _buildTextField(
        controller: controller,
        hintText: "Place",
      );
    }
  }

  static Widget addressLineField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hintText: "Address Line",
    );
  }

  static Widget cityField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hintText: "City",
    );
  }

  static Widget stateField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hintText: "State",
    );
  }

  static Widget pincodeField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hintText: "Pincode",
      keyboardType: TextInputType.number,
    );
  }

  static Widget countryField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hintText: "Country",
    );
  }

  static Widget inviteCodeField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hintText: "Invite Code (Optional)",
    );
  }

  static Widget firstNameField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hintText: "First Name",
    );
  }

  static Widget lastNameField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hintText: "Last Name",
    );
  }

  static Widget dobField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hintText: "DOB",
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          String formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}/"
              "${pickedDate.month.toString().padLeft(2, '0')}/"
              "${pickedDate.year}";
          controller.text = formattedDate;
        }
      },
    );
  }

  static Widget genderDropdown(Rx<String> gender) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);

      return SizedBox(
        width: 350.w,
        height: 50.w,
        child: DropdownButtonFormField<String>(
          value: gender.value.isEmpty ? null : gender.value,
          decoration: _getInputDecoration(hintText: "Gender"),
          items: ["Male", "Female", "Others"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: theme.textTheme.bodyMedium),
            );
          }).toList(),
          onChanged: (value) {
            gender.value = value!;
          },
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ),
      );
    });
  }

  static Widget heightField(TextEditingController controller, Rx<String> unit) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);

      return _buildMeasurementField(
        controller: controller,
        hintText: "Height",
        unit: unit,
        unitOptions: ['cm', 'ft'],
        theme: theme,
      );
    });
  }

  static Widget weightField(TextEditingController controller, Rx<String> unit) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);

      return _buildMeasurementField(
        controller: controller,
        hintText: "Weight",
        unit: unit,
        unitOptions: ['kg', 'lb'],
        theme: theme,
      );
    });
  }

  static Widget userTypeDropdown(Rx<String> userType) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);

      return SizedBox(
        width: 350.w,
        height: 50.w,
        child: DropdownButtonFormField<String>(
          value: userType.value,
          decoration: _getInputDecoration(hintText: "User type"),
          items: [
            DropdownMenuItem(
              value: 'student',
              child: Text('Student', style: theme.textTheme.bodyMedium),
            ),
            DropdownMenuItem(
              value: 'employee',
              child: Text('Employee', style: theme.textTheme.bodyMedium),
            ),
            DropdownMenuItem(
              value: 'general',
              child: Text('General', style: theme.textTheme.bodyMedium),
            ),
          ],
          onChanged: (value) {
            userType.value = value!;
          },
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ),
      );
    });
  }

  static Widget idField(TextEditingController controller, String userType) {
    return _buildTextField(
      controller: controller,
      hintText: userType == "student" ? "Student ID" : "Employee ID",
    );
  }

  static Widget emailField(TextEditingController controller, String userType) {
    return _buildTextField(
      controller: controller,
      hintText: userType == "student" ? "College Mail" : "Email",
      keyboardType: TextInputType.emailAddress,
    );
  }

  static Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);

      return SizedBox(
        width: 350.w,
        height: 50.w,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: theme.textTheme.bodyMedium,
          decoration: _getInputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            theme: theme,
          ),
        ),
      );
    });
  }

  static Widget _buildMeasurementField({
    required TextEditingController controller,
    required String hintText,
    required Rx<String> unit,
    required List<String> unitOptions,
    required ThemeData theme,
  }) {
    return SizedBox(
      width: 350.w,
      height: 50.w,
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                  ),
                ),
                hintText: hintText,
                hintStyle:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                  ),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Obx(
              () => Container(
                height: 50.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.r),
                    bottomRight: Radius.circular(10.r),
                  ),
                ),
                child: DropdownButton<String>(
                  value: unit.value,
                  isExpanded: true,
                  underline: Container(),
                  items: unitOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Text(
                          value,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    unit.value = newValue!;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _getInputDecoration({
    required String hintText,
    String? prefixText,
    ThemeData? theme,
  }) {
    return InputDecoration(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(10.r),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.r),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      hintText: hintText,
      hintStyle: theme?.textTheme.bodyMedium?.copyWith(color: Colors.grey) ??
          TextStyle(color: Colors.grey),
      prefixText: prefixText,
      prefixStyle: prefixText != null
          ? theme?.textTheme.bodyMedium?.copyWith(color: Colors.grey) ??
              TextStyle(color: Colors.grey)
          : null,
    );
  }
}
