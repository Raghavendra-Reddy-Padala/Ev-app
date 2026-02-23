import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:mjollnir/features/bikes/controller/bike_controller.dart';
import 'package:mjollnir/features/bikes/controller/bike_metrics_controller.dart';
import 'package:mjollnir/features/main_page_controller.dart';
import 'package:mjollnir/shared/components/bike/summary_card.dart';
import 'package:mjollnir/shared/components/map/path_view.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/trips/trips_model.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class RideSummary extends StatefulWidget {
  final EndTrip? tripData;
  final double fareAmount; // Add fare parameter

  RideSummary({
    super.key, 
    this.tripData,
    this.fareAmount = 0, // Default to 0 if not provided
  });

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
    print('💰 Fare Amount: ${widget.fareAmount}');
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
    final BikeMetricsController bikeController = Get.find<BikeMetricsController>();
    final LocalStorage localStorage = Get.find<LocalStorage>();
    final TripsController tripsController = Get.find<TripsController>();
    final BikeController bikeDataController = Get.find<BikeController>();

    // Get fare from multiple sources (priority order)
    final displayFare = widget.fareAmount > 0 
        ? widget.fareAmount 
        : (widget.tripData?.fare ?? 
           tripsController.endTripDetails.value?.data?.rideSummary?.fare ?? 
           0);

    return WillPopScope(
      onWillPop: () async {
        await _handleClose();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isClosing
            ? _buildClosingIndicator()
            : Column(
                children: [
                  _buildCustomHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        color: Colors.white,
                        child: Screenshot(
                          controller: screenshotController,
                          child: Container(
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
                                      // Add Fare Display Section
                                      _buildFareSection(displayFare),
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
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildClosingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            'Saving trip data...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // NEW: Fare Display Section
  Widget _buildFareSection(double fare) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Fare',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '₹ ${fare.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Paid',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        type: 'Manual Bike',
        bikeImage: 'assets/images/bike.png',
        price: 0,
        rideId: widget.tripData?.bikeId ??
            tripsController.endTripDetails.value?.data?.trip?.bikeId ??
            "k2590tnkfx",
        frameNumber: bikeDataController.bikeData.value?.frameNumber ?? 'FN0199dfff',
        duration: _getDurationText(bikeController.totalDuration.value, localStorage),
        calories: _getCaloriesText(
          tripsController.endTripDetails.value?.data?.rideSummary?.caloriesBurned,
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
          color: Colors.white,
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
      
      await Future.delayed(Duration(milliseconds: 300));
      
      final Uint8List? image = await screenshotController.capture(
        delay: Duration(milliseconds: 500),
        pixelRatio: 2.0,
      );
      
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final imagePath = '${directory.path}/trip_summary_$timestamp.png';
        
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        
        print('✅ Screenshot saved to: $imagePath');
        
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Check out my amazing trip! 🚴‍♂️\n'
                'Total Fare: ₹${widget.fareAmount.toStringAsFixed(0)}\n'
                '#Mjollnir #CyclingLife #FitnessJourney',
        );
        
        print('✅ Trip summary shared successfully');
        
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

      if (Get.isRegistered<MainPageController>()) {
        final mainController = Get.find<MainPageController>();
        print('🔄 Refreshing main page subscription status...');
        await mainController.refreshSubscriptionStatus();

        if (mainController.selectedIndex.value == 1) {
          print('🔄 Forcing navigation refresh for bike tab...');
          mainController.updateSelectedIndex(0);
          await Future.delayed(Duration(milliseconds: 100));
          mainController.updateSelectedIndex(1);
        }
      }

      await Future.delayed(Duration(milliseconds: 300));

      print('✅ RideSummary: State reset completed, navigating back...');

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.back();
    } catch (e) {
      print('❌ Error in _handleClose: $e');
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