import 'package:bolt_ui_kit/bolt_kit.dart' as BoltKit;
import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/wallet/controller/wallet_controller.dart';
import 'package:mjollnir/features/wallet/views/topup.dart';
import 'package:mjollnir/features/wallet/views/transactionview.dart';
import 'package:mjollnir/shared/constants/colors.dart';

class WalletMainView extends StatelessWidget {
  const WalletMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: _UI(),
      ),
    );
  }
}

class _UI extends StatefulWidget {
  const _UI();

  @override
  State<_UI> createState() => _UIState();
}

class _UIState extends State<_UI> {
  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.find<WalletController>();
    controller.fetchWalletBalance();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Wallet',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Balance Card
              Obx(() => _buildBalanceCard(controller)),

              SizedBox(height: 30.h),

              // Action Buttons
              _buildActionButtons(controller),

              SizedBox(height: 30.h),

              // Transactions Section
              _buildTransactionsSection(),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F9F1), // Light mint green
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            "₹${(controller.walletData.value?.balance ?? 0.0).toInt()}",
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your Balance',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(WalletController controller) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.to(() => WalletTopup(
                  balance: controller.walletData.value?.balance ?? 0.0));
            },
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Center(
                child: Text(
                  'TOP-UP',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Fixed - should probably navigate to withdraw page
              // Get.to(() => WithdrawView());
             BoltKit.Toast.show(
               message:  "Wallet is Empty. please Top-up your wallet",
               type:BoltKit.ToastType.error,
                duration: Duration(seconds: 2),
              );
            },
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Center(
                child: Text(
                  'Withdraw',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return GestureDetector(
      onTap: () {
        Get.to(() => TransactionView());
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F9F1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Transactions",
              style: AppTextThemes.bodyLarge().copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.black54,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}