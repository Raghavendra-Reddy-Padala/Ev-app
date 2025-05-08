import 'package:get/get.dart';

import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';
import '../../../shared/models/group/group_models.dart';
import '../../../shared/services/dummy_data_service.dart';

class GroupController extends BaseController {
  final RxList<Group> allGroups = <Group>[].obs;
  final RxList<Group> userGroups = <Group>[].obs;
  final RxList<Group> joinedGroups = <Group>[].obs;
  final Rxn<GroupMembersDetailsModel> groupMembersDetails =
      Rxn<GroupMembersDetailsModel>();
  final Rxn<AggregatedData> groupAggregateData = Rxn<AggregatedData>();

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
              endpoint: '/v1/groups/getAll',
              headers: {
                'Authorization': 'Bearer $authToken',
              },
              queryParams: queryParams);

          if (response != null) {
            final groupsResponse = GetAllGroupsResponse.fromJson(response.data);
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
            endpoint: '/v1/user/groups_created',
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          );

          if (response != null) {
            final groupsResponse = GetAllGroupsResponse.fromJson(response.data);
            userGroups.assignAll(groupsResponse.groups);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getGroupsResponse();
          final groupsResponse = GetAllGroupsResponse.fromJson(dummyData);

          userGroups.assignAll(groupsResponse.groups.where((g) => g.isCreator));
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
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

          final response = await apiService.get(
            endpoint: '/v1/user/groups',
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          );

          if (response != null) {
            final groupsResponse = GetAllGroupsResponse.fromJson(response.data);
            joinedGroups.assignAll(groupsResponse.groups);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getGroupsResponse();
          final groupsResponse = GetAllGroupsResponse.fromJson(dummyData);

          joinedGroups
              .assignAll(groupsResponse.groups.where((g) => g.isMember));
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createGroup(String name, String description) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response =
              await apiService.post(endpoint: '/v1/groups/create', headers: {
            'Authorization': 'Bearer $authToken',
          }, body: {
            "name": name,
            "description": description
          });

          if (response != null && response.data['success']) {
            await fetchUserGroups();
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyResponse =
              DummyDataService.createGroupResponse(name, description);

          userGroups.add(
            Group(
              id: dummyResponse['group_id'],
              name: name,
              description: description,
              createdAt: DateTime.now(),
              createdBy: 'dummy-user-id',
              memberCount: 1,
              isMember: true,
              isCreator: true,
              lastActivity: DateTime.now().toIso8601String(),
              totalDistance: 0.0,
              totalTrips: 0,
              averageSpeed: 0.0,
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

          final response = await apiService.post(
            endpoint: '/v1/groups/$groupId/join',
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          );

          if (response != null && response.data['success']) {
            // Refresh joined groups after joining a new one
            await fetchJoinedGroups();
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyResponse = DummyDataService.joinGroupResponse();

          final groupIndex = allGroups.indexWhere((g) => g.id == groupId);
          if (groupIndex >= 0) {
            final group = allGroups[groupIndex];
            group.isMember = true;
            allGroups[groupIndex] = group;

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
            endpoint: '/v1/groups/$groupId/members/data',
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          );

          if (response != null) {
            groupMembersDetails.value =
                GroupMembersDetailsModel.fromJson(response.data);
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
            },
          );

          if (response != null) {
            final aggregateModel = GroupAggregateModel.fromJson(response.data);
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
}
