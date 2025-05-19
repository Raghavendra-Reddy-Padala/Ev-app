import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/components/buttons/app_button.dart';
import 'package:mjollnir/shared/components/inputs/app_text_fields.dart';

class LoginMainView extends StatelessWidget {
  const LoginMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: _UI()),
    );
  }
}

class _UI extends StatelessWidget {
  const _UI();

  @override
  Widget build(BuildContext context) {
     
    final AppTextField textFields = Get.find<AppTextField>();
    final AppButton elevatedButtons = AppButton();
    final Texts texts = Texts();
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CompanyLogoPadding(),
          SizedBox(height:30.h),
          Text(
            TextStrings.login,
            style: CustomTextTheme.headlineSmallIBold,
          ),
          SizedBox(height:20.h),
          textFields.loginTextField,
          SizedBox(height:15.h),
          SizedBox(
            width:350.w,
            height: 50.w,
            child: elevatedButtons.loginButton,
          ),
          SizedBox(height:20.h),
          Padding(
            padding:EdgeInsets.symmetric(horizontal: 25.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: texts.loginText1,
                ),
                const Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height:20.h),
          SizedBox(
            width: 350.w,
            height: 50.w,
            child: elevatedButtons.googleButton,
          ),
          SizedBox(height:20.h),
          Padding(
            padding:EdgeInsets.symmetric(horizontal: 15.h),
            child: texts.tc,
          ),
        ],
      ),
    );
  }
}
