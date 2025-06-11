import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/constants/constants.dart';
import '../../../shared/components/buttons/login_button.dart';
import '../../../shared/components/inputs/phone_field.dart';
import '../../../shared/components/texts/tac.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController controller;

  const LoginScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),
                  
                  // Logo section
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        Constants.currentLogo,
                        height: 80.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 48.h),
                  
                  // Welcome text
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Text(
                    "Sign in to continue to your account",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  // Login form container
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Phone Number",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            letterSpacing: 0.2,
                          ),
                        ),
                        
                        SizedBox(height: 8.h),
                        
                        PhoneField(controller: controller.phoneController),
                        
                        SizedBox(height: 24.h),
                        
                        LoginButton(
                          onTap: controller.handleLogin,
                          isLoading: controller.isLoading,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Terms and conditions
                  const TermsText(),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}