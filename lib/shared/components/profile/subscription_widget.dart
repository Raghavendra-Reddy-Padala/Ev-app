import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/subscriptions/subscriptions_model.dart';

class SubscriptionsWidget extends StatelessWidget {
  final List<UserSubscriptionModel> subscriptions;

  const SubscriptionsWidget({
    super.key,
    required this.subscriptions,
  });
  DateTime _parseDate(String dateStr) {
    final List<String> parts = dateStr.split('/');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }
    throw FormatException("Invalid date format", dateStr);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: subscriptions.map((subscription) {
        final DateTime currentDate = DateTime.now();
        final DateTime endDate =
            _parseDate(subscription.userSubscription.endDate);
        final String status =
            endDate.isBefore(currentDate) ? "Expired" : "Active";

        return Padding(
          padding: EdgeInsets.only(bottom: ScreenUtil().screenHeight * 0.02),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.accent1,
              borderRadius:
                  BorderRadius.circular(ScreenUtil().screenHeight * 0.02),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(ScreenUtil().screenHeight * 0.02),
                  child: _Details(subscription: subscription),
                ),
                _StatusFooter(status: status),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Details extends StatelessWidget {
  final UserSubscriptionModel subscription;

  const _Details({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            subscription.subscriptionDetails.name,
            style: AppTextThemes.bodyMedium().copyWith(color: Colors.black),
          ),
        ),
        const Divider(),
        _RowHelper(
          title: "Subscription Charges",
          value:
              "\$${subscription.subscriptionDetails.monthlyFee.toStringAsFixed(2)}",
          style1: AppTextThemes.bodyMedium().copyWith(color: Colors.black),
          style2:AppTextThemes.bodyMedium().copyWith(color: Colors.black),
        ),
        _RowHelper(
          title: "Security Deposit",
          value:
              "\$${subscription.subscriptionDetails.securityDeposit.toStringAsFixed(2)}",
          style1: AppTextThemes.bodyMedium().copyWith(color: Colors.black),
          style2: AppTextThemes.bodyMedium().copyWith(color: Colors.black),
        ),
        _RowHelper(
          title: "Subscription Type",
          value: subscription.subscriptionDetails.type,
          style1: AppTextThemes.bodyMedium().copyWith(color: Colors.black),
          style2: AppTextThemes.bodyMedium().copyWith(color: Colors.black),
        ),
      ],
    );
  }
}

class _StatusFooter extends StatelessWidget {
  final String status;

  const _StatusFooter({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ScreenUtil().screenHeight * 0.02),
          bottomRight: Radius.circular(ScreenUtil().screenHeight * 0.02),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().screenHeight * 0.02,
          vertical: ScreenUtil().screenHeight * 0.01,
        ),
        child: _RowHelper(
          title: "Status",
          value: status,
          style1: AppTextThemes.bodyMedium().copyWith(color: Colors.white),
          style2: AppTextThemes.bodyMedium().copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _RowHelper extends StatelessWidget {
  final String title;
  final String value;
  final TextStyle style1;
  final TextStyle style2;

  const _RowHelper({
    required this.title,
    required this.value,
    required this.style1,
    required this.style2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style1),
        Text(value, style: style2),
      ],
    );
  }
}
