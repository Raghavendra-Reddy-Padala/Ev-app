import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/subscriptions/subscriptions_model.dart';

import 'subscription_card.dart';

class SubscriptionsWidget extends StatelessWidget {
  final List<UserSubscriptionData> subscriptions;
  final VoidCallback? onSubscriptionTap;

  const SubscriptionsWidget({
    super.key,
    required this.subscriptions,
    this.onSubscriptionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return const _EmptySubscriptionsView();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subscriptions.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) => SubscriptionCard(
        subscription: subscriptions[index],
        onTap: onSubscriptionTap,
      ),
    );
  }
}

class _EmptySubscriptionsView extends StatelessWidget {
  const _EmptySubscriptionsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.accent1,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.subscriptions,
            size: 48.r,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: 16.h),
          Text(
            'No subscriptions found',
            style: AppTextThemes.bodyMedium().copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
