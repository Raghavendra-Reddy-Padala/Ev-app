// followers_model.dart
class FollowersResponse {
  final bool success;
  final FollowersData data;
  final String message;
  final String? error;

  FollowersResponse({
    required this.success,
    required this.data,
    required this.message,
    this.error,
  });

  factory FollowersResponse.fromJson(Map<String, dynamic> json) {
    return FollowersResponse(
      success: json['success'] ?? false,
      data: FollowersData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
      'error': error,
    };
  }
}

class FollowersData {
  final List<FollowerUser> followers;
  final FollowerUser user;

  FollowersData({
    required this.followers,
    required this.user,
  });

  factory FollowersData.fromJson(Map<String, dynamic> json) {
    return FollowersData(
      followers: (json['followers'] as List<dynamic>?)
          ?.map((follower) => FollowerUser.fromJson(follower))
          .toList() ?? [],
      user: FollowerUser.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followers': followers.map((follower) => follower.toJson()).toList(),
      'user': user.toJson(),
    };
  }
}

class FollowerUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;
  final int points;
  final bool following;

  FollowerUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    required this.points,
    required this.following,
  });

  factory FollowerUser.fromJson(Map<String, dynamic> json) {
    return FollowerUser(
      uid: json['uid'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      points: json['points'] ?? 0,
      following: json['following'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar': avatar,
      'points': points,
      'following': following,
    };
  }

  String get fullName => '$firstName $lastName';
}