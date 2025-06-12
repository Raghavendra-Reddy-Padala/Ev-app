import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/storage/local_storage.dart';
import '../../../features/account/controllers/trips_controller.dart';
import '../../../features/bikes/controller/bike_controller.dart';
import '../../../features/bikes/controller/bike_metrics_controller.dart';
import '../../../features/main_page_controller.dart';
import '../../constants/colors.dart';
import '../../models/trips/trips_model.dart';
import '../map/path_view.dart';
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
  bool _isSharing = false;

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
        // Remove AppBar completely
        body: _isClosing
            ? _buildClosingIndicator()
            : Column(
                children: [
                  // Add custom header with back button
                  _buildCustomHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        color: Colors.white,
                        child: Screenshot(
                          controller: screenshotController,
                          child: Container(
                            // Add white background for screenshot
                            color: Colors.white,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20.h),
                                      _buildSummaryCard(
                                        bikeController,
                                        localStorage,
                                        tripsController,
                                        bikeDataController,
                                      ),
                                      SizedBox(height: 20.h),
                                      _buildMapSection(bikeController),
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
                  ),
                  _buildShareButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10.h,
        left: 20.w,
        right: 20.w,
        bottom: 10.h,
      ),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: _isClosing ? null : _handleClose,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20.w,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Ride Summary',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 40.w), // Balance the back button
        ],
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

  Widget _buildShareButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: _isSharing ? null : _shareTrip,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSharing) ...[
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Sharing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Download',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
        type: 'Maunal Bike',
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
        child: Container(
          width: double.infinity,
          height: 170.h,
          color: Colors.white, // Ensure white background for map
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

  Future<void> _shareTrip() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      print('📤 Capturing and sharing trip summary...');
      
      // Add delay to ensure UI is fully rendered
      await Future.delayed(Duration(milliseconds: 300));
      
      final Uint8List? image = await screenshotController.capture(
        delay: Duration(milliseconds: 500),
        pixelRatio: 2.0, // High quality screenshot
      );
      
      if (image != null) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final imagePath = '${directory.path}/trip_summary_$timestamp.png';
        
        // Save image to file
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        
        print('✅ Screenshot saved to: $imagePath');
        
        // Share the image with a nice message
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Check out my amazing trip! 🚴‍♂️\n'
                '#Mjollnir #CyclingLife #FitnessJourney',
        );
        
        print('✅ Trip summary shared successfully');
        
        // Show success feedback
        Get.snackbar(
          'Success! 🎉',
          'Trip summary shared successfully',
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
          duration: Duration(seconds: 2),
        );
        
      } else {
        throw Exception('Failed to capture screenshot');
      }
    } catch (e) {
      print('❌ Error sharing trip: $e');
      
      // Show error feedback
      Get.snackbar(
        'Oops! 😔',
        'Could not share trip summary. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
        duration: Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
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