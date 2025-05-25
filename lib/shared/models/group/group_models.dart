class Group {
  String id;
  String name;
  String description;
  DateTime? createdAt; // Made nullable
  String createdBy;
  int memberCount;
  bool isMember;
  bool isCreator;
  String lastActivity;
  double totalDistance;
  int totalTrips;
  double averageSpeed;
  AggregatedData? aggregatedData;

  Group({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt, // Made nullable
    required this.createdBy,
    required this.memberCount,
    required this.isMember,
    required this.isCreator,
    required this.lastActivity,
    required this.totalDistance,
    required this.totalTrips,
    required this.averageSpeed,
    this.aggregatedData,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt:
          json['created_at'] != null && json['created_at'].toString().isNotEmpty
              ? DateTime.tryParse(json['created_at'])
              : null,
      createdBy: json['created_by'],
      memberCount: json['member_count'] ?? 0,
      isMember: json['is_member'] ?? false,
      isCreator: json['is_creator'] ?? false,
      lastActivity: json['last_activity'] ?? '',
      totalDistance: json['total_distance'] != null
          ? (json['total_distance'] as num).toDouble()
          : 0.0,
      totalTrips: json['total_trips'] ?? 0,
      averageSpeed: json['average_speed'] != null
          ? (json['average_speed'] as num).toDouble()
          : 0.0,
      aggregatedData: json['aggregated_data'] != null
          ? AggregatedData.fromJson(json['aggregated_data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'member_count': memberCount,
      'is_member': isMember,
      'is_creator': isCreator,
      'last_activity': lastActivity,
      'total_distance': totalDistance,
      'total_trips': totalTrips,
      'average_speed': averageSpeed,
      'aggregated_data': aggregatedData?.toJson(),
    };
  }
}

class AggregatedData {
  final double totalCarbon;
  final int totalPoints;
  final double totalKm;
  final int noOfUsers;

  AggregatedData({
    required this.totalCarbon,
    required this.totalPoints,
    required this.totalKm,
    required this.noOfUsers,
  });

  factory AggregatedData.fromJson(Map<String, dynamic> json) {
    return AggregatedData(
      totalCarbon: json['total_carbon'] != null
          ? (json['total_carbon'] as num).toDouble()
          : 0.0,
      totalPoints: json['total_points'] ?? 0,
      totalKm:
          json['total_km'] != null ? (json['total_km'] as num).toDouble() : 0.0,
      noOfUsers: json['no_of_users'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_carbon': totalCarbon,
      'total_points': totalPoints,
      'total_km': totalKm,
      'no_of_users': noOfUsers,
    };
  }
}

class GetAllGroupsResponse {
  List<Group> groups;
  bool success;
  String? message;

  GetAllGroupsResponse({
    required this.groups,
    required this.success,
    this.message,
  });

  factory GetAllGroupsResponse.fromJson(Map<String, dynamic> json) {
    List<Group> groupsList = [];

    if (json['groups'] != null && json['groups'] is List) {
      groupsList = (json['groups'] as List)
          .map((groupJson) => Group.fromJson(groupJson))
          .toList();
    }

    return GetAllGroupsResponse(
      groups: groupsList,
      success: json['success'] ?? false,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groups': groups.map((group) => group.toJson()).toList(),
      'success': success,
      'message': message,
    };
  }
}

// Rest of your models remain the same
class GroupAggregateModel {
  final AggregatedData? aggregateData;
  final bool success;

  GroupAggregateModel({
    this.aggregateData,
    this.success = false,
  });

  factory GroupAggregateModel.fromJson(Map<String, dynamic> json) {
    return GroupAggregateModel(
      aggregateData: json['aggregate_data'] != null
          ? AggregatedData.fromJson(json['aggregate_data'])
          : null,
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aggregate_data': aggregateData?.toJson(),
      'success': success,
    };
  }
}

class GroupMembersDetailsModel {
  List<MemberDetails> members;
  bool success;

  GroupMembersDetailsModel({
    required this.members,
    required this.success,
  });

  factory GroupMembersDetailsModel.fromJson(Map<String, dynamic> json) {
    return GroupMembersDetailsModel(
      members: List<MemberDetails>.from(
          json['members'].map((member) => MemberDetails.fromJson(member))),
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'members': members.map((member) => member.toJson()).toList(),
      'success': success,
    };
  }
}

class MemberDetails {
  String uid;
  String firstName;
  String lastName;
  String email;
  double carbonFootprint;
  int points;
  double kmTraveled;
  String avatar;

  MemberDetails({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.carbonFootprint,
    required this.points,
    required this.kmTraveled,
    required this.avatar,
  });

  factory MemberDetails.fromJson(Map<String, dynamic> json) {
    return MemberDetails(
      uid: json['uid'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      carbonFootprint: (json['carbon_footprint'] ?? 0).toDouble(),
      points: json['points'] ?? 0,
      kmTraveled: (json['km_traveled'] ?? 0).toDouble(),
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'carbon_footprint': carbonFootprint,
      'points': points,
      'km_traveled': kmTraveled,
      'avatar': avatar,
    };
  }
}

class GroupMembersModel {
  List<Member> members;
  bool success;

  GroupMembersModel({
    required this.members,
    required this.success,
  });

  factory GroupMembersModel.fromJson(Map<String, dynamic> json) {
    return GroupMembersModel(
      members: List<Member>.from(
          json['members'].map((member) => Member.fromJson(member))),
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'members': members.map((member) => member.toJson()).toList(),
      'success': success,
    };
  }
}

class Member {
  String uid;
  String firstName;
  String lastName;
  String email;

  Member({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      uid: json['uid'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
  }
}

class JoinedGroup {
  final int id;
  final String name;
  final String description;
  final String? createdAt;
  final String? updatedAt;

  JoinedGroup({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory JoinedGroup.fromJson(Map<String, dynamic> json) {
    return JoinedGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
