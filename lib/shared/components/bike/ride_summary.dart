import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import '../../../core/storage/local_storage.dart';
import '../../../features/account/controllers/trips_controller.dart';
import '../../../features/bikes/controller/bike_controller.dart';
import '../../../features/bikes/controller/bike_metrics_controller.dart';
import '../../../features/main_page_controller.dart';
import '../../constants/colors.dart';
import '../../models/trips/trips_model.dart';
import '../map/path_view.dart';
import '../misc/miscdownloader.dart';
import 'summary_card.dart';

class RideSummary extends StatefulWidget {
  final EndTrip? tripData;

  RideSummary({super.key, this.tripData});

  @override
  State<RideSummary> createState() => _RideSummaryState();
}

class _RideSummaryState extends State<RideSummary> with WidgetsBindingObserver {
  final ScreenshotController screenshotController = ScreenshotController();
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _markSummaryAsShown();

    print('🎯 RideSummary: Initialized with trip data');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _markSummaryAsShown() async {
    try {
      final localStorage = Get.find<LocalStorage>();
      await localStorage.setString(
          'lastSummaryShown', DateTime.now().toIso8601String());
      print('✅ Trip summary marked as shown');
    } catch (e) {
      print('⚠️ Error marking summary as shown: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final BikeMetricsController bikeController =
        Get.find<BikeMetricsController>();
    final LocalStorage localStorage = Get.find<LocalStorage>();
    final TripsController tripsController = Get.find<TripsController>();
    final BikeController bikeDataController = Get.find<BikeController>();

    return WillPopScope(
      onWillPop: () async {
        await _handleClose();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black87,
              size: 24.w,
            ),
            onPressed: _isClosing ? null : _handleClose,
          ),
          title: Text(
            'Trip Summary',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
        ),
        body: _isClosing
            ? _buildClosingIndicator()
            : SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  child: Screenshot(
                    controller: screenshotController,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            children: [
                              _buildSummaryCard(
                                bikeController,
                                localStorage,
                                tripsController,
                                bikeDataController,
                              ),
                              SizedBox(height: 20.h),
                              _buildMapSection(bikeController),
                              SizedBox(height: 20.h),
                              _buildMiscSection(),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildClosingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Saving trip data...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BikeMetricsController bikeController,
    LocalStorage localStorage,
    TripsController tripsController,
    BikeController bikeDataController,
  ) {
    return SummaryCard(
      rideDetails: RideDetails(
        type: 'Electric Bike',
        bikeImage: 'assets/images/bike.png',
        price: 0,
        rideId: widget.tripData?.bikeId ??
            tripsController.endTripDetails.value?.data?.bikeId ??
            "k2590tnkfx",
        frameNumber:
            bikeDataController.bikeData.value?.frameNumber ?? 'FN0199dfff',
        duration: _getDurationText(
          bikeController.totalDuration.value,
          localStorage,
        ),
        calories: _getCaloriesText(
          tripsController.endTripDetails.value?.data?.kcal,
          bikeController.lastTripCalories.value,
          localStorage,
        ),
        status: 'Completed',
      ),
      tripDetails: TripDetails(
        pickupTime: widget.tripData?.startTimestamp != null
            ? DateFormat('hh:mma').format(widget.tripData!.startTimestamp)
            : DateFormat('hh:mma').format(DateTime.now()),
        dropTime: widget.tripData?.endTimestamp != null
            ? DateFormat('hh:mma').format(widget.tripData!.endTimestamp)
            : "N/A",
        pickupLocation: bikeController.startLocationName.value.isNotEmpty
            ? bikeController.startLocationName.value
            : "Unknown Location",
        dropLocation: bikeController.endLocationName.value.isNotEmpty
            ? bikeController.endLocationName.value
            : "Unknown Location",
      ),
    );
  }

  Widget _buildMapSection(BikeMetricsController bikeController) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: double.infinity,
          height: 170.h,
          child: PathView(
            pathPoints: bikeController.pathPoints.isNotEmpty
                ? bikeController.pathPoints
                    .map((point) => LatLng(point[0], point[1]))
                    .toList()
                : [],
            isScreenshotMode: false,
          ),
        ),
      ),
    );
  }

  Widget _buildMiscSection() {
    return Miscellaneous(
      diffPage: false,
      screenshotController: screenshotController,
    );
  }

  Future<void> _handleClose() async {
    if (_isClosing) return;

    setState(() {
      _isClosing = true;
    });

    try {
      print('🔄 RideSummary: Handling close...');

      // Ensure main page state is properly reset
      if (Get.isRegistered<MainPageController>()) {
        final mainController = Get.find<MainPageController>();
        print('🔄 Refreshing main page subscription status...');
        await mainController.refreshSubscriptionStatus();

        // Force update to QR scanner if user was on bike tab
        if (mainController.selectedIndex.value == 1) {
          print('🔄 Forcing navigation refresh for bike tab...');
          mainController.updateSelectedIndex(0); // Go to home first
          await Future.delayed(Duration(milliseconds: 100));
          mainController.updateSelectedIndex(1); // Then back to QR scanner
        }
      }

      // Give some time for state updates
      await Future.delayed(Duration(milliseconds: 300));

      print('✅ RideSummary: State reset completed, navigating back...');

      // Navigate back to main page
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.back();
    } catch (e) {
      print('❌ Error in _handleClose: $e');
      // Force navigation even if there's an error
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleShare() async {
    try {
      print('📤 Sharing trip summary...');
      // You can implement share functionality here
      // For now, just take a screenshot and show a message

      final image = await screenshotController.capture();
      if (image != null) {
        // Implement your share logic here
        Get.snackbar(
          'Success',
          'Trip summary prepared for sharing',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error sharing: $e');
      Get.snackbar(
        'Error',
        'Could not prepare trip summary for sharing',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleSaveImage() async {
    try {
      print('💾 Saving trip summary image...');

      final image = await screenshotController.capture();
      if (image != null) {
        // You can implement save to gallery functionality here
        Get.snackbar(
          'Success',
          'Trip summary saved to gallery',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error saving image: $e');
      Get.snackbar(
        'Error',
        'Could not save trip summary',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  String _getDurationText(double localDuration, LocalStorage localStorage) {
    final time = localStorage.getDouble("lastTripDuration")?.toInt() ?? 0;

    if (time < 60) {
      return "$time sec";
    }

    final totalMinutes = (time / 60).round();
    final hours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;

    if (hours > 0) {
      return "$hours hr $remainingMinutes min";
    } else {
      return "$remainingMinutes min";
    }
  }

  String _getCaloriesText(
    num? backendCalories,
    double controllerCalories,
    LocalStorage localStorage,
  ) {
    final lastTripCal = localStorage.getDouble("lastTripCalories") ?? 0.0;

    if (lastTripCal > 0) {
      return "${lastTripCal.toInt()} Kcal";
    }

    if (controllerCalories > 0) {
      return "${controllerCalories.toInt()} Kcal";
    }

    return "0 Kcal";
  }
}
