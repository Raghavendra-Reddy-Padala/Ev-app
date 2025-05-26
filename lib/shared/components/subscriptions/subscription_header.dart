import 'package:bolt_ui_kit/theme/text_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/subscriptions/subscriptions_model.dart';
import 'subscription_type_chip.dart';

class SubscriptionHeader extends StatelessWidget {
  final UserSubscriptionData subscription;

  const SubscriptionHeader({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 5.h),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  subscription.name,
                  style: AppTextThemes.bodyLarge().copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.h),
                Text(
                  subscription.bikeType,
                  style: AppTextThemes.bodySmall().copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SubscriptionTypeChip(type: subscription.type),
        ],
      ),
    );
  }
}
