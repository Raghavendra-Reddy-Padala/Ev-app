import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mjollnir/features/wallet/controller/wallet_controller.dart';
import 'package:mjollnir/shared/components/payment/payment_web.dart';
import 'package:mjollnir/shared/constants/colors.dart';

String formatBalance(double balance) {
  if (balance >= 1000000000) {
    return '₹ ${(balance / 1000000000).toStringAsFixed(1)}B';
  } else if (balance >= 1000000) {
    return '₹ ${(balance / 1000000).toStringAsFixed(1)}M';
  } else if (balance >= 1000) {
    return '₹ ${(balance / 1000).toStringAsFixed(1)}K';
  } else {
    return "₹ ${balance.toString()}";
  }
}

Widget amountBanner(int balance) {
  final WalletController controller = Get.find<WalletController>();
  return Container(
    height: 95.h,
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 249, 241, 1),
        borderRadius: BorderRadius.circular(10.r)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          formatBalance(controller.walletData.value?.balance.toDouble() ?? 0.0),
          style: AppTextThemes.bodyLarge().copyWith(
            fontSize: 25.h,
            color: Colors.black,
          ),
        ),
        Text(
          'Your Balance',
          style: AppTextThemes.bodySmall().copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}

class WalletTopup extends StatefulWidget {
  final double balance;

  WalletTopup({super.key, required this.balance});

  @override
  State<WalletTopup> createState() => _WalletTopupState();
}

class _WalletTopupState extends State<WalletTopup> {
  final TextEditingController _amountController = TextEditingController();
  final WalletController controller = Get.find<WalletController>();
  final _focusNode = FocusNode();

  void _proceedWithTopUp() {
    _focusNode.unfocus();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Payment"),
          content: Text(
              "Do you want to proceed with the top-up of ₹${_amountController.text}?"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
                child: const Text("Confirm"),
                onPressed: () async {
                  final String? response =
                      await controller.topUpWallet(_amountController.text);
                  String url =
                      "https://payments.avidia.in/payments/$response";
                  Get.back();
                  Get.to(paymentWeb(url: url));
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.find<WalletController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 55.0,
        titleSpacing: 30.0,
        title: Text('Wallet', style: AppTextThemes.bodyMedium().copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        )),
        leading: IconButton(
          padding: EdgeInsets.only(left: 20.w),
          icon: Image.asset('assets/images/back_green.png'),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => amountBanner(controller.walletData.value?.balance.toInt() ?? 0) ),
            Text(
              'Top - Up',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(56, 68, 76, 1),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              onChanged: (value) => setState(() {}),
              focusNode: _focusNode,
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTextThemes.bodySmall().copyWith(
                fontWeight: FontWeight.w600,
                color: const Color.fromRGBO(89, 89, 89, 1),
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.currency_rupee),
                hintText: 'Enter amount',
                hintStyle: AppTextThemes.bodySmall().copyWith(
                  color: const Color.fromRGBO(130, 130, 130, 1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed:
                  _amountController.text == "" ? null : _proceedWithTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48.0),
              ),
              child: Text("Proceed",
                  style: AppTextThemes.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
