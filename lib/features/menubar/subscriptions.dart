import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/subscriptions/subscription_controller.dart';

import '../../shared/components/subscriptions/subscriptions_widget.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  final SubscriptionController subscriptionController =
      Get.find<SubscriptionController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      subscriptionController.fetchUserSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => subscriptionController.refreshUserSubscriptions(),
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: _UI(),
          ),
        ),
      ),
    );
  }
}

class _UI extends StatelessWidget {
  const _UI();

  @override
  Widget build(BuildContext context) {
    final SubscriptionController subscriptionController =
        Get.find<SubscriptionController>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Header(heading: "Subscriptions", size: 35.w),
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Obx(() {
            if (subscriptionController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (subscriptionController.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      subscriptionController.errorMessage.value,
                      style: AppTextThemes.bodyMedium(),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () =>
                          subscriptionController.fetchUserSubscriptions(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final subscription = subscriptionController.userSubscriptions.value;

            if (subscription == null || subscription.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      "No subscriptions found.",
                      style: AppTextThemes.bodyMedium(),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () =>
                          subscriptionController.fetchUserSubscriptions(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return SubscriptionsWidget(subscriptions: subscription);
          }),
        ),
      ],
    );
  }
}
