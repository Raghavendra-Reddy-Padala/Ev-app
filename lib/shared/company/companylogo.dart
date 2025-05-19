import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/company/applogo.dart';

class CompanyLogoPadding extends StatelessWidget {
  const CompanyLogoPadding({super.key});

  @override
  Widget build(BuildContext context) {
     
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: const CompanyLogo(),
    );
  }
}
