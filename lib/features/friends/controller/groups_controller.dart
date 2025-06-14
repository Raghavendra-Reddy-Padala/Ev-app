import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/storage/local_storage.dart';

import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';
import '../../../shared/models/group/group_models.dart';
import '../../../shared/services/dummy_data_service.dart';

class GroupController extends BaseController {
  final RxList<AllGroup> allGroups = <AllGroup>[].obs;
  final RxList<GroupData> userGroups = <GroupData>[].obs;
  final RxList<AllGroup> joinedGroups = <AllGroup>[].obs;
  final Rxn<GroupMembersDetailsModel> groupMembersDetails =
      Rxn<GroupMembersDetailsModel>();
  final Rxn<AggregatedData> groupAggregateData = Rxn<AggregatedData>();
  var joined_groups = <GroupData>[].obs;
  final RxMap<String, GroupDetails> userGroupDetails =
      <String, GroupDetails>{}.obs;
  final RxMap<String, List<GroupMember>> groupMembersData =
      <String, List<GroupMember>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    fetchUserGroups();
    fetchJoinedGroups();
  }

  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          Map<String, dynamic> queryParams = {
            'members': '<10',
            'sort_by': 'activity',
            'order': 'desc',
            'only_member': 'false'
          };

          final response = await apiService.get(
              endpoint:
                  '${ApiConstants.groupsGetAll}?members=<10&sort_by=activity&order=desc&only_member=false',
              headers: {
                'Authorization': 'Bearer $authToken',
                'X-Karma-App': 'dafjcnalnsjn'
              },
              queryParams: queryParams);

          if (response != null) {
            final groupsResponse = GetAllGroupsResponse.fromJson(response);
            allGroups.assignAll(groupsResponse.groups);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getGroupsResponse();
          final groupsResponse = GetAllGroupsResponse.fromJson(dummyData);
          allGroups.assignAll(groupsResponse.groups);
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserGroups() async {
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
            endpoint: ApiConstants.userGroupsCreated,
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );

          if (response != null) {
            final groupsResponse = GroupsResponse.fromJson(response);
            userGroups.assignAll(groupsResponse.data);
            await fetchGroupDetailsAndMembers();
            return true;
          }
          return false;
        },
        dummyData: () {
          // final dummyData = DummyDataService.getGroupsResponse();
          // final groupsResponse = GroupsResponse.fromJson(dummyData);

          //userGroups.assignAll(groupsResponse.data.where((g) => g.isCreator));
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGroupDetailsAndMembers() async {
    for (var group in userGroups) {
      await fetchGroupDetails(group.id);
      await fetchGroupMembers(group.id);
    }
  }

  Future<void> fetchGroupDetails(String groupId) async {
    try {
      final String? authToken = await getToken();
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await apiService.get(
        endpoint: '${ApiConstants.groupDetails}/$groupId',
        headers: {
          'Authorization': 'Bearer $authToken',
          'X-Karma-App': 'dafjcnalnsjn'
        },
      );

      if (response != null) {
        final groupDetailsResponse = GroupDetailsResponse.fromJson(response);
        userGroupDetails[groupId] = groupDetailsResponse.group;
      }
    } catch (e) {
      print('Error fetching group details for $groupId: $e');
    }
  }

  Future<void> fetchGroupMembers(String groupId) async {
    try {
      final String? authToken = await getToken();
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await apiService.get(
        endpoint: '${ApiConstants.groupDetails}/$groupId/members/data',
        headers: {
          'Authorization': 'Bearer $authToken',
          'X-Karma-App': 'dafjcnalnsjn'
        },
      );

      if (response != null) {
        final membersResponse = GroupMembersResponse.fromJson(response);
        groupMembersData[groupId] = membersResponse.data;
      }
    } catch (e) {
      print('Error fetching group members for $groupId: $e');
    }
  }

  Future<void> fetchJoinedGroups() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          // First, fetch all groups
          final response = await apiService.get(
            endpoint: ApiConstants.groupsGetAll,
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );

          if (response != null) {
            final List<AllGroup> allGroups;
            if (response is List) {
              allGroups = response.map((e) => AllGroup.fromJson(e)).toList();
            } else {
              final groupsResponse = GetAllGroupsResponse.fromJson(response);
              allGroups = groupsResponse.groups;
            }

            // Filter groups where user is member but not creator
            final joinedGroupsList = allGroups
                .where((group) => group.isMember && !group.isCreator)
                .toList();

            // For each joined group, fetch its details
            for (var group in joinedGroupsList) {
              await fetchGroupDetails(group.id);
            }

            joinedGroups.assignAll(joinedGroupsList);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getGroupsResponse();
          final groupsResponse = GetAllGroupsResponse.fromJson(dummyData);
          final joinedGroupsList = groupsResponse.groups
              .where((g) => g.isMember && !g.isCreator)
              .toList();
          joinedGroups.assignAll(joinedGroupsList);
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Updated createGroup method for GroupController
  Future<bool> createGroup(String name, String description,
      [String? groupImage]) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          // Prepare the request body
          Map<String, dynamic> requestBody = {
            "name": name,
            "description": description,
          };

          // Add group_image only if it's provided
          if (groupImage != null && groupImage.isNotEmpty) {
            requestBody["group_image"] = groupImage;
          }

          final response = await apiService.post(
            endpoint: ApiConstants.groupsCreate,
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn'
            },
            body: requestBody,
          );

          if (response != null && response['success']) {
            await fetchUserGroups();
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyResponse =
              DummyDataService.createGroupResponse(name, description);

          userGroups.add(
            GroupData(
              id: dummyResponse['group_id'],
              name: name,
              description: description,
              createdAt: DateTime.now().toString(),
              createdBy: 'dummy-user-id',
              avatarUrl: groupImage ??
                  'https://dummyimage.com/600x400/000/fff&text=Group+Image',
            ),
          );
          return true;
        },
      );

      return result;
    } catch (e) {
      handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> joinGroup(String groupId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: 'groups/$groupId/join',
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );

          if (response != null && response['success']) {
            // Update the allGroups list immediately
            final currentGroups = List<AllGroup>.from(allGroups.value);
            final groupIndex = currentGroups.indexWhere((g) => g.id == groupId);

            if (groupIndex >= 0) {
              final updatedGroup = currentGroups[groupIndex];
              updatedGroup.isMember = true;
              updatedGroup.memberCount = (updatedGroup.memberCount) + 1;
              currentGroups[groupIndex] = updatedGroup;
              allGroups.value = currentGroups; // Trigger reactive update
            }

            // Also refresh the joined groups list in background
            getAlreadyJoinedGroups();
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyResponse = DummyDataService.joinGroupResponse();

          final currentGroups = List<AllGroup>.from(allGroups.value);
          final groupIndex = currentGroups.indexWhere((g) => g.id == groupId);

          if (groupIndex >= 0) {
            final group = currentGroups[groupIndex];
            group.isMember = true;
            currentGroups[groupIndex] = group;
            allGroups.value = currentGroups; // Trigger reactive update

            if (!joinedGroups.any((g) => g.id == groupId)) {
              joinedGroups.add(group);
            }
          }

          return dummyResponse['success'];
        },
      );

      return result;
    } catch (e) {
      handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGroupMembersDetails(String groupId) async {
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
            endpoint: 'groups/$groupId/members/data',
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );

          if (response != null) {
            groupMembersDetails.value =
                GroupMembersDetailsModel.fromJson(response);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getGroupMembersResponse(groupId);
          groupMembersDetails.value =
              GroupMembersDetailsModel.fromJson(dummyData);
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGroupAggregate(String groupId) async {
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
            endpoint: '/v1/groups/$groupId/aggregate',
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn'
            },
          );

          if (response != null) {
            final aggregateModel = GroupAggregateModel.fromJson(response);
            groupAggregateData.value = aggregateModel.aggregateData;
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getGroupAggregateResponse(groupId);
          final aggregateModel = GroupAggregateModel.fromJson(dummyData);
          groupAggregateData.value = aggregateModel.aggregateData;
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAlreadyJoinedGroups() async {
    String? authtoken = Get.find<LocalStorage>().getToken();

    final response = await apiService.get(
        endpoint: '${ApiConstants.groupsGetAll}/?limit=10',
        headers: {
          'Authorization': 'Bearer $authtoken',
          'X-Karma-App': 'dafjcnalnsjn'
        });

    if (response != null && response is List) {
      joined_groups.value = response.map((e) => GroupData.fromJson(e)).toList();
      joined_groups.refresh(); // Ensure UI updates
    }
    print("Joined groups: $joined_groups");
  }
}
