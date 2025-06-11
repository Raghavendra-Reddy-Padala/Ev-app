import 'package:bolt_ui_kit/bolt_kit.dart' as t;
import 'package:bolt_ui_kit/helpers/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/faq/faq_controller.dart';

import '../../shared/components/header/header.dart';

class FAQ extends StatelessWidget {
  FAQ({super.key});

  final FaqController controller = Get.put(FaqController());

  @override
  Widget build(BuildContext context) {
    controller.fetchFaqs(); 
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40.h),
        child: Header(heading: 'FAQ'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "FAQs are frequently asked questions that help you understand our services better.",
                  style: t.AppTextThemes.bodySmall().copyWith(
                    color: Colors.black,
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () => controller.refreshFaqs(),
                  child: Text('Get FAQs'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshFaqs(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(), // Enables pull-to-refresh
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    'How can we help you?',
                    style: t.AppTextThemes.bodyMedium().copyWith(
                      fontSize: 16.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.faqs.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final faq = controller.faqs[index];

                    return Obx(() {
                      final isExpanded =
                          index < controller.expandedStates.length
                              ? controller.expandedStates[index]
                              : false;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    faq.question,
                                    style: t.AppTextThemes.bodySmall().copyWith(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF424242),
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                GestureDetector(
                                  onTap: () =>
                                      controller.toggleExpansion(index),
                                  child: AnimatedRotation(
                                    duration: const Duration(milliseconds: 300),
                                    turns: isExpanded ? 0.125 : 0,
                                    child: Container(
                                      width: 24.w,
                                      height: 24.w,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00D4AA),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 12.h),
                                  Text(
                                    faq.answer,
                                    style: t.AppTextThemes.bodySmall().copyWith(
                                      color: const Color(0xFF757575),
                                      fontSize: 12.sp,
                                      height: 1.4,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}
