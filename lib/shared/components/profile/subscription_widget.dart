import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';
import '../badges/text_badges.dart';

class SubscriptionCard extends StatelessWidget {
  final String name;
  final double monthlyFee;
  final double securityDeposit;
  final String type;
  final String startDate;
  final String endDate;
  final bool isActive;

  const SubscriptionCard({
    Key? key,
    required this.name,
    required this.monthlyFee,
    required this.securityDeposit,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildHeader(),
          Divider(height: 1, thickness: 1),
          _buildDetails(),
          _buildStatusFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.accent1,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildDetailRow('Subscription Charges',
              '\$${monthlyFee.toStringAsFixed(2)}/month'),
          SizedBox(height: 8.h),
          _buildDetailRow(
              'Security Deposit', '\$${securityDeposit.toStringAsFixed(2)}'),
          SizedBox(height: 8.h),
          _buildDetailRow('Subscription Type', type),
          SizedBox(height: 8.h),
          _buildDetailRow('Valid Period', '$startDate to $endDate'),
        ],
      ),
    );
  }

  Widget _buildStatusFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.grey.shade300,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Status',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          TextBadge(
            text: isActive ? 'Active' : 'Expired',
            type: isActive ? BadgeType.success : BadgeType.neutral,
            size: BadgeSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
