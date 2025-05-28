import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/shared/components/indicators/loading_indicator.dart';
import 'package:mjollnir/shared/components/states/empty_state.dart';
import '../../../shared/components/activity/activity_graph.dart';
import '../../shared/components/activity/activity_state_grid.dart';
import '../../shared/components/header/header.dart';
import '../account/controllers/activity_controller.dart';

class ActivityMainView extends StatelessWidget {
  const ActivityMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 40.h),
        child: Header(heading: 'Activity'),
      ),
      body: GetBuilder<ActivityController>(
        init: ActivityController(),
        builder: (controller) => SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshActivity,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _ActivityContent(controller: controller),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityContent extends StatelessWidget {
  final ActivityController controller;

  const _ActivityContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.tripSummary.value == null) {
        return SizedBox(
          height: 0.8.sh,
          child: const LoadingIndicator(
            type: LoadingType.circular,
            message: 'Loading activity data...',
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty &&
          controller.tripSummary.value == null) {
        return SizedBox(
          height: 0.8.sh,
          child: EmptyState(
            title: 'Failed to load activity',
            subtitle: controller.errorMessage.value,
            icon: Icon(Icons.timeline, size: 64.w, color: Colors.orange),
            buttonText: 'Retry',
            onButtonPressed: controller.refreshActivity,
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildActivityGraph(),
            SizedBox(height: 20.h),
            _buildActivityStats(),
            SizedBox(height: 32.h),
          ],
        ),
      );
    });
  }

  Widget _buildActivityGraph() {
    return Obx(() {
      return ActivityGraphWidget(
        tripSummary: controller.tripSummary.value,
        onDateRangeChanged: controller.setDateRange,
      );
    });
  }

  Widget _buildActivityStats() {
    return Obx(() {
      final summary = controller.tripSummary.value;
      if (summary == null) return const SizedBox();

      return ActivityStatsGrid(
        tripSummary: summary,
        formatTime: controller.formatTime,
        isLoading: controller.isLoading.value,
      );
    });
  }
}
