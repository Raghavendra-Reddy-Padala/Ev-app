import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/views/profile_main_view.dart';
import 'package:mjollnir/features/bikes/views/qr_scanner.dart';
import 'package:mjollnir/features/friends/views/friends_page.dart';
import 'package:mjollnir/features/home/views/home_main_view.dart';
import 'package:mjollnir/features/wallet/views/walletpage.dart';
import 'package:mjollnir/shared/constants/colors.dart';

import '../core/storage/local_storage.dart';
import '../shared/components/navigation/app_bottom_navbar.dart';
import 'bikes/views/bike_details_view.dart';
import 'main_page_controller.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final MainPageController mainPageController = Get.put(MainPageController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Force initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainPageController.refreshSubscriptionStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Refresh subscription status when app becomes active
    if (state == AppLifecycleState.resumed) {
      mainPageController.refreshSubscriptionStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeMainView(),
      QrScannerView(),
      WalletMainView(),
      FriendsPage(),
      ProfileMainView()
    ];

    return GetBuilder<MainPageController>(
      builder: (controller) {
        return Obx(() {
          print('🏗️ MainPage rebuilding...');
          print('   - Selected index: ${controller.selectedIndex.value}');
          print(
              '   - Is bike subscribed: ${controller.isBikeSubscribed.value}');

          return Scaffold(
            body: IndexedStack(
              index: controller.selectedIndex.value,
              children: [
                pages[0], // Home
                _getSecondPageContent(controller), // QR Scanner or Bike Details
                pages[2], // Wallet
                pages[3], // Friends
                pages[4], // Profile
              ],
            ),
            bottomNavigationBar: Navbar(
              currentIndex: controller.selectedIndex.value,
              onTap: (index) {
                print('🔄 Nav item tapped: $index');
                controller.updateSelectedIndex(index);
              },
              primaryColor: AppColors.primary,
            ),
          );
        });
      },
    );
  }

  Widget _getSecondPageContent(MainPageController controller) {
    // Debug logging
    print('🔍 Determining second page content:');
    print('   - isBikeSubscribed: ${controller.isBikeSubscribed.value}');

    if (controller.isBikeSubscribed.value) {
      print('   - Showing BikeDetailsView');
      return const BikeDetailsView();
    } else {
      print('   - Showing QrScannerView');
      return QrScannerView();
    }
  }
}
