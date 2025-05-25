import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/main.dart';

import '../../../core/api/base/base_controller.dart';
import '../../../shared/models/user/user_model.dart';
import '../../../shared/services/dummy_data_service.dart';
import '../../friends/controller/follow_controller.dart';

class UserController extends BaseController {
  final Rxn<UserDetailsResponse> userData = Rxn<UserDetailsResponse>();
  final RxList<User> users = <User>[].obs;
  final Rxn<GetAllUsersResponse> getAllUsers = Rxn<GetAllUsersResponse>();

  @override
  void onInit() {
    super.onInit();
    dataFetch();
    getUsers();
  }

  Future<void> dataFetch() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: ApiConstants.userGet,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response != null) {
            userData.value = UserDetailsResponse.fromJson(response.data);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getUserData();
          userData.value = UserDetailsResponse.fromJson(dummyData);
          return true;
        },
      );
    } catch (e) {
      print('Error fetching user details: $e');
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: ApiConstants.userGetAll,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response != null) {
            final usersResponse = GetAllUsersResponse.fromJson(response.data);
            users.assignAll(usersResponse.data);
            getAllUsers.value = usersResponse;

            final followController = Get.find<FollowController>();
            for (var user in getAllUsers.value!.data) {
              followController.followedUsers[user.uid] = user.following;
            }
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getAllUsersResponse();
          final usersResponse = GetAllUsersResponse.fromJson(dummyData);
          users.assignAll(usersResponse.data);
          getAllUsers.value = usersResponse;

          final followController = Get.find<FollowController>();
          for (var user in getAllUsers.value!.data) {
            followController.followedUsers[user.uid] = user.following;
          }
          return true;
        },
      );
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateFollowStatus() {
    final followController = Get.find<FollowController>();
    if (getAllUsers.value != null) {
      for (var user in getAllUsers.value!.data) {
        if (user.following) {
          followController.followedUsers[user.uid] = true;
        } else {
          followController.followedUsers[user.uid] = false;
        }
      }
    }
  }
}
