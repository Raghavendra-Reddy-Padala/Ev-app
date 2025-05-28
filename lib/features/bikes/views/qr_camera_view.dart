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

class _QrCameraViewState extends State<QrCameraView>
    with TickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _isTorchOn = false;

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
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
          if (_isProcessing) _ModernProcessingIndicator(),
          _InstructionText(),
        ],
      ),
    );
  }

  Widget _ModernProcessingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated QR Code Icon with Pulse Effect
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(
                              0.3 + (_pulseController.value * 0.7)),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 40.w,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),

              // Rotating Circular Progress Indicator
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * 3.14159,
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),

              // Animated Text with Typewriter Effect
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.7 + (_pulseController.value * 0.3),
                    child: Text(
                      'Processing QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 8.h),

              // Animated Dots
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      final delay = index * 0.2;
                      final animationValue =
                          (_pulseController.value + delay) % 1.0;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withOpacity(0.3 + (animationValue * 0.7)),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
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

    // Stop the scanner immediately to prevent multiple detections
    await _scannerController.stop();

    setState(() => _isProcessing = true);
    _scaleController.forward();

    try {
      final success = await widget.onScan(qrCode);
      if (success && mounted) {
        final MainPageController mainPageController = Get.find();
        mainPageController.isBikeSubscribed.value = true;

        // Add a slight delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate back on success
        Navigator.of(context).pop();
      } else {
        if (mounted) {
          setState(() => _isProcessing = false);
          _scaleController.reverse();
          // Restart scanner if processing failed
          await _scannerController.start();
        }
      }
    } catch (e) {
      print('Error processing QR code: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        _scaleController.reverse();
        // Restart scanner if error occurred
        await _scannerController.start();
      }
    }
  }
}

// Enhanced Scanner Overlay with Breathing Animation
class _ScannerOverlay extends StatefulWidget {
  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          return Container(
            width: 250.w + (_breathingController.value * 10),
            height: 250.w + (_breathingController.value * 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary
                    .withOpacity(0.6 + (_breathingController.value * 0.4)),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10 + (_breathingController.value * 5),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.r),
              child: CustomPaint(
                painter: _ScannerCornerPainter(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScannerCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    const cornerLength = 25.0;
    const cornerThickness = 4.0;

    // Top-left corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 10, cornerLength, cornerThickness),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 10, cornerThickness, cornerLength),
        const Radius.circular(2),
      ),
      paint,
    );

    // Top-right corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - cornerLength - 10,
          10,
          cornerLength,
          cornerThickness,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - cornerThickness - 10,
          10,
          cornerThickness,
          cornerLength,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Bottom-left corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          10,
          size.height - cornerThickness - 10,
          cornerLength,
          cornerThickness,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          10,
          size.height - cornerLength - 10,
          cornerThickness,
          cornerLength,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Bottom-right corner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - cornerLength - 10,
          size.height - cornerThickness - 10,
          cornerLength,
          cornerThickness,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - cornerThickness - 10,
          size.height - cornerLength - 10,
          cornerThickness,
          cornerLength,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _InstructionText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80.h,
      left: 20.w,
      right: 20.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          'Align QR Code within the scanner frame',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
