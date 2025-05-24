import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:mjollnir/core/routes/app_routes.dart';
import 'package:mjollnir/features/main_page_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../shared/constants/colors.dart';

class QrCameraView extends StatefulWidget {
  final Future<bool> Function(String) onScan;

  const QrCameraView({super.key, required this.onScan});

  @override
  State<QrCameraView> createState() => _QrCameraViewState();
}

class _QrCameraViewState extends State<QrCameraView> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                  color: state == TorchState.off ? Colors.white : Colors.yellow,
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleDetection,
          ),
          _ScannerOverlay(),
          if (_isProcessing) _ProcessingIndicator(),
          _InstructionText(),
        ],
      ),
    );
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing || capture.barcodes.isEmpty) return;

    final String? qrCode = capture.barcodes.first.rawValue;
    if (qrCode == null) return;

    setState(() => _isProcessing = true);

    try {
      final success = await widget.onScan(qrCode);
      if (success && mounted) {
        final MainPageController mainPageController = Get.find();
        mainPageController.isBikeSubscribed.value = true;
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
    }
  }
}

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250.w,
        height: 250.w,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: CustomPaint(
          painter: _ScannerCornerPainter(),
        ),
      ),
    );
  }
}

class _ScannerCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const cornerLength = 30.0;
    const cornerThickness = 4.0;

    // Top-left corner
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, cornerLength, cornerThickness),
      paint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, cornerThickness, cornerLength),
      paint,
    );

    // Top-right corner
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - cornerLength,
        0,
        cornerLength,
        cornerThickness,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - cornerThickness,
        0,
        cornerThickness,
        cornerLength,
      ),
      paint,
    );

    // Bottom-left corner
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height - cornerThickness,
        cornerLength,
        cornerThickness,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height - cornerLength,
        cornerThickness,
        cornerLength,
      ),
      paint,
    );

    // Bottom-right corner
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - cornerLength,
        size.height - cornerThickness,
        cornerLength,
        cornerThickness,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - cornerThickness,
        size.height - cornerLength,
        cornerThickness,
        cornerLength,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _ProcessingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 20.h),
            Text(
              'Processing QR Code...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Text(
            'Align QR Code within the scanner frame',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
