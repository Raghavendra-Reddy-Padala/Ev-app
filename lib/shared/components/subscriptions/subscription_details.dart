import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/subscriptions/subscriptions_model.dart';
import 'helpers.dart';

class SubscriptionDetailsWidget extends StatelessWidget {
  final UserSubscriptionData subscription;

  const SubscriptionDetailsWidget({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.attach_money,
            label: "Monthly Fee",
            value: "₹${subscription.monthlyFee.toStringAsFixed(2)}",
            iconColor: Colors.green.shade600,
          ),
          SizedBox(height: 12.h),
          _DetailRow(
            icon: Icons.security,
            label: "Security Deposit",
            value: "₹${subscription.securityDeposit.toStringAsFixed(2)}",
            iconColor: Colors.blue.shade600,
          ),
          SizedBox(height: 12.h),
          _DetailRow(
            icon: Icons.calendar_today,
            label: "Duration",
            value: _formatDateRange(),
            iconColor: Colors.purple.shade600,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  String _formatDateRange() {
    final startDate = DateHelper.parseDate(subscription.startDate);
    final endDate = DateHelper.parseDate(subscription.endDate);
    return "${DateHelper.formatShortDate(startDate)} - ${DateHelper.formatShortDate(endDate)}";
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextThemes.bodyMedium().copyWith(
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextThemes.bodyMedium().copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
