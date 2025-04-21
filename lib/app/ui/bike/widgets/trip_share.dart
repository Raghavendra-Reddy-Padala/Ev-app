import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/models/misc_models.dart';

class TripShareButton extends StatelessWidget {
  final ScreenshotController screenshotController;
  final Trip? tripDetails;
  final bool diffPage;

  const TripShareButton({
    super.key,
    required this.screenshotController,
    required this.tripDetails,
    this.diffPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().screenHeight * 0.02),
      child: ElevatedButton(
        onPressed: () => _handleSharePress(),
        style: ElevatedButton.styleFrom(
          backgroundColor: EVColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.share, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              'Share Summary',
              style: CustomTextTheme.bodyMediumPBold.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSharePress() async {
    try {
      Get.dialog(
        Center(
          child: CircularProgressIndicator(
            color: EVColors.primary,
          ),
        ),
        barrierDismissible: false,
      );

      Uint8List? imageBytes = await _captureScreenshot();
      Get.back();

      if (imageBytes != null && imageBytes.isNotEmpty) {
        final double? distance = tripDetails?.distance;
        final String? duration = tripDetails?.duration as String?;
        await _shareRideSummary(imageBytes);
      } else {
        Get.snackbar(
          "Notice",
          "Couldn't capture screenshot, sharing link only.",
          duration: const Duration(seconds: 3),
        );
        await _shareRideSummaryLinkOnly();
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "An error occurred: $e");
    }
  }

  Future<Uint8List?> _captureScreenshot() async {
    if (diffPage) {
      return await _captureFromNewPage();
    } else {
      return await _captureInPlace();
    }
  }

  Future<Uint8List?> _captureFromNewPage() async {
    final ScreenshotController newScreenshotController = ScreenshotController();

    Get.to(
      () => ScreenshotView(
        details: tripDetails!,
        screenshotController: newScreenshotController,
      ),
      preventDuplicates: false,
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final bytes = await newScreenshotController.capture(
          delay: const Duration(milliseconds: 300),
          pixelRatio: 2.0,
        );
        if (bytes != null && bytes.isNotEmpty) {
          Get.back();
          return bytes;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Screenshot attempt $attempt failed: $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    Get.back();
    return null;
  }

  Future<Uint8List?> _captureInPlace() async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final bytes = await screenshotController.capture(
          delay: const Duration(milliseconds: 300),
          pixelRatio: 2.0,
        );
        if (bytes != null && bytes.isNotEmpty) return bytes;
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Screenshot attempt $attempt failed: $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
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
      final String rideId =
          tripDetails?.id ?? 'ride_${DateTime.now().millisecondsSinceEpoch}';
      final String summaryUrl =
          'https://ev.coffeecodes.in/v1/trips/summary/$rideId';
      final shareText =
          'Check out my bike ride! View detailed summary: $summaryUrl';
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: shareText,
        subject: 'My Bike Ride Summary',
      );
    } catch (e) {
      debugPrint('Error sharing ride summary: $e');
      Get.snackbar("Sharing Error", "Couldn't share your ride: $e");

      await _shareRideSummaryLinkOnly();
    }
  }

  Future<void> _shareRideSummaryLinkOnly() async {
    try {
      final String rideId =
          tripDetails?.id ?? 'ride_${DateTime.now().millisecondsSinceEpoch}';
      final String summaryUrl =
          'https://ev.coffeecodes.in/v1/trips/summary/$rideId';
      final shareText =
          'Check out my bike ride! View detailed summary: $summaryUrl';

      await Share.share(
        shareText,
        subject: 'My Bike Ride Summary',
      );
    } catch (e) {
      Get.snackbar("Sharing Error", "Couldn't share your ride link: $e");
    }
  }
}
