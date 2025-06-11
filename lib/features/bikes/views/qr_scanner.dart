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
    return Column(
      children: [
        if (_isLoading)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        AppButton(
          text: "Riding your own bike?",
          type: ButtonType.dark,
          fullWidth: true,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _handleOwnBikeTap,
        ),
      ],
    );
  }

  Future<void> _handleOwnBikeTap() async {
    setState(() => _isLoading = true);

    try {
      print("🚴 Starting personal bike trip...");

      final tripsController = Get.find<TripsController>();
      final bikeController = Get.find<BikeMetricsController>();
      final tripControlService = Get.find<TripControlService>();
      final storage = Get.find<LocalStorage>();

      // First check if there's already an active trip
      print("🔍 Checking for existing active trip...");
      final activeTrip = await tripsController.fetchActiveTrip();

      bool shouldSetupBike = false;
      String notificationTitle = "";

      if (activeTrip != null) {
        print("✅ Found existing active trip: ${activeTrip.id}");
        // User already has an active trip
        tripsController.tripId.value = activeTrip.id;
        tripsController.activeTripData.value = activeTrip;
        tripControlService.currentTripId.value = activeTrip.id;

        // Load existing metrics
        bikeController.totalDistance.value = activeTrip.distanceKm;
        bikeController.currentSpeed.value = activeTrip.speedKmh;
        bikeController.calculatedCalories.value = activeTrip.caloriesTrip;
        bikeController.maxElevation.value = activeTrip.maxElevationM;
        bikeController.totalDuration.value = activeTrip.totalTimeHours * 3600;

        // Save to storage
        await storage.setTripMetrics(
          distance: activeTrip.distanceKm,
          duration: activeTrip.totalTimeHours * 3600,
          speed: activeTrip.speedKmh,
          calories: activeTrip.caloriesTrip,
          elevation: activeTrip.maxElevationM,
        );

        shouldSetupBike = true;
        notificationTitle = "Resumed tracking your bike!";
        print("🔄 Resuming existing trip with metrics loaded");
      } else {
        print("🆕 No existing trip found, starting new trip...");
        // Try to start a new trip
        final startTripData = StartTrip(
          bikeId: "_3a0ienbqx",
          stationId: "6xugln92qx",
          personal: true,
        );

        final success = await tripControlService.startTrip(
          startTripData,
          personal: true,
        );

        if (success) {
          shouldSetupBike = true;
          notificationTitle = "Started tracking your bike!";
          print("✅ New personal trip started successfully");
        } else {
          print(
              "❌ Failed to start new trip: ${tripControlService.errorMessage.value}");
          Toast.show(
            message: tripControlService.errorMessage.value.isNotEmpty
                ? tripControlService.errorMessage.value
                : "Failed to start trip",
            type: ToastType.error,
          );
          return;
        }
      }

      // Setup bike tracking if everything went well
      if (shouldSetupBike) {
        print("🔧 Setting up bike tracking...");

        bikeController.bikeSubscribed.value = true;
        bikeController.bikeID.value = "_3a0ienbqx";

        await storage.setBikeSubscribed(true);
        await storage.setBikeCode("_3a0ienbqx");

        // Start or resume tracking
        if (!bikeController.isTracking.value) {
          await bikeController.startTracking();
        }

        // Update main page
        Get.find<MainPageController>().isBikeSubscribed.value = true;

        // Show success notification
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1,
            channelKey: "tracking_channel",
            title: notificationTitle,
            body: "Your ride metrics are being tracked automatically",
          ),
        );

        print("🎉 Personal bike setup completed successfully");

        // Navigate back or close modal
        Get.back();
      }
    } catch (e) {
      print('❌ Error in _handleOwnBikeTap: $e');
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
}
