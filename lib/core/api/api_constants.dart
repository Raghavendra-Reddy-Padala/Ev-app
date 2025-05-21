class ApiConstants {
  static const String baseUrl = 'https://ev.coffeecodes.in/v1';

  static const String login = 'auth/login';
  static const String signup = 'auth/signup';
  static const String verifyOtp = 'auth/verify_otp';

  static const String userGet = 'user/get';
  static const String userFollow = 'user/follow';
  static const String userGetAll = 'user/getAll';
  static const String userGroups = 'user/groups';
  static const String userGroupsCreated = 'user/groups_created';
  static const String userTimeTravelled = 'user/time_travelled';
  static const String userInviteCode = 'user/invite_code';

  static const String stationsGet = 'stations/get';
  static const String stationsGetNearby = 'stations/get_nearby';

  static const String bikesByStation = 'bikes/get/station';
  static const String bikesStatus = 'metal/status';

  static const String tripsStart = 'trips/start';
  static const String tripsEnd = 'trips/end';
  static const String tripsMyTrips = 'trips/mytrips';
  static const String tripsLocation = 'trips/location';

  static const String groupsGetAll = 'groups/getAll';
  static const String groupsCreate = 'groups/create';
  static const String groupsJoin = 'groups/join';
  static const String groupsMembers = 'groups/members';

  static const String walletGet = 'wallet/get';
  static const String walletTopup = 'wallet/topup';

  static const String transactionsGetAll = 'transactions/getAll';

  static const String subscriptionsCreate = 'subscriptions/create';
  static const String userSubscriptionGet = 'user_subscription/get';
  static const String faq = 'faq';
}
