import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bolt_ui_kit/bolt_kit.dart' show AppTextThemes;
import 'package:bolt_ui_kit/components/toast/toast.dart' show Toast, ToastType;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:mjollnir/features/bikes/controller/bike_metrics_controller.dart';
import 'package:mjollnir/shared/models/trips/trips_model.dart';
import '../../../../shared/components/buttons/app_button.dart';
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
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "There's a QR code affixed to rent your bike",
          style: TextStyle(
            fontSize: 14.sp,
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
           _RidingOwnBikeButton(),
      ],
    );
  }

  void _scanQrCode(BuildContext context) {
    Get.to(QrCameraView(onScan: controller.processQrCode));
  }
}


class _RidingOwnBikeButton extends StatefulWidget {
  @override
  _RidingOwnBikeButtonState createState() => _RidingOwnBikeButtonState();
}

class _RidingOwnBikeButtonState extends State<_RidingOwnBikeButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else
          TextButton(
            onPressed: _handleOwnBikeTap,
            child: Text(
              "Riding your own bike?",
              style: TextStyle(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleOwnBikeTap() async {
    setState(() => _isLoading = true);
    
    try {
      final tripsController = Get.find<TripsController>();
      final bikeController = Get.find<BikeMetricsController>();
      final storage = Get.find<LocalStorage>();
      
      // Try to start trip
      final success = await tripsController.startTrip(
        StartTrip(
          bikeId: "_3a0ienbqx",
          stationId: "6xugln92qx",
          personal: true,
        ),
        personal: true,
      );

      if (success) {
        // Setup bike tracking
        bikeController.bikeSubscribed.value = true;
        bikeController.bikeID.value = "_3a0ienbqx";
        await storage.setBikeSubscribed(true);
        await storage.setBikeCode("_3a0ienbqx");
        await bikeController.startTracking();

        // Update main page
        Get.find<MainPageController>().isBikeSubscribed.value = true;
        
        // Show success notification
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1,
            channelKey: "tracking_channel",
            title: tripsController.tripId.value.isEmpty 
              ? "Resumed tracking your bike!" 
              : "Started tracking your bike!",
          ),
        );
      } else {
        Toast.show(
          message: "Already in an Active trip.",
          type: ToastType.error,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to start trip: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
  // Future<void> _handleDemoRide() async {
  //   final success = await controller.startDemoTrip();
  //   if (success) {
  //     final MainPageController mainPageController = Get.find();
  //     mainPageController.isBikeSubscribed.value = true;
  //   }
  // }

