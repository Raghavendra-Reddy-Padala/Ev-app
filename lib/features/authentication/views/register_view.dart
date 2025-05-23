import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/authentication/controller/auth_controller.dart';
import 'package:mjollnir/shared/constants/constants.dart';
import '../../../shared/components/auth/signup_form_fields.dart';
import '../../../shared/components/buttons/custom_button.dart';
import '../../../shared/components/profile_picker/profile_image_picker.dart';
import '../../../shared/components/texts/tac.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: GetBuilder<AuthController>(
              builder: (controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Image.asset(Constants.currentLogo),
                    ),
                    SizedBox(height: 20.h),
                    if (controller.currentStep.value == 1)
                      _buildPersonalInfoForm(controller, context)
                    else if (controller.currentStep.value == 2)
                      _buildAdditionalInfoForm(controller, context)
                    else
                      _buildProfilePictureStep(controller, context),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm(
      AuthController controller, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Column(
        children: [
          SignupFormFields.phoneField(controller.phoneController,
              readOnly: true),
          SizedBox(height: 10.h),
          SignupFormFields.firstNameField(controller.firstNameController),
          SizedBox(height: 10.h),
          SignupFormFields.lastNameField(controller.lastNameController),
          SizedBox(height: 10.h),
          SignupFormFields.dobField(controller.dobController),
          SizedBox(height: 10.h),
          SignupFormFields.genderDropdown(controller.gender),
          SizedBox(height: 20.h),
          CustomButton(
            label: 'Continue',
            onPressed: controller.validateAndContinue,
            width: double.infinity,
            backgroundColor: Colors.black,
          ),
          SizedBox(height: 20.h),
          const TermsText(),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoForm(
      AuthController controller, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Column(
        children: [
          SignupFormFields.userTypeDropdown(controller.userType),
          SizedBox(height: 10.h),
          SignupFormFields.placeField(
              controller.placeController, controller.userType.value),
          SizedBox(height: 10.h),
          Obx(() => Visibility(
                visible: controller.userType.value == "student" ||
                    controller.userType.value == "employee",
                child: Column(
                  children: [
                    SignupFormFields.idField(
                        controller.idController, controller.userType.value),
                    SizedBox(height: 10.h),
                  ],
                ),
              )),
          SignupFormFields.emailField(
              controller.emailController, controller.userType.value),
          SizedBox(height: 10.h),
          SignupFormFields.heightField(
              controller.heightController, controller.heightUnit),
          SizedBox(height: 10.h),
          SignupFormFields.weightField(
              controller.weightController, controller.weightUnit),
          SizedBox(height: 20.h),
          CustomButton(
            label: 'Continue',
            onPressed: controller.validateSecondFormAndContinue,
            width: double.infinity,
            backgroundColor: Colors.black,
          ),
          SizedBox(height: 10.h),
          const TermsText(),
        ],
      ),
    );
  }

  Widget _buildProfilePictureStep(
      AuthController controller, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Column(
        children: [
          SizedBox(height: 30.h),
          ProfileImagePicker(
            imageUrl: controller.profileImageUrl,
            onImageSelected: controller.updateProfileImage,
            size: 120,
          ),
          SizedBox(height: 30.h),
          CustomButton(
            label: 'Complete Signup',
            onPressed: controller.completeSignup,
            width: double.infinity,
            backgroundColor: Colors.black,
          ),
          SizedBox(height: 10.h),
          const TermsText(),
        ],
      ),
    );
  }
}
