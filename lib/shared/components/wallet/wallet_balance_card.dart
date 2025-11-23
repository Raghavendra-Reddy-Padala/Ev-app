// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../buttons/app_button.dart';
// import '../cards/app_cards.dart';

// class WalletBalanceCard extends StatelessWidget {
//   final double balance;
//   final VoidCallback onTopUp;
//   final VoidCallback onWithdraw;
//   final List<String> quickAmounts;
//   final Function(String) onQuickAmountSelected;

//   const WalletBalanceCard({
//     super.key,
//     required this.balance,
//     required this.onTopUp,
//     required this.onWithdraw,
//     this.quickAmounts = const ['50', '100', '200', '500'],
//     required this.onQuickAmountSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppCard(
//       padding: EdgeInsets.all(16.w),
//       backgroundColor: const Color(0xFFE8F9F1), // Light green background
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           _buildBalanceDisplay(),
//           SizedBox(height: 20.h),
//           _buildQuickAmounts(),
//           SizedBox(height: 20.h),
//           AppButton(
//             text: 'Top Up',
//             onPressed: onTopUp,
//             fullWidth: true,
//           ),
//           SizedBox(height: 12.h),
//           AppButton(
//             text: 'Withdraw',
//             type: ButtonType.outline,
//             onPressed: onWithdraw,
//             fullWidth: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBalanceDisplay() {
//     return Column(
//       children: [
//         Text(
//           formatBalance(balance),
//           style: TextStyle(
//             fontSize: 36.sp,
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//         Text(
//           'Your Balance',
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade700,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickAmounts() {
//     return Wrap(
//       spacing: 10.w,
//       children: quickAmounts.map((amount) {
//         return ActionChip(
//           label: Text(
//             '+$amount',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           backgroundColor: Colors.white,
//           elevation: 0,
//           side: BorderSide(color: Colors.grey.shade300),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.r),
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//           onPressed: () => onQuickAmountSelected(amount),
//         );
//       }).toList(),
//     );
//   }

//   String formatBalance(double balance) {
//     if (balance >= 1000000000) {
//       return '₹ ${(balance / 1000000000).toStringAsFixed(1)}B';
//     } else if (balance >= 1000000) {
//       return '₹ ${(balance / 1000000).toStringAsFixed(1)}M';
//     } else if (balance >= 1000) {
//       return '₹ ${(balance / 1000).toStringAsFixed(1)}K';
//     } else {
//       return "₹ ${balance.toStringAsFixed(2)}";
//     }
//   }
// }
