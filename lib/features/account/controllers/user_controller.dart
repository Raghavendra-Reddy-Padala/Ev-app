import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/features/friends/views/individualuser.dart';
import 'package:mjollnir/main.dart';
import 'package:mjollnir/shared/models/followers/followers_model.dart';

import '../../../core/api/base/base_controller.dart';
import '../../../shared/models/user/user_model.dart';
import '../../../shared/services/dummy_data_service.dart';
import '../../friends/controller/follow_controller.dart';

class UserController extends BaseController {
  final Rxn<UserDetailsResponse> userData = Rxn<UserDetailsResponse>();
  final RxList<User> users = <User>[].obs;
  final Rxn<GetAllUsersResponse> getAllUsers = Rxn<GetAllUsersResponse>();
  
  // Add followers data
  final Rxn<FollowersResponse> followersData = Rxn<FollowersResponse>();
  final RxList<FollowerUser> followers = <FollowerUser>[].obs;

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
              'X-Karma-App': 'dafjcnalnsjn',
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
      errorMessage.value = ''; // Clear previous errors

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
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );

          if (response != null) {
            final usersResponse = GetAllUsersResponse.fromJson(response);
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
      handleError(e); 
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFollowers() async {
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
            endpoint: ApiConstants.userFollowers,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
              'X-Karma-App': 'dafjcnalnsjn',
            },
          );

          if (response != null) {
           followersData.value = FollowersResponse.fromJson(response);
            followers.assignAll(followersData.value!.data.followers);
            return true;
          }
          return false;
        },
        dummyData: () {
          // Create dummy followers data
          final dummyFollowersData = {
            "success": true,
            "data": {
              "followers": [
                {
                  "uid": "vi0jpqkdco",
                  "first_name": "chintu",
                  "last_name": "reddy",
                  "email": "fux@gmajl.xom",
                  "avatar": "https://res.cloudinary.com/djyny0qqn/image/upload/v1749474051/37391-3840x2160-desktop-4k-venom-background-image_tvehbk.jpg",
                  "points": 0,
                  "following": false
                }
              ],
              "user": {
                "uid": "0d5u-yu4dn",
                "first_name": "anil",
                "last_name": "kumar",
                "email": "anilkumar2000jnv@gmail.com",
                "avatar": "https://cdn.public.prod.coffeecodes.in/ImageType.avatar_1750929856364.jpg",
                "points": 0,
                "following": false
              }
            },
            "message": "User followers retrieved successfully",
            "error": null
          };
          
          followersData.value = FollowersResponse.fromJson(dummyFollowersData);
          followers.assignAll(followersData.value!.data.followers);
          return true;
        },
      );
    } catch (e) {
      print('Error fetching followers: $e');
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Method to show followers list
  void showFollowersList() {
    if (followers.isEmpty) {
      fetchFollowers().then((_) {
        if (followers.isNotEmpty) {
          _displayFollowersDialog();
        }
      });
    } else {
      _displayFollowersDialog();
    }
  }
void _displayFollowersDialog() {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: Get.width * 0.9,
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Followers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (followers.isEmpty) {
                  return Center(
                    child: Text(
                      'No followers yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: followers.length,
                  itemBuilder: (context, index) {
                    final follower = followers[index];
                    return ListTile(
                      leading: GestureDetector(
                        onTap: () async {
                          await Get.to(() => IndividualUserPage(
                            name: follower.firstName,
                            trips: follower.points,
                            followers: follower.points,
                            distance: follower.points.toInt().toString(),
                            avatharurl: follower.avatar.toString(),
                            uid: follower.uid,
                            points: follower.points,
                          ));
                        },
                        child: CircleAvatar(
                          backgroundImage: follower.avatar != null
                              ? NetworkImage(follower.avatar!)
                              : null,
                          child: follower.avatar == null
                              ? Icon(Icons.person)
                              : null,
                        ),
                      ),
                      title: Text(follower.fullName),
                      trailing: Text(
                        '${follower.points} pts',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    ),
  );
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