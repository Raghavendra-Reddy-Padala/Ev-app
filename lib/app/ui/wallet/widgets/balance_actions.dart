import 'package:flutter/material.dart';

class BalanceAndActions extends StatelessWidget {
  final double balance;
  final VoidCallback onTopUpPressed;
  final VoidCallback onWithdrawPressed;

  const BalanceAndActions({
    super.key,
    required this.balance,
    required this.onTopUpPressed,
    required this.onWithdrawPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBalanceCard(),
        SizedBox(height: 20.h),
        _buildQuickTopUpOptions(),
        SizedBox(height: 20.h),
        _buildTopUpButton(),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      height: 150.w,
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 249, 241, 1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            BalanceFormatter.formatBalance(balance),
            style: CustomTextTheme.headlineXLargePBold.copyWith(
              color: Colors.black,
              fontSize: 35.sp,
            ),
          ),
          Text(
            'Your Balance',
            style: CustomTextTheme.bodySmallPBold.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTopUpOptions() {
    List<String> actions = ['+50', '+100', '+200', '+500'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return _buildQuickTopUpChip(actions[index]);
      }),
    );
  }

  Widget _buildQuickTopUpChip(String amount) {
    final WalletController controller = Get.find<WalletController>();

    return GestureDetector(
      onTap: () => _handleQuickTopUp(controller, amount),
      child: Chip(
        label: Text(
          amount,
          style: CustomTextTheme.headlineSmallPBold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        side: BorderSide(
          color: Theme.of(Get.context!).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }

  Future<void> _handleQuickTopUp(
      WalletController controller, String amount) async {
    final String cleanAmount = amount.removeAllWhitespace.substring(1);
    final String response = await controller.topUp(cleanAmount);
    final String url = "https://payments.avidia.in/payments/$response";
    Get.to(paymentWeb(url: url));
  }

  Widget _buildTopUpButton() {
    return SizedBox(
      height: 50.h,
      width: ScreenUtil().screenWidth,
      child: ElevatedButton(
        onPressed: onTopUpPressed,
        style: _getTopUpButtonStyle(),
        child: Text(
          'Top Up',
          style: CustomTextTheme.headlineSmallPBold,
        ),
      ),
    );
  }

  ButtonStyle _getTopUpButtonStyle() {
    return Theme.of(Get.context!).elevatedButtonTheme.style!.copyWith(
          backgroundColor: WidgetStateProperty.all(
            const Color.fromRGBO(0, 168, 119, 0.66),
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0.w),
          )),
        );
  }
}
