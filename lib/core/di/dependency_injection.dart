import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:mjollnir/features/authentication/controller/auth_controller.dart';
import 'package:mjollnir/features/authentication/controller/loc_controller.dart';
import 'package:mjollnir/features/bikes/controller/bike_metrics_controller.dart';
import 'package:mjollnir/features/bikes/controller/qr_controller.dart';
import 'package:mjollnir/features/bikes/controller/trips_control_service.dart';
import 'package:mjollnir/features/friends/controller/follow_controller.dart';
import 'package:mjollnir/shared/subscriptions/subscription_controller.dart';

import '../../features/account/controllers/user_controller.dart';
import '../../features/bikes/controller/bike_controller.dart';
import '../../features/friends/controller/groups_controller.dart';
import '../../features/home/controller/station_controller.dart';
import '../../features/main_page_controller.dart';
import '../../features/wallet/controller/wallet_controller.dart';
import '../storage/local_storage.dart';

Future<void> setupDependencies() async {
  final localStorage = LocalStorage();
  await localStorage.init();
  Get.put(localStorage);
  Get.put(LocationController());
  Get.put(MainPageController());
  Get.put(UserController());
  Get.put(GroupController());
  Get.put(WalletController());
  Get.put(StationController());
  Get.put(AuthController());
  Get.put(TripsController());

  Get.put(BikeController());
  Get.put(BikeMetricsController());
  Get.put(TripControlService());
  Get.put(QrScannerController());
  Get.put(StationController());
  Get.put(SubscriptionController());
  Get.put(FollowController());
}
