import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/theme/app_theme.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/shared/components/misc/screenshot_view.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class Miscellaneous extends StatelessWidget {
  final bool diffPage;
  final Trip? tripDetails;
  final ScreenshotController? screenshotController;
  
  const Miscellaneous({
    super.key, 
    required this.diffPage,
    this.tripDetails,
    this.screenshotController,
  });

  @override
  Widget build(BuildContext context) {
    // Build proper content instead of Placeholder
    return Column(
      children: [
        // Other widgets can be added here
        if (screenshotController != null) 
          buildShareButton(context),
      ],
    );
  }

  Widget buildShareButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.02.sh),
      child: ElevatedButton(
        onPressed: () => _handleShareButtonPress(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.share, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              'Share Summary',
              style: AppTheme.lightTheme().textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleShareButtonPress() async {
    try {
      _showLoadingDialog();
      
      final Uint8List? imageBytes = await _captureScreenshot();
      
      Get.back(); // Close loading dialog
      
      if (imageBytes != null && imageBytes.isNotEmpty) {
        await _shareRideSummary(imageBytes);
      } else {
        await _shareRideSummaryLinkOnly();
      }
    } catch (e) {
      AppLogger.e('Error handling share button press: $e');
      Get.back(); // Close loading dialog in case of error
      _showErrorSnackbar('Failed to share ride summary');
    }
  }

  void _showLoadingDialog() {
    Get.dialog(
      Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      margin: EdgeInsets.all(10.w),
    );
  }

  Future<Uint8List?> _captureScreenshot() async {
    Uint8List? imageBytes;
    
    if (diffPage) {
      imageBytes = await _captureFromDifferentPage();
    } else {
      imageBytes = await _captureFromCurrentPage();
    }
    
    return imageBytes;
  }

  Future<Uint8List?> _captureFromDifferentPage() async {
    if (tripDetails == null) {
      AppLogger.e('Trip details is null when trying to capture from different page');
      return null;
    }
    
    final ScreenshotController newScreenshotController = ScreenshotController();

    Get.to(
      () => ScreenshotView(
        details: tripDetails!,
        screenshotController: newScreenshotController,
      ),
      preventDuplicates: false,
    );
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    return await _tryMultipleCaptures(newScreenshotController);
  }

  Future<Uint8List?> _captureFromCurrentPage() async {
    if (screenshotController == null) {
      AppLogger.e('Screenshot controller is null when trying to capture from current page');
      return null;
    }
    
    // Short delay to ensure UI is ready
    await Future.delayed(const Duration(milliseconds: 300));
    
    return await _tryMultipleCaptures(screenshotController!);
  }

  Future<Uint8List?> _tryMultipleCaptures(ScreenshotController controller) async {
    const int maxAttempts = 3;
    const int delayBetweenAttempts = 500;
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final imageBytes = await controller.capture(
          delay: const Duration(milliseconds: 300),
          pixelRatio: 2.0,
        );
        
        if (imageBytes != null && imageBytes.isNotEmpty) {
          return imageBytes;
        }
        
        AppLogger.w('Screenshot attempt $attempt returned empty bytes');
      } catch (e) {
        AppLogger.e('Screenshot attempt $attempt failed: $e');
      }
      
      await Future.delayed(const Duration(milliseconds: delayBetweenAttempts));
    }
    
    return null;
  }

  Future<void> _shareRideSummary(Uint8List imageBytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/ride_summary_$timestamp.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);
      
      final String rideId = _getRideId();
      final String summaryUrl = _generateSummaryUrl(rideId);
      final String shareText = _generateShareText(summaryUrl);
      
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: shareText,
        subject: 'My Bike Ride Summary',
      );
    } catch (e) {
      AppLogger.e('Error sharing ride summary with image: $e');
      await _shareRideSummaryLinkOnly();
    }
  }

  Future<void> _shareRideSummaryLinkOnly() async {
    try {
      final String rideId = _getRideId();
      final String summaryUrl = _generateSummaryUrl(rideId);
      final String shareText = _generateShareText(summaryUrl);

      await Share.share(
        shareText,
        subject: 'My Bike Ride Summary',
      );
    } catch (e) {
      AppLogger.e('Error sharing ride summary link: $e');
      _showErrorSnackbar('Failed to share ride summary');
    }
  }

  String _getRideId() {
    return tripDetails?.id ?? 'ride_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateSummaryUrl(String rideId) {
    return 'https://ev-api.aks2.mellob.in/v1/trips/summary/$rideId';
  }

  String _generateShareText(String summaryUrl) {
    if (tripDetails != null) {
      final double? distance = tripDetails?.distance;
      final String? duration = tripDetails?.duration as String?;
      
      String statsText = '';
      if (distance != null) {
        statsText += '${distance.toStringAsFixed(2)} km';
      }
      
      if (duration != null && duration.isNotEmpty) {
        if (statsText.isNotEmpty) statsText += ' • ';
        statsText += duration;
      }
      
      if (statsText.isNotEmpty) {
        return 'Check out my bike ride! ($statsText)\nView detailed summary: $summaryUrl';
      }
    }
    
    return 'Check out my bike ride! View detailed summary: $summaryUrl';
  }
}