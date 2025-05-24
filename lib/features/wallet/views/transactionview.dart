import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/wallet/controller/wallet_controller.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/components/wallet/transaction_list.dart';
import 'package:mjollnir/shared/models/transaction/transaction.dart';

class TransactionView extends StatelessWidget {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController transactionController =
        Get.find<WalletController>();
    transactionController.transactions();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.h),
          child: _UI(),
        ),
      ),
    );
  }
}

class _UI extends StatelessWidget {
  const _UI();

  @override
  Widget build(BuildContext context) {
    final WalletController transactionController =
        Get.find<WalletController>();

    return Obx(() {
      if (transactionController.transactions == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final fetchedTransactions =
          transactionController.transactions;
      if (fetchedTransactions == null || fetchedTransactions.isEmpty) {
        return const Center(
          child: Text('No transactions found.'),
        );
      }
      // final List<Transaction> transactions = fetchedTransactions.map((t) {
      //   return Transaction(
      //     time: DateFormat('h:mm a').format(t.timestamp),
      //     details: t.description,
      //     amount: t.type == 'CREDIT' ? '+${t.amount} rs' : '-${t.amount} rs',
      //     date: DateFormat('yyyy-MM-dd').format(t.timestamp),
      //     isDeposit: t.type == 'CREDIT',
      //   );
      // }).toList();
      //

      final List<Transaction> transactions = (fetchedTransactions
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp)))
          .map((t) => Transaction(
            id: t.id,
                userId: t.userId,
                amount: t.amount,
                type: t.type,
                description: t.description,
                timestamp: t.timestamp,
               
              ))
          .toList();

      return SingleChildScrollView(
        child: Column(
          children: [
            const Header(heading: "Transactions"),
            SizedBox(height: 10.h),
            TransactionList(transactions: transactions),
            SizedBox(
              height: 40.h,
            )
          ],
        ),
      );
    });
  }
}
