import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/navigation/navigation_service.dart';
import 'package:mjollnir/features/wallet/controller/wallet_controller.dart';
import 'package:mjollnir/features/wallet/views/topup.dart';
import 'package:mjollnir/features/wallet/views/transactionview.dart';
import 'package:mjollnir/shared/components/wallet/wallet_balance_card.dart';
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

class _UI extends StatelessWidget {
  const _UI();

  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.find<WalletController>();
    controller.fetchWalletBalance();
    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.all(10.w),
        child: ListView(
          children: [
            Text("Wallet", style: AppTextThemes.bodyMedium().copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            )),
            SizedBox(height:5.h),
            Obx(
              () => WalletBalanceCard(
                onWithdraw: () => controller.transactions,
onQuickAmountSelected: (String amount) async {
      await controller.topUpWallet(amount); 
    },
                    balance: controller.walletData.value?.balance.toDouble() ?? 0.0,
                onTopUp: () => NavigationService.pushTo(
                    WalletTopup(balance:  controller.walletData.value?.balance ?? 0.0,
                    ))),

              ),
  

            SizedBox(height:20.h),
            GestureDetector(
              onTap: () {
                NavigationService.pushTo(
                  const TransactionView(),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accent1,
                  borderRadius:
                      BorderRadius.circular(10.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transactions",
                        style: AppTextThemes.bodyLarge().copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
