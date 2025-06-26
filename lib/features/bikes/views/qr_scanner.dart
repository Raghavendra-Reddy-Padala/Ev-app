import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bolt_ui_kit/components/toast/toast.dart' show Toast, ToastType;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/features/bikes/controller/bike_metrics_controller.dart';
import 'package:mjollnir/shared/models/trips/trips_model.dart';
import '../../../../shared/components/buttons/app_button.dart';
import '../../main_page_controller.dart';
import '../controller/qr_controller.dart';
import '../controller/trips_control_service.dart';
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
          width: 250.w,
          height: 250.w,
          child: Image.asset('assets/images/qr2.png'),
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
    return AppButton(
      text: "Riding your own bike?",
      type: ButtonType.dark,
      fullWidth: true,
      isLoading: _isLoading,
      onPressed: _isLoading ? null : _handleOwnBikeTap,
    );
  }

  Future<void> _handleOwnBikeTap() async {
    setState(() => _isLoading = true);

    try {

      final bikeController = Get.find<BikeMetricsController>();
      final tripControlService = Get.find<TripControlService>();
      final storage = Get.find<LocalStorage>();

      await _clearExistingTripData(storage, bikeController);
      final startTripData = StartTrip(
        bikeId: "_3a0ienbqx",
        stationId: "6xugln92qx",
        personal: true,
      );

      final success = await tripControlService.startFreshTrip(
        startTripData,
        personal: true,
      );

      if (success) {
        Get.find<MainPageController>().isBikeSubscribed.value = true;
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1,
            channelKey: "tracking_channel",
            title: "Bike tracking active!",
            body: "Your ride metrics are being tracked",
          ),
        );
        print("🎉 Personal bike setup completed successfully");
        Get.back();
      } else {
        Toast.show(
          message: tripControlService.errorMessage.value.isNotEmpty
              ? tripControlService.errorMessage.value
              : "Failed to start trip",
          type: ToastType.error,
        );
      }
    } catch (e) {
      Toast.show(
        message: "Failed to start bike tracking: $e",
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearExistingTripData(
      LocalStorage storage, BikeMetricsController bikeController) async {
    await storage.remove('tripId');
    await storage.setBikeSubscribed(false);
    await storage.setBikeCode('');
    await storage.setDouble('totalDistance', 0.0);
    await storage.setDouble('totalDuration', 0.0);
    await storage.setDouble('currentSpeed', 0.0);
    await storage.setDouble('calories', 0.0);
    await storage.setDouble('maxElevation', 0.0);
    await storage.setTime(0);
    await storage.saveLocationList([]);
    await storage.savePathPoints([]);

    // Reset controller values
    bikeController.totalDistance.value = 0.0;
    bikeController.totalDuration.value = 0.0;
    bikeController.currentSpeed.value = 0.0;
    bikeController.calculatedCalories.value = 0.0;
    bikeController.maxElevation.value = 0.0;
    bikeController.bikeSubscribed.value = false;
    bikeController.bikeID.value = '';
    bikeController.pathPoints.clear();
    bikeController.startLocationName.value = '';
    bikeController.endLocationName.value = '';
  }
}
