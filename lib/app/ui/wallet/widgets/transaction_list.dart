import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/helpers.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(index, transactions, transaction),
            TransactionItem(transaction: transaction),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(
      int index, List<Transaction> transactions, Transaction transaction) {
    if (index == 0 || transactions[index - 1].date != transaction.date) {
      return Padding(
        padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
        child: Text(
          transaction.date,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color.fromRGBO(130, 130, 130, 1),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final String formattedAmount = _formatAmount();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: ListTile(
        title: Text(
          transaction.details,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color.fromRGBO(75, 75, 75, 1),
          ),
        ),
        subtitle: Text(
          transaction.date,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        trailing: Text(
          "${transaction.isDeposit ? '+' : '-'}₹$formattedAmount",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: transaction.isDeposit ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  String _formatAmount() {
    final String formattedBalance =
        BalanceFormatter.formatTransactionAmount(transaction.amount);

    if (formattedBalance.startsWith('-')) {
      return formattedBalance.substring(1);
    }

    return formattedBalance;
  }
}
