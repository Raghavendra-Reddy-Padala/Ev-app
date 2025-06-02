class ApiConstants {
  static const String baseUrl = 'https://ev.coffeecodes.in/v1';

  static const String login = 'auth/login';
  static const String signup = 'auth/register';
  static const String verifyOtp = 'auth/verify_otp';
  static const String dummyToken = 'auth/dummy';

  static const String userGet = 'user/me';
  static const String userFollow = 'user/follow';
  static const String userGetAll = 'user/getAll';
  static const String userGroups = 'user/groups';
  static const String userGroupsCreated = 'user/groups_created';
  static const String userTimeTravelled = 'user/time_travelled';
  static const String userInviteCode = 'user/invite_code';
  static const String userDetails = 'user/me';
  static const String updateProfile = 'user/update';

  static const String stationsGet = 'stations/get';
  static const String stationsGetNearby = 'stations/get_nearby';

  static const String bikesByStation = 'bikes/station';
  static const String bikesStatus = 'metal/status';
  static const String getBikes = 'bikes/get';
  static const String bikesById = 'bikes';

  static const String tripsStart = 'trips/start';
  static const String tripsEnd = 'trips/end';
  static const String active = 'trips/active';
  static const String tripsMyTrips = 'trips/my';
  static const String tripsLocation = 'trips/location';
  static const String tripsSummary = 'trips/summary';
  static const String userTrips = 'trips/user';

  static const String groupsGetAll = 'groups';
  static const String groupsCreate = 'groups';
  static const String groupsJoin = 'groups/join';
  static const String groupsMembers = 'groups/members';
  static const String groupDetails = 'groups';
  static const String walletGet = 'wallet/get';
  static const String walletTopup = 'wallet/topup';

  static const String transactionsGetAll = 'transactions/getAll';

  static const String subscriptionsCreate = 'subscriptions/create';
  static const String userSubscriptions = 'user_subscription';
  static const String faq = 'faqs';

  static const String referralCode = 'user/invite_code';
  static const String referralBenefits = 'user/referral_benefits';
  static const String activityGraph = 'analytics/activity_graph';

  static const String toggleBike = 'metal/toggle';

  static const String subscriptions = 'subscriptions';
  static const String userSubscription = 'user_subscription/';
}
