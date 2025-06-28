import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/features/friends/views/individualuser.dart';
import 'package:mjollnir/main.dart';
import 'package:mjollnir/shared/models/followers/followers_model.dart';
import '../../../core/api/base/base_controller.dart';

class IndividualUserFollowersController extends BaseController {
  // Followers data for specific user
  final Rxn<FollowersResponse> userFollowersData = Rxn<FollowersResponse>();
  final RxList<FollowerUser> userFollowers = <FollowerUser>[].obs;
  
  // Track current user ID
  final RxString currentUserId = ''.obs;

  Future<void> fetchUserFollowers({required String uid}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentUserId.value = uid;

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: '${ApiConstants.userFollowers}?uid=$uid',
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
              'X-Karma-App': 'dafjcnalnsjn',
            },
          );

          if (response != null) {
            // Fix: Pass the entire response to fromJson (not response.data)
            // The response is already the Map<String, dynamic> containing the JSON structure
            userFollowersData.value = FollowersResponse.fromJson(response);
            
            // Check if the data was parsed successfully
            if (userFollowersData.value?.data?.followers != null) {
              userFollowers.assignAll(userFollowersData.value!.data.followers);
            } else {
              print('Warning: No followers data found in response');
              userFollowers.clear();
            }
            return true;
          }
          return false;
        },
        dummyData: () {
          // Create dummy followers data for the specific user
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
                  "points": 150,
                  "following": false
                },
                {
                  "uid": "abc123def",
                  "first_name": "priya",
                  "last_name": "sharma",
                  "email": "priya.sharma@example.com", 
                  "avatar": "https://res.cloudinary.com/djyny0qqn/image/upload/v1749474006/475525-3840x2160-desktop-4k-mjolnir-thor-wallpaper_bl9rvh.jpg",
                  "points": 280,
                  "following": true
                },
                {
                  "uid": "xyz789ghi",
                  "first_name": "rahul",
                  "last_name": "verma",
                  "email": "rahul.v@example.com",
                  "avatar": "https://res.cloudinary.com/djyny0qqn/image/upload/v1749388344/ChatGPT_Image_Jun_8_2025_05_27_53_PM_nu0zjs.png",
                  "points": 95,
                  "following": false
                }
              ],
              "user": {
                "uid": uid,
                "first_name": "target",
                "last_name": "user",
                "email": "target@example.com",
                "avatar": "https://cdn.public.prod.coffeecodes.in/ImageType.avatar_1750929856364.jpg",
                "points": 0,
                "following": false
              }
            },
            "message": "User followers retrieved successfully",
            "error": null
          };
          
          userFollowersData.value = FollowersResponse.fromJson(dummyFollowersData);
          userFollowers.assignAll(userFollowersData.value!.data.followers);
          return true;
        },
      );
    } catch (e) {
      print('Error fetching user followers: $e');
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Method to show user followers list - optimized like UserController
  void showUserFollowersList({required String uid, required String userName}) {
    if (userFollowers.isEmpty || currentUserId.value != uid) {
      fetchUserFollowers(uid: uid).then((_) {
        if (userFollowers.isNotEmpty) {
          _displayUserFollowersDialog(userName: userName);
        }
      });
    } else {
      _displayUserFollowersDialog(userName: userName);
    }
  }

  // Simplified dialog like in UserController
  void _displayUserFollowersDialog({required String userName}) {
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
                    '$userName\'s Followers',
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
                  if (userFollowers.isEmpty) {
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
                    itemCount: userFollowers.length,
                    itemBuilder: (context, index) {
                      final follower = userFollowers[index];
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Get.back(); 
                            Get.to(() => IndividualUserPage(
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

  // Clear data when switching users
  void clearUserData() {
    userFollowersData.value = null;
    userFollowers.clear();
    currentUserId.value = '';
  }

  @override
  void onClose() {
    clearUserData();
    super.onClose();
  }
}