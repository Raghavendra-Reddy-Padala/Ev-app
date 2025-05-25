import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/main_page_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../shared/constants/colors.dart';

class QrCameraView extends StatefulWidget {
  final Future<bool> Function(String) onScan;

  const QrCameraView({super.key, required this.onScan});

  @override
  State<QrCameraView> createState() => _QrCameraViewState();
}

class _QrCameraViewState extends State<QrCameraView> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _isTorchOn = false;

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
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? Colors.yellow : Colors.white,
            ),
            onPressed: _toggleTorch,
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

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      print('Error toggling torch: $e');
    }
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

        // Navigate back on success
        Navigator.of(context).pop();
      } else {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      print('Error processing QR code: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              17.r), // Slightly smaller to account for border
          child: CustomPaint(
            painter: _ScannerCornerPainter(),
          ),
        ),
      ),
    );
  }
}

class _ScannerCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    const cornerLength = 20.0;
    const cornerThickness = 3.0;

    // Top-left corner
    canvas.drawRect(
      const Rect.fromLTWH(10, 10, cornerLength, cornerThickness),
      paint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(10, 10, cornerThickness, cornerLength),
      paint,
    );

    // Top-right corner
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - cornerLength - 10,
        10,
        cornerLength,
        cornerThickness,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - cornerThickness - 10,
        10,
        cornerThickness,
        cornerLength,
      ),
      paint,
    );

    // Bottom-left corner
    canvas.drawRect(
      Rect.fromLTWH(
        10,
        size.height - cornerThickness - 10,
        cornerLength,
        cornerThickness,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        10,
        size.height - cornerLength - 10,
        cornerThickness,
        cornerLength,
      ),
      paint,
    );

    // Bottom-right corner
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - cornerLength - 10,
        size.height - cornerThickness - 10,
        cornerLength,
        cornerThickness,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - cornerThickness - 10,
        size.height - cornerLength - 10,
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
              strokeWidth: 3,
            ),
            SizedBox(height: 20.h),
            Text(
              'Processing QR Code...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
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
      bottom: 80.h,
      left: 20.w,
      right: 20.w,
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
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
