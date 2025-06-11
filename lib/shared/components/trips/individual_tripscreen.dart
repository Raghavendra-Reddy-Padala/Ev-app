import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/components/map/graph_view.dart';
import 'package:mjollnir/shared/components/map/path_view.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class IndividualTripScreen extends StatelessWidget {
  final Trip trip;
  const IndividualTripScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header with better spacing
            const Header(heading: "My Trip"),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: UI(trip: trip),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UI extends StatelessWidget {
  final Trip trip;
  UI({super.key, required this.trip});
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> _shareTrip() async {
    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/trip_summary.png';
        
        // Save image to file
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        
        // Share the image
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Check out my amazing trip! 🚴‍♂️\n'
                '#Mjollnir #CyclingLife #FitnessJourney',
        );
      }
    } catch (e) {
      print('Error sharing trip: $e');
    
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Screenshot(
          controller: screenshotController,
          child: Container(
            color: const Color(0xFFF8FAFB),
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Image.asset(
                    'assets/company/Logo-Black.png',
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
                ),
                
                EnhancedTripDetails(trip: trip),
                SizedBox(height: 24.h),
                
                EnhancedGraphAndPath(trip: trip),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 24.h),
        
        // Share Button
        Container(
          width: double.infinity,
          height: 56.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
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
              onTap: _shareTrip,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: _shareTrip,
                      child: Text(
                        'Share Trip Summary',
                        style: AppTextThemes.bodyLarge().copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // SizedBox(height: 16.h),
        
        // Row(
        //   children: [
        //     Expanded(
        //       child: _buildQuickShareButton(
        //         icon: Icons.facebook,
        //         label: 'WhatsApp',
        //         color: const Color(0xFF25D366),
        //         onTap: () => _shareToSpecificPlatform('whatsapp'),
        //       ),
        //     ),
        //     SizedBox(width: 12.w),
        //     Expanded(
        //       child: _buildQuickShareButton(
        //         icon: Icons.telegram,
        //         label: 'Telegram',
        //         color: const Color(0xFF0088CC),
        //         onTap: () => _shareToSpecificPlatform('telegram'),
        //       ),
        //     ),
        //     SizedBox(width: 12.w),
        //     Expanded(
        //       child: _buildQuickShareButton(
        //         icon: Icons.more_horiz,
        //         label: 'More',
        //         color: const Color(0xFF6B7280),
        //         onTap: _shareTrip,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildQuickShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 20.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: AppTextThemes.bodySmall().copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareToSpecificPlatform(String platform) async {
    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/trip_summary_$platform.png';
        
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        
        String shareText = '🚴‍♂️ Just completed an amazing ride!\n\n'
                          
                          '#Mjollnir #CyclingLife #FitnessGoals';
        
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: shareText,
        );
        
        // Show success feedback
        Get.snackbar(
          'Shared Successfully! 🎉',
          'Your trip summary has been shared',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error sharing to $platform: $e');
    }
  }
}

class EnhancedTripDetails extends StatelessWidget {
  final Trip trip;
  const EnhancedTripDetails({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9F4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE8F5ED),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Detailed Ride",
            style: AppTextThemes.bodyLarge().copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Time and Distance Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: "Start Time",
                  value: "7:30 AM",
                  icon: Icons.schedule,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  label: "End Time",
                  value: "8:19 AM",
                  icon: Icons.schedule_outlined,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  label: "Distance",
                  value: "3km",
                  icon: Icons.straighten,
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: "Run Time",
                  value: "49m 32sec",
                  icon: Icons.timer,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  label: "Calories",
                  value: "830 kcal",
                  icon: Icons.local_fire_department,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  label: "Avg Speed",
                  value: "8 km/h",
                  icon: Icons.speed,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Third Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: "Maximum Elevation",
                  value: "150 m",
                  icon: Icons.terrain,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  label: "Carbon footprint",
                  value: "25 kg",
                  icon: Icons.eco,
                  valueColor: Colors.green,
                ),
              ),
              Expanded(child: Container()), // Empty space for alignment
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: const Color(0xFF6B7280),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                style: AppTextThemes.bodySmall().copyWith(
                  color: Colors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTextThemes.bodyMedium().copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A1A),
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}

class EnhancedGraphAndPath extends StatelessWidget {
  final Trip trip;
  const EnhancedGraphAndPath({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Enhanced Tab Bar
            Container(
              margin: EdgeInsets.all(16.w),
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF6B7280),
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                indicatorPadding: EdgeInsets.all(2.w),
                labelPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Riding Path",
                        style: AppTextThemes.bodyMedium().copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Graph",
                        style: AppTextThemes.bodyMedium().copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Area
            Container(
              height: 300.h,
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: BorderedContainer(trip: trip),
            ),
          ],
        ),
      ),
    );
  }
}

class BorderedContainer extends StatelessWidget {
  final Trip trip;
  const BorderedContainer({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final TripsController tripController = Get.find<TripsController>();
    List<LatLng> pathPoints = [];
    
    try {
      if (trip.path.isNotEmpty) {
        pathPoints = tripController.convertToLatLng(
          trip.path.map((point) => [point.lat, point.long]).toList()
        );
      }
    } catch (e) {
      print("Error converting path points: $e");
    }

    final Map<int, double> graphData = {
      0: 8.0,
      1: 10.0,
      2: 12.0,
    };
    
    final Map<int, String> xLabels = {
      0: '8 Hr',
      1: '10 Hr',
      2: '12 Hr',
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: TabBarView(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
            ),
            child: PathView(pathPoints: pathPoints),
          ),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: GraphView(
              data: graphData,
              xLabels: xLabels,
              showYAxisLabels: true,
              showHorizontalLines: true,
              showLogo: true,
              useParentColor: true,
            ),
          ),
        ],
      ),
    );
  }
}