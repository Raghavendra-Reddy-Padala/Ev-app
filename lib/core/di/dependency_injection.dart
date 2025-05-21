import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:mjollnir/features/authentication/controller/auth_controller.dart';
import 'package:mjollnir/features/authentication/controller/loc_controller.dart';

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

  Get.put(MainPageController());
  Get.put(UserController());
  Get.put(GroupController());
  Get.put(WalletController());
  Get.put(StationController());
  Get.put(AuthController());
  Get.put(BikeController());
  Get.put(TripsController());
  Get.put(LocationController());
  Get.put(TripsController());
  Get.put(StationController());
  
  
}
