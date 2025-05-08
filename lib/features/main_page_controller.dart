import 'package:get/get.dart';
import '../core/storage/local_storage.dart';

class MainPageController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isBikeSubscribed = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkBikeSubscription();
  }

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  void updateSubscriptionStatus(bool status) {
    isBikeSubscribed.value = status;
  }

  Future<void> _checkBikeSubscription() async {
    final localStorage = Get.find<LocalStorage>();
    isBikeSubscribed.value = localStorage.getBool('bike_subscribed');
  }
}
