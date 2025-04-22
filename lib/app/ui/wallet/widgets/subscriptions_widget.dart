import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/constants.dart';
import '../../../utils/theme.dart';

class SubscriptionsWidget extends StatelessWidget {
  final List<UserSubscriptionModel> subscriptions;

  const SubscriptionsWidget({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: subscriptions
          .map((subscription) => _buildSubscriptionCard(subscription))
          .toList(),
    );
  }

  Widget _buildSubscriptionCard(UserSubscriptionModel subscription) {
    final DateTime currentDate = DateTime.now();
    final DateTime endDate = _parseDate(subscription.userSubscription.endDate);
    final String status = endDate.isBefore(currentDate) ? "Expired" : "Active";

    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().screenHeight * 0.02),
      child: Container(
        decoration: BoxDecoration(
          color: EVColors.accent1,
          borderRadius: BorderRadius.circular(ScreenUtil().screenHeight * 0.02),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(ScreenUtil().screenHeight * 0.02),
              child: SubscriptionDetailsSection(subscription: subscription),
            ),
            StatusFooter(status: status),
          ],
        ),
      ),
    );
  }

  DateTime _parseDate(String dateStr) {
    final List<String> parts = dateStr.split('/');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]), // Year
        int.parse(parts[1]), // Month
        int.parse(parts[0]), // Day
      );
    }
    throw FormatException("Invalid date format", dateStr);
  }
}

class SubscriptionDetailsSection extends StatelessWidget {
  final UserSubscriptionModel subscription;

  const SubscriptionDetailsSection({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            subscription.subscriptionDetails.name,
            style: CustomTextTheme.bodyMediumP.copyWith(color: Colors.black),
          ),
        ),
        const Divider(),
        SubscriptionInfoRow(
          title: "Subscription Charges",
          value:
              "\$${subscription.subscriptionDetails.monthlyFee.toStringAsFixed(2)}",
        ),
        SubscriptionInfoRow(
          title: "Security Deposit",
          value:
              "\$${subscription.subscriptionDetails.securityDeposit.toStringAsFixed(2)}",
        ),
        SubscriptionInfoRow(
          title: "Subscription Type",
          value: subscription.subscriptionDetails.type,
        ),
      ],
    );
  }
}

class SubscriptionInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const SubscriptionInfoRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: CustomTextTheme.bodyMediumP.copyWith(color: Colors.black)),
        Text(value,
            style: CustomTextTheme.bodyMediumP.copyWith(color: Colors.black)),
      ],
    );
  }
}

class StatusFooter extends StatelessWidget {
  final String status;

  const StatusFooter({super.key, required this.status});

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Status",
              style: CustomTextTheme.bodyMediumP.copyWith(color: Colors.white),
            ),
            Text(
              status,
              style: CustomTextTheme.bodyMediumP.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
