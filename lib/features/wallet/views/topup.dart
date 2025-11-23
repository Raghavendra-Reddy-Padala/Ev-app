import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mjollnir/features/wallet/controller/wallet_controller.dart';
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

  const WalletTopup({super.key, required this.balance});

  @override
  State<WalletTopup> createState() => _WalletTopupState();
}

class _WalletTopupState extends State<WalletTopup> {
  final TextEditingController _amountController = TextEditingController();
  final WalletController controller = Get.find<WalletController>();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? selectedAmount;

  void _proceedWithTopUp() {
    if (_amountController.text.isEmpty) {
      Get.snackbar("Error", "Please enter an amount");
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar("Error", "Please enter a valid amount");
      return;
    }

    if (amount < 1) {
      Get.snackbar("Error", "Minimum amount is ₹1");
      return;
    }

    if (amount > 100000) {
      Get.snackbar("Error", "Maximum amount is ₹1,00,000");
      return;
    }

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
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _processTopUp();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _processTopUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await controller.topUpWallet(_amountController.text);
      
      
    } catch (e) {
      print("Top-up error: $e");
      Get.snackbar("Error", "Failed to process top-up: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildQuickAmountButtons() {
    final amounts = ['50', '100', '200', '500'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Amount',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(56, 68, 76, 1),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: amounts.map((amount) {
            bool isSelected = selectedAmount == amount;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAmount = amount;
                  _amountController.text = amount;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '+$amount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 55.0,
        titleSpacing: 30.0,
        title: Text(
          'Wallet', 
          style: AppTextThemes.bodyMedium().copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          )
        ),
        leading: IconButton(
          padding: EdgeInsets.only(left: 20.w),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            SizedBox(height: 20.h),
            Obx(() => amountBanner(controller.walletData.value?.balance.toInt() ?? 0)),
            SizedBox(height: 20.h),
            
            // Quick Amount Buttons
            _buildQuickAmountButtons(),
            SizedBox(height: 20.h),
            
            Text(
              'Custom Amount',
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
              onChanged: (value) {
                setState(() {
                  selectedAmount = null; // Clear quick amount selection when typing
                });
              },
              focusNode: _focusNode,
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTextThemes.bodySmall().copyWith(
                fontWeight: FontWeight.w600,
                color: const Color.fromRGBO(89, 89, 89, 1),
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.currency_rupee),
                hintText: 'Enter amount (Min: ₹1, Max: ₹1,00,000)',
                hintStyle: AppTextThemes.bodySmall().copyWith(
                  color: const Color.fromRGBO(130, 130, 130, 1),
                  fontWeight: FontWeight.w600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: (_amountController.text.isEmpty || _isLoading) 
                  ? null 
                  : _proceedWithTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Proceed with Razorpay",
                      style: AppTextThemes.bodyMedium().copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}