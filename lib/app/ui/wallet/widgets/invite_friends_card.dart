import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants.dart';
import '../../../utils/theme.dart';

class InviteFriendsCard extends StatelessWidget {
  const InviteFriendsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final InviteCodeController controller = Get.find<InviteCodeController>();

    return Obx(() => Card(
          color: EVColors.accent1,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildInviteRow(controller),
                _buildErrorMessage(controller),
                _buildBenefitsDescription(controller),
              ],
            ),
          ),
        ));
  }

  Widget _buildInviteRow(InviteCodeController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildInviteButton(controller),
        ),
        _buildCopyButton(controller),
      ],
    );
  }

  Widget _buildInviteButton(InviteCodeController controller) {
    return GestureDetector(
      onTap: () => controller.shareReferralCode(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/add_friend.png'),
          const SizedBox(width: 8),
          Text(
            'Invite Friends',
            style: CustomTextTheme.bodySmallPBold.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(InviteCodeController controller) {
    if (controller.isLoading.value) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: EVColors.greytext,
        ),
      );
    }

    return GestureDetector(
      onTap: () => controller.shareReferralCode(),
      child: Icon(
        Icons.copy,
        color: EVColors.greytext,
      ),
    );
  }

  Widget _buildErrorMessage(InviteCodeController controller) {
    if (controller.errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        controller.errorMessage.value,
        style: CustomTextTheme.bodySmallP.copyWith(color: Colors.red),
      ),
    );
  }

  Widget _buildBenefitsDescription(InviteCodeController controller) {
    if (controller.benefits.value == null ||
        controller.benefits.value!.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        controller.benefits.value!.description,
        style: CustomTextTheme.bodySmallP.copyWith(color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }
}
