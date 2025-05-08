class ApiConstants {
  static const String baseUrl = 'https://ev.coffeecodes.in';

  static const String login = '/v1/auth/login';
  static const String signup = '/v1/auth/signup';
  static const String verifyOtp = '/v1/auth/verify_otp';

  static const String userGet = '/v1/user/get';
  static const String userFollow = '/v1/user/follow';
  static const String userGetAll = '/v1/user/getAll';
  static const String userGroups = '/v1/user/groups';
  static const String userGroupsCreated = '/v1/user/groups_created';
  static const String userTimeTravelled = '/v1/user/time_travelled';
  static const String userInviteCode = '/v1/user/invite_code';

  static const String stationsGet = '/v1/stations/get';
  static const String stationsGetNearby = '/v1/stations/get_nearby';

  static const String bikesByStation = '/v1/bikes/get/station';
  static const String bikesStatus = '/v1/metal/status';

  static const String tripsStart = '/v1/trips/start';
  static const String tripsEnd = '/v1/trips/end';
  static const String tripsMyTrips = '/v1/trips/mytrips';
  static const String tripsLocation = '/v1/trips/location';

  static const String groupsGetAll = '/v1/groups/getAll';
  static const String groupsCreate = '/v1/groups/create';
  static const String groupsJoin = '/v1/groups/join';
  static const String groupsMembers = '/v1/groups/members';

  static const String walletGet = '/v1/wallet/get';
  static const String walletTopup = '/v1/wallet/topup';

  static const String transactionsGetAll = '/v1/transactions/getAll';

  static const String subscriptionsCreate = '/v1/subscriptions/create';
  static const String userSubscriptionGet = '/v1/user_subscription/get';
  static const String faq = '/v1/faq';
}
