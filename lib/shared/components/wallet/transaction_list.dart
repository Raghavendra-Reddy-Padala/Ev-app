import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../models/transaction/transaction.dart';
import '../cards/app_cards.dart';
import '../states/empty_state.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isLoading;

  const TransactionList({
    super.key,
    required this.transactions,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateGroup = groupedTransactions.keys.elementAt(index);
        final dateTransactions = groupedTransactions[dateGroup]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 8.h,
              ),
              child: Text(
                dateGroup,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ...dateTransactions.map((transaction) {
              return TransactionCard(transaction: transaction);
            }).toList(),
          ],
        );
      },
    );
  }

  Map<String, List<Transaction>> _groupTransactionsByDate() {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
      if (!grouped.containsKey(transaction.date)) {
        grouped[transaction.date] = [];
      }
      grouped[transaction.date]!.add(transaction);
    }

    return grouped;
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: AppCard(
            child: Container(
              height: 70.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade100,
                    Colors.grey.shade300,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      title: "No Transactions Yet",
      subtitle: "Your transaction history will appear here",
      icon: Icon(
        Icons.receipt_long_outlined,
        size: 64.w,
        color: Colors.grey,
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final Color amountColor = transaction.isDeposit ? Colors.green : Colors.red;
    final IconData icon = transaction.isDeposit
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return AppCard(
      margin: EdgeInsets.only(bottom: 8.h, left: 16.w, right: 16.w),
      padding: EdgeInsets.all(12.w),
      elevation: CardElevation.none,
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: amountColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.details,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatTime(transaction.date),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(transaction.amount, transaction.isDeposit),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(String amount, bool isDeposit) {
    final cleanAmount = amount.replaceAll(' rs', '').trim();

    try {
      final double amountValue = double.parse(cleanAmount);
      final formatter = NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 2,
        locale: 'en_IN',
      );

      return "${isDeposit ? '+' : '-'}${formatter.format(amountValue.abs())}";
    } catch (e) {
      return "${isDeposit ? '+' : '-'}₹$cleanAmount";
    }
  }

  String _formatTime(String dateString) {
    try {
      final parts = dateString.split(' ');
      if (parts.length > 1) {
        return parts[1];
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }
}
