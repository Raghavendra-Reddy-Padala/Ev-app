import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/wallet/controller/wallet_controller.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DodoCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;
  final String paymentId;
  final String amount;

  const DodoCheckoutScreen({
    super.key,
    required this.checkoutUrl,
    required this.paymentId,
    required this.amount,
  });

  @override
  State<DodoCheckoutScreen> createState() => _DodoCheckoutScreenState();
}

class _DodoCheckoutScreenState extends State<DodoCheckoutScreen> {
  late final WebViewController _webViewController;
  final WalletController _walletController = Get.find<WalletController>();
  bool _isLoading = true;
  String _paymentStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));

    // Start polling for payment status
    _walletController.startPollingPaymentStatus(
      widget.paymentId,
      onStatusChange: (status) {
        if (mounted) {
          setState(() => _paymentStatus = status);
          _showPaymentResult(status);
        }
      },
    );
  }

  @override
  void dispose() {
    _walletController.stopPollingPaymentStatus();
    super.dispose();
  }

  void _showPaymentResult(String status) {
    if (!mounted) return;

    final isSuccess = status == 'success';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? AppColors.primary : Colors.red,
              size: 64,
            ),
            SizedBox(height: 16.h),
            Text(
              isSuccess ? 'Payment Successful!' : 'Payment Failed',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isSuccess
                  ? 'Your wallet has been topped up with ₹${widget.amount}'
                  : 'The payment could not be processed. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.back(); // Go back to wallet
                if (isSuccess) {
                  Get.back(); // Also go back from topup screen
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? AppColors.primary : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                isSuccess ? 'Done' : 'Try Again',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment?'),
                content: const Text(
                  'Are you sure you want to cancel this payment?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.back();
                    },
                    child: const Text('Yes, Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
