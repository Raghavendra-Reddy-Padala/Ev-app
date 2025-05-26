import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/components/subscriptions/divider.dart';

import '../../constants/colors.dart';
import '../../models/subscriptions/subscriptions_model.dart';
import 'helpers.dart';
import 'subscription_details.dart';
import 'subscription_footer.dart';
import 'subscription_header.dart';

class SubscriptionCard extends StatelessWidget {
  final UserSubscriptionData subscription;
  final VoidCallback? onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = SubscriptionStatusHelper.getStatus(subscription);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.accent1,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubscriptionHeader(subscription: subscription),
              DividerWidget(),
              SubscriptionDetailsWidget(subscription: subscription),
              SubscriptionFooter(status: subscriptionStatus),
            ],
          ),
        ),
      ),
    );
  }
}
