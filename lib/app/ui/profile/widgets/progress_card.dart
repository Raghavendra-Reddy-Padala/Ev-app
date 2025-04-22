import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants.dart';

class UserProgressCard extends StatelessWidget {
  const UserProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();

    return Obx(() {
      if (userController.isLoading.value) {
        return _buildLoadingCard();
      }

      if (userController.errorMessage.isNotEmpty) {
        return _buildErrorCard(userController.errorMessage.value);
      }

      final userData = userController.userData.value;
      if (userData == null) {
        return _buildNoDataCard();
      }

      return _buildProgressCard(context, userData.data.points);
    });
  }

  Widget _buildLoadingCard() {
    return const Card(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Card(
      color: Colors.red[100],
      child: Center(
        child: Text(
          'Error: $errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildNoDataCard() {
    return const Card(
      child: Center(
        child: Text('No user data available'),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, int points) {
    return Card(
      color: EVColors.accent1,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Image.asset('assets/images/11icon.png'),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHelpButton(),
                  _buildProgressBar(points),
                  _buildPointsInfo(points, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(12, 12),
              shape: const CircleBorder(),
              backgroundColor: EVColors.white,
              elevation: 5,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Icon(
              Icons.question_mark,
              size: 8,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(int points) {
    return LinearProgressIndicator(
      value: points.toDouble() / 10,
      backgroundColor: Colors.green[100],
      valueColor: AlwaysStoppedAnimation<Color>(EVColors.green),
      minHeight: 8,
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildPointsInfo(int points, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$points points",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          Text(
            "${10 - points} points to Level 2",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}
