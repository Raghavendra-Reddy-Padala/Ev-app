import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/constants/colors.dart' show AppColors;
import 'package:mjollnir/shared/issues/issuecontroller.dart';

class Issues extends StatelessWidget {
  const Issues({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(IssueController());
    return const Scaffold(
      body: SafeArea(
        child: _UI(),
      ),
    );
  }
}

class _UI extends StatelessWidget {
  const _UI();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
                height: ScreenUtil().screenHeight,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Header(heading: "Report an issue"),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: const _IssueOptions(),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: const _TextFieldAndSubmit(),
            )
          ],
        ),
      ),
    );
  }
}

class _IssueOptions extends StatelessWidget {
  const _IssueOptions();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RowHelper(
          image: [
            Image.asset('assets/images/chain.png'),
            Image.asset('assets/images/battery.png'),
            Image.asset('assets/images/pedal.png')
          ],
          name: const ['Chain', 'Battery', 'Pedal'],
          startIndex: 0,
        ),
        SizedBox(height: 10.h),
        _RowHelper(
          image: [
            Image.asset('assets/images/brake.png'),
            Image.asset('assets/images/tyre.png'),
            Image.asset('assets/images/seat.png')
          ],
          name: const ['Brake', 'Tyre', 'Seat'],
          startIndex: 3,
        )
      ],
    );
  }
}

class _RowHelper extends StatelessWidget {
  final List<Image> image;
  final List<String> name;
  final int startIndex;

  const _RowHelper(
      {required this.image, required this.name, required this.startIndex});

  @override
  Widget build(BuildContext context) {
    final IssueController issueController = Get.find<IssueController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(image.length, (index) {
        return GestureDetector(
          onTap: () {
            issueController.toggleIssueSelection(
                startIndex + index, name[index]);
          },
          child: Obx(
            () => _IconGenerator(
              image: image[index],
              text: name[index],
              isSelected: issueController.selectedIssues.contains(name[index]),
            ),
          ),
        );
      }),
    );
  }
}

class _IconGenerator extends StatelessWidget {
  final Image image;
  final String text;
  final bool isSelected;

  const _IconGenerator({
    required this.image,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: ScreenUtil().screenHeight * 0.1,
          height: ScreenUtil().screenHeight * 0.1,
          decoration: BoxDecoration(
            color: AppColors.accent1,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(
              ScreenUtil().screenHeight * 0.02,
            ),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 3.0)
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: image,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          text,
          style: AppTextThemes.bodyMedium(),
        ),
      ],
    );
  }
}

class _TextFieldAndSubmit extends StatelessWidget {
  const _TextFieldAndSubmit();

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final IssueController issueController = Get.find<IssueController>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Type your concern",
          style: AppTextThemes.bodySmall().copyWith(color: Colors.grey),
        ),
        TextField(
          controller: textController,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.accent1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.r, horizontal: 15.r),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: ScreenUtil().screenHeight * 0.07,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              bool success = await issueController.submitIssue(
                textController.text,
                issueController.selectedIssues,
              );

              if (success) {
                Get.defaultDialog(
                  contentPadding: EdgeInsets.all(10.w),
                  title: "Success",
                  titleStyle: AppTextThemes.bodyLarge()
                      .copyWith(fontWeight: FontWeight.bold),
                  content:
                      const Text("Your issue has been submitted successfully!"),
                  confirm: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text("OK"),
                  ),
                );
                textController.clear();
              }
            },
            child: const Text("Submit"),
          ),
        ),
      ],
    );
  }
}
