import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';
import '../cards/app_cards.dart';
import '../badges/text_badges.dart';
import '../buttons/app_button.dart';

class InviteFriendsCard extends StatelessWidget {
  final String referralCode;
  final VoidCallback onCopyCode;
  final VoidCallback onShare;
  final String? benefitsText;

  const InviteFriendsCard({
    Key? key,
    required this.referralCode,
    required this.onCopyCode,
    required this.onShare,
    this.benefitsText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.accent1,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add_alt_rounded, size: 24.w, color: Colors.black),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invite Friends",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (referralCode.isNotEmpty)
                      Row(
                        children: [
                          Text(
                            "Your code: ",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextBadge(
                            text: referralCode,
                            type: BadgeType.primary,
                            size: BadgeSize.small,
                            onTap: onCopyCode,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.grey[600]),
                onPressed: onCopyCode,
              ),
            ],
          ),
          if (benefitsText != null && benefitsText!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                benefitsText!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          AppButton(
            text: "Share with friends",
            onPressed: onShare,
            prefixIcon: Icon(Icons.share, size: 18.w),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
