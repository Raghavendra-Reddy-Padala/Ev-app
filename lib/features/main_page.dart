import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/home/views/home_main_view.dart';
import 'package:mjollnir/shared/constants/colors.dart';

import '../core/storage/local_storage.dart';
import '../shared/components/navigation/app_bottom_navbar.dart';
import 'main_page_controller.dart';

class MainPage extends StatelessWidget {
  final MainPageController mainPageController = Get.put(MainPageController());

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeMainView(),
      const Placeholder(),
      // QrScanView(onSuccess: () {
      //   mainPageController.updateSubscriptionStatus(true);
      // }),
      const Placeholder(),
      const Placeholder(),
      const Placeholder(),
    ];

    _checkBikeSubscription();

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: mainPageController.selectedIndex.value,
          children: [
            pages[0],
            pages[1],
            // mainPageController.isBikeSubscribed.value
            //     ? const BikeDetails()
            //     : pages[1],
            pages[2],
            pages[3],
            pages[4],
          ],
        ),
        bottomNavigationBar: Navbar(
          currentIndex: mainPageController.selectedIndex.value,
          onTap: (index) => mainPageController.updateSelectedIndex(index),
          primaryColor: AppColors.primary,
        ),
      );
    });
  }

  void _checkBikeSubscription() async {
    LocalStorage sharedPreferencesService = Get.find();

    mainPageController.updateSubscriptionStatus(
        await sharedPreferencesService.isBikeSubscribed());
  }
}
