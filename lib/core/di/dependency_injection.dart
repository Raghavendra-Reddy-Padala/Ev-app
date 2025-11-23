import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/trips_controller.dart';
import 'package:mjollnir/features/authentication/controller/auth_controller.dart';
import 'package:mjollnir/features/authentication/controller/loc_controller.dart';
import 'package:mjollnir/features/bikes/controller/bike_metrics_controller.dart';
import 'package:mjollnir/features/bikes/controller/qr_controller.dart';
import 'package:mjollnir/features/bikes/controller/trips_control_service.dart';
import 'package:mjollnir/features/friends/controller/follow_controller.dart';
import 'package:mjollnir/features/friends/views/individualuserfollowerscontrolller.dart';
import 'package:mjollnir/shared/faq/faq_controller.dart';
import 'package:mjollnir/shared/issues/issuecontroller.dart';
import 'package:mjollnir/shared/subscriptions/subscription_controller.dart';

import '../../features/account/controllers/user_controller.dart';
import '../../features/bikes/controller/bike_controller.dart';
import '../../features/friends/controller/groups_controller.dart';
import '../../features/home/controller/station_controller.dart';
import '../../features/main_page_controller.dart';
import '../../features/wallet/controller/wallet_controller.dart';
import '../storage/local_storage.dart';

Future<void> setupDependencies() async {
  final localStorage = Get.put(LocalStorage());
  await localStorage.init();
  
  // Core controllers that don't require authentication
  Get.put(LocationController());
  Get.put(AuthController());
  Get.put(FaqController());
  Get.put(IssueController());
  
  Get.lazyPut<BikeController>(() => BikeController());
  Get.lazyPut<BikeMetricsController>(() => BikeMetricsController());
  Get.lazyPut<TripControlService>(() => TripControlService());
  Get.lazyPut<TripsController>(() => TripsController());
  Get.lazyPut<UserController>(() => UserController());
  Get.lazyPut<GroupController>(() => GroupController());
  Get.lazyPut<WalletController>(() => WalletController());
  Get.lazyPut<StationController>(() => StationController());
  Get.lazyPut<SubscriptionController>(() => SubscriptionController());
  Get.lazyPut<FollowController>(() => FollowController());
  Get.lazyPut<IndividualUserFollowersController>(() => IndividualUserFollowersController());
  
  Get.put(QrScannerController());
  
  print('✅ Core controllers initialized');
}

Future<void> setupAuthDependentDependencies() async {
  try {
    final localStorage = Get.find<LocalStorage>();
    if (!localStorage.isLoggedIn()) {
      print('❌ Cannot setup auth-dependent controllers: User not authenticated');
      return;
    }

    if (Get.isRegistered<BikeController>(tag: null)) {
      Get.find<BikeController>();
    }
    if (Get.isRegistered<BikeMetricsController>(tag: null)) {
      Get.find<BikeMetricsController>();
    }
    if (Get.isRegistered<TripControlService>(tag: null)) {
      Get.find<TripControlService>();
    }

    Get.put(MainPageController());
    Get.put(UserController());
    Get.put(GroupController());
    Get.put(WalletController());
    
    Get.put(StationController());
    
    Get.put(TripsController());
    Get.put(SubscriptionController());
    Get.put(FollowController());
    Get.put(IndividualUserFollowersController());
    
    if (Get.isRegistered<TripControlService>()) {
      final tripControlService = Get.find<TripControlService>();
       tripControlService.initializeFromStorage();
    }
    
    print('✅ Auth-dependent controllers initialized');
  } catch (e) {
    print('❌ Error initializing auth-dependent controllers: $e');
    rethrow; // Re-throw to handle upstream
  }
}

Future<void> onLoginSuccess() async {
  try {
    await setupAuthDependentDependencies();
  } catch (e) {
    print('❌ Failed to setup dependencies after login: $e');
  }
}

Future<void> onLogout() async {
  try {
    if (Get.isRegistered<IndividualUserFollowersController>()) {
      Get.delete<IndividualUserFollowersController>();
    }
    if (Get.isRegistered<FollowController>()) {
      Get.delete<FollowController>();
    }
    if (Get.isRegistered<SubscriptionController>()) {
      Get.delete<SubscriptionController>();
    }
    if (Get.isRegistered<TripsController>()) {
      Get.delete<TripsController>();
    }
    if (Get.isRegistered<StationController>()) {
      Get.delete<StationController>();
    }
    if (Get.isRegistered<WalletController>()) {
      Get.delete<WalletController>();
    }
    if (Get.isRegistered<GroupController>()) {
      Get.delete<GroupController>();
    }
    if (Get.isRegistered<UserController>()) {
      Get.delete<UserController>();
    }
    if (Get.isRegistered<MainPageController>()) {
      Get.delete<MainPageController>();
    }
    
    if (Get.isRegistered<TripControlService>()) {
      Get.delete<TripControlService>();
      Get.lazyPut<TripControlService>(() => TripControlService());
    }
    if (Get.isRegistered<BikeMetricsController>()) {
      Get.delete<BikeMetricsController>();
      Get.lazyPut<BikeMetricsController>(() => BikeMetricsController());
    }
    if (Get.isRegistered<BikeController>()) {
      Get.delete<BikeController>();
      Get.lazyPut<BikeController>(() => BikeController());
    }
    
    print('✅ Auth-dependent controllers cleaned up');
  } catch (e) {
    print('❌ Error during logout cleanup: $e');
  }
}

T getOrInitController<T>() {
  if (Get.isRegistered<T>()) {
    return Get.find<T>();
  }
  
  final localStorage = Get.find<LocalStorage>();
  if (localStorage.isLoggedIn()) {
    setupAuthDependentDependencies().then((_) {
    }).catchError((e) {
      print('❌ Error setting up dependencies for controller $T: $e');
    });
    
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    }
  }
  
  throw Exception('Controller $T not available - user not authenticated or initialization failed');
}