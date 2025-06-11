import 'package:get/get.dart';
import '../core/storage/local_storage.dart';

class MainPageController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isBikeSubscribed = false.obs;
  final LocalStorage localStorage = Get.find<LocalStorage>();

  @override
  void onInit() {
    super.onInit();
    _checkBikeSubscription();

    // Listen for changes in subscription status
    ever(isBikeSubscribed, (bool status) {
      print(
          '🔄 MainPageController: Bike subscription status changed to: $status');
    });
  }

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
    print('📱 Navigation index updated to: $index');
  }

  void updateSubscriptionStatus(bool status) {
    print(
        '🔄 Updating subscription status from ${isBikeSubscribed.value} to $status');
    isBikeSubscribed.value = status;
    // Force UI update
    update();
  }

  Future<void> _checkBikeSubscription() async {
    try {
      // Use consistent key name - check both variations for backward compatibility
      bool subscriptionStatus = localStorage.getBool('bikeSubscribed') ??
          localStorage.getBool('bike_subscribed') ??
          false;

      print('🔍 MainPageController: Checking bike subscription...');
      print('   - Retrieved status: $subscriptionStatus');
      print('   - Current isBikeSubscribed: ${isBikeSubscribed.value}');

      isBikeSubscribed.value = subscriptionStatus;

      // Force immediate UI update
      update();
    } catch (e) {
      print('❌ Error checking bike subscription: $e');
      isBikeSubscribed.value = false;
    }
  }

  // Method to force refresh subscription status
  Future<void> refreshSubscriptionStatus() async {
    await _checkBikeSubscription();
  }

  // Method to handle trip end cleanup
  Future<void> handleTripEnded() async {
    print('🏁 MainPageController: Handling trip ended...');

    // Reset subscription status
    isBikeSubscribed.value = false;

    // Update local storage with consistent key
    await localStorage.setBool('bikeSubscribed', false);

    // Force UI update
    update();

    print('✅ MainPageController: Trip end cleanup completed');
  }
}
