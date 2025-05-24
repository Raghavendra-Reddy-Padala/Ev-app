import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../shared/components/buttons/app_button.dart';
import '../../../../shared/components/header/header.dart';
import '../../../../shared/constants/colors.dart';
import '../../main_page_controller.dart';
import '../controller/qr_controller.dart';
import 'qr_camera_view.dart';

class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final QrScannerController controller = Get.put(QrScannerController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Header(heading: "Scan QR Code"),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QrInstructions(),
                    _QrImage(),
                    _ActionButtons(controller: controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrInstructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Scan your code",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "There's a QR code affixed to rent your bike",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QrImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200.w,
          height: 200.w,
          child: Image.asset('assets/images/qr.png'),
        ),
        SizedBox(height: 16.h),
        Text(
          "Haven't started your ride yet?",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final QrScannerController controller;

  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return AppButton(
            text: "Scan QR Code",
            type: ButtonType.primary,
            fullWidth: true,
            isLoading: controller.isProcessing.value,
            onPressed: () => _scanQrCode(context),
          );
        }),
        SizedBox(height: 16.h),
        _DemoButton(controller: controller),
      ],
    );
  }

  void _scanQrCode(BuildContext context) {
    NavigationService.pushTo(
      QrCameraView(onScan: controller.processQrCode),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final QrScannerController controller;

  const _DemoButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: _handleDemoRide,
        child: Text(
          "Riding your own bike?",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
      );
    });
  }

  Future<void> _handleDemoRide() async {
    final success = await controller.startDemoTrip();
    if (success) {
      final MainPageController mainPageController = Get.find();
      mainPageController.isBikeSubscribed.value = true;
    }
  }
}
