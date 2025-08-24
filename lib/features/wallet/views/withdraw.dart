import 'package:bolt_ui_kit/bolt_kit.dart' as BoltKit;
import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/constants/colors.dart';

class WithdrawView extends StatefulWidget {
  final double currentBalance;
  
  const WithdrawView({
    super.key,
    required this.currentBalance,
  });

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  String selectedMethod = 'Bank Transfer';
  
  final List<String> withdrawMethods = [
    'Bank Transfer',
    'UPI',
    'PayPal',
    'Digital Wallet'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Withdraw',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Balance Card
              _buildAvailableBalanceCard(),
              
              SizedBox(height: 30.h),
              
              // Withdraw Amount Section
              _buildWithdrawAmountSection(),
              
              SizedBox(height: 25.h),
              
              // Withdraw Method Section
              _buildWithdrawMethodSection(),
              
              SizedBox(height: 25.h),
              
              // Account Details Section
              _buildAccountDetailsSection(),
              
              Spacer(),
              
              // Withdraw Button
              _buildWithdrawButton(),
              
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F9F1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            'Available Balance',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "₹${widget.currentBalance.toInt()}",
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Withdraw Amount',
          style: AppTextThemes.bodyLarge().copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        // Quick amount buttons
        Row(
          children: [
            _buildQuickAmountButton('₹500'),
            SizedBox(width: 10.w),
            _buildQuickAmountButton('₹1000'),
            SizedBox(width: 10.w),
            _buildQuickAmountButton('All'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return GestureDetector(
      onTap: () {
        if (amount == 'All') {
          _amountController.text = widget.currentBalance.toInt().toString();
        } else {
          _amountController.text = amount.replaceAll('₹', '');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          amount,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Withdraw Method',
          style: AppTextThemes.bodyLarge().copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedMethod,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
            items: withdrawMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMethod = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Details',
          style: AppTextThemes.bodyLarge().copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        
        // Account Number/UPI ID field
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _accountController,
            decoration: InputDecoration(
              hintText: selectedMethod == 'UPI' ? 'UPI ID' : 'Account Number',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ),
        
        if (selectedMethod == 'Bank Transfer') ...[
          SizedBox(height: 12.h),
          // IFSC Code field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _ifscController,
              decoration: InputDecoration(
                hintText: 'IFSC Code',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWithdrawButton() {
    return GestureDetector(
      onTap: () {
        _handleWithdraw();
      },
      child: Container(
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(27.5.r),
        ),
        child: Center(
          child: Text(
            'Withdraw Money',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _handleWithdraw() {
    // Mock withdraw logic
    if (_amountController.text.isEmpty) {
      BoltKit.Toast.show(
        message: "Please enter withdraw amount",
        type: BoltKit.ToastType.error,
        duration: Duration(seconds: 2),
      );
      return;
    }

    if (_accountController.text.isEmpty) {
      BoltKit.Toast.show(
        message: "Please enter account details",
        type: BoltKit.ToastType.error,
        duration: Duration(seconds: 2),
      );
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount > widget.currentBalance) {
      BoltKit.Toast.show(
        message: "Insufficient balance",
        type: BoltKit.ToastType.error,
        duration: Duration(seconds: 2),
      );
      return;
    }

    // Show success message and go back
    BoltKit.Toast.show(
      message: "Withdraw request submitted successfully!",
      type: BoltKit.ToastType.success,
      duration: Duration(seconds: 2),
    );
    
    Get.back();
  }
}