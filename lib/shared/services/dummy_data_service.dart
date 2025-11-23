// import 'dart:math';

// import 'package:mjollnir/shared/models/group/group_models.dart';
// import 'package:mjollnir/shared/models/user/user_model.dart';

// class DummyDataService {
//   static Map<String, dynamic> getUserData() {
//     return {
//       'success': true,
//       'data': {
//         'uid': 'dummy-user-id',
//         'phone': '+91987654321',
//         'email': 'dummyuser@example.com',
//         'password': '',
//         'first_name': 'John',
//         'last_name': 'Doe',
//         'date_of_birth': '1990-01-01',
//         'type': 'student',
//         'employee_id': '',
//         'company': '',
//         'college': 'Dummy University',
//         'student_id': 'DU12345',
//         'height': 175,
//         'weight': 70,
//         'age': 32,
//         'points': 120,
//         'avatar': 'https://placehold.co/400',
//         'banner': '',
//         'trips': 15,
//         'distance': 85.5,
//         'followers': 42,
//       },
//       'message': 'User data retrieved successfully'
//     };
//   }

//   static Map<String, dynamic> getAllUsersResponse() {
//     return {
//       'success': true,
//       'data': List.generate(
//           10,
//           (index) => {
//                 'uid': 'dummy-user-$index',
//                 'first_name': 'User',
//                 'last_name': 'Name$index',
//                 'email': 'user$index@example.com',
//                 'phone': '+91987654${index.toString().padLeft(4, '0')}',
//                 'avatar': 'https://placehold.co/400',
//                 'points': 100 + Random().nextInt(200),
//                 'following': index % 3 == 0,
//                 'trips': 5 + Random().nextInt(20),
//                 'distance': 10.0 + (Random().nextDouble() * 90),
//                 'followers': 5 + Random().nextInt(50),
//               }),
//       'message': 'Users fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getBikesResponse(String stationId) {
//     return {
//       'success': true,
//       'data': List.generate(
//         5,
//         (index) => {
//           'id': 'bike-$index',
//           'frame_number': 'FN${1000 + index}',
//           'name': 'Mountain Bike ${index + 1}',
//           'station_id': stationId,
//           'top_speed': 25 + (index * 2),
//           'range': 50 + (index * 10),
//           'time_to_station': 1 + (index % 3),
//         },
//       ),
//       'message': 'Bikes fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getBikeResponse(String id) {
//     final int index = int.tryParse(id.split('-').last) ?? 0;
//     return {
//       'success': true,
//       'data': {
//         'id': id,
//         'frame_number': 'FN${1000 + index}',
//         'name': 'Mountain Bike ${index + 1}',
//         'station_id': 'station-${1 + (index % 3)}',
//         'top_speed': 25 + (index * 2),
//         'range': 50 + (index * 10),
//         'time_to_station': 1 + (index % 3),
//       },
//       'message': 'Bike details fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getBatteryResponse() {
//     return {
//       'success': true,
//       'data': '${Random().nextInt(80) + 20}%',
//       'message': 'Battery status fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getStationsResponse() {
//     return {
//       'success': true,
//       'data': List.generate(
//         8,
//         (index) => {
//           'id': 'station-$index',
//           'name': 'Station Location ${index + 1}',
//           'location_latitude': (17.4065 + (index * 0.01)).toString(),
//           'location_longitude': (78.4772 + (index * 0.01)).toString(),
//           'capacity': 10 + (index * 2),
//           'current_capacity': 5 + (index % 5),
//           'distance': 0.5 + (index * 0.5),
//         },
//       ),
//       'message': 'Stations fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getWalletBalanceResponse() {
//     return {
//       'success': true,
//       'data': {
//         'user_id': 'dummy-user-id',
//         'balance': 1250.50,
//       },
//       'message': 'Wallet balance fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getWalletTopupResponse() {
//     return {
//       'success': true,
//       'data': 'dummy-order-id-${DateTime.now().millisecondsSinceEpoch}',
//       'message': 'Top-up initiated successfully'
//     };
//   }

//   static Map<String, dynamic> getTransactionsResponse() {
//     final now = DateTime.now();

//     return {
//       'success': true,
//       'data': List.generate(
//         10,
//         (index) {
//           final bool isDeposit = index % 3 != 0;
//           final timestamp =
//               now.subtract(Duration(days: index ~/ 2, hours: index % 12));

//           return {
//             'id': 'txn-${1000 + index}',
//             'user_id': 'dummy-user-id',
//             'amount': isDeposit ? (100.0 + index * 10) : -(50.0 + index * 5),
//             'type': isDeposit ? 'deposit' : 'withdrawal',
//             'description': isDeposit ? 'Account top up' : 'Bike rental payment',
//             'timestamp': timestamp.toIso8601String(),
//           };
//         },
//       ),
//       'message': 'Transactions fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getGroupsResponse() {
//     return {
//       'success': true,
//       'groups': List.generate(
//         5,
//         (index) => {
//           'id': 'group-$index',
//           'name': 'Cycling Group ${index + 1}',
//           'description': 'A group for cycling enthusiasts ${index + 1}',
//           'created_at': DateTime.now()
//               .subtract(Duration(days: 30 + index))
//               .toIso8601String(),
//           'created_by': index == 0 ? 'dummy-user-id' : 'user-${index % 3}',
//           'member_count': 5 + (index * 2),
//           'is_member': index % 2 == 0,
//           'is_creator': index == 0,
//           'last_activity': DateTime.now()
//               .subtract(Duration(hours: index * 5))
//               .toIso8601String(),
//           'total_distance': 120.0 + (index * 15),
//           'total_trips': 25 + (index * 5),
//           'average_speed': 15.0 + (index * 2),
//           'aggregated_data': {
//             'total_carbon': 50.0 + (index * 10),
//             'total_points': 200 + (index * 50),
//             'total_km': 120.0 + (index * 15),
//             'no_of_users': 5 + (index * 2),
//           }
//         },
//       ),
//       'message': 'Groups fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getGroupMembersResponse(String groupId) {
//     return {
//       'success': true,
//       'members': List.generate(
//         5,
//         (index) => {
//           'uid': 'user-$index',
//           'first_name': 'Group',
//           'last_name': 'Member$index',
//           'email': 'member$index@example.com',
//           'carbon_footprint': 10.0 + (index * 2.5),
//           'points': 50 + (index * 20),
//           'km_traveled': 25.0 + (index * 10),
//           'avatar': 'https://placehold.co/400',
//         },
//       ),
//       'message': 'Group members fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getGroupDetailsResponse(String groupId) {
//     return {
//       'success': true,
//       'group': {
//         'id': groupId,
//         'name': 'Cycling Group X',
//         'description': 'A group for cycling enthusiasts',
//         'created_at':
//             DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
//         'created_by': 'dummy-user-id',
//       },
//       'message': 'Group details fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getGroupAggregateResponse(String groupId) {
//     return {
//       'success': true,
//       'aggregate_data': {
//         'total_carbon': 150.5,
//         'total_points': 750,
//         'total_km': 325.5,
//         'no_of_users': 12,
//       },
//       'message': 'Group aggregate data fetched successfully'
//     };
//   }

//   static Map<String, dynamic> joinGroupResponse() {
//     return {'success': true, 'message': 'Successfully joined the group'};
//   }

//   static Map<String, dynamic> createGroupResponse(
//       String name, String description) {
//     return {
//       'success': true,
//       'created_by': 'dummy-user-id',
//       'description': description,
//       'group_id': 'group-${DateTime.now().millisecondsSinceEpoch}',
//       'message': 'Group created successfully',
//       'name': name,
//     };
//   }

//   static Map<String, dynamic> getTripsResponse() {
//     return {
//       'success': true,
//       'data': List.generate(
//         5,
//         (index) => {
//           'id': 'trip-$index',
//           'user_id': 'dummy-user-id',
//           'bike_id': 'bike-$index',
//           'station_id': 'station-$index',
//           'start_timestamp': DateTime.now()
//               .subtract(Duration(days: index, hours: 2))
//               .toIso8601String(),
//           'end_timestamp':
//               DateTime.now().subtract(Duration(days: index)).toIso8601String(),
//           'distance': 10.0 + (index * 5),
//           'duration': 30.0 + (index * 15),
//           'average_speed': 12.0 + (index * 2),
//           'path': List.generate(
//             3 + index,
//             (i) => [17.4065 + (i * 0.001), 78.4772 + (i * 0.001)],
//           ),
//           'max_elevation': 100 + (index * 10),
//           'kcal': 200 + (index * 50),
//         },
//       ),
//       'message': 'Trips fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getStartTripResponse() {
//     return {
//       'success': true,
//       'data': {
//         'id': 'trip-${DateTime.now().millisecondsSinceEpoch}',
//         'user_id': 'dummy-user-id',
//         'bike_id': 'dummy-bike-id',
//         'station_id': 'dummy-station-id',
//         'start_timestamp': DateTime.now().toIso8601String(),
//       },
//       'message': 'Trip started successfully'
//     };
//   }

//   static Map<String, dynamic> getEndTripResponse(String tripId) {
//     return {
//       'success': true,
//       'data': {
//         'id': tripId,
//         'user_id': 'dummy-user-id',
//         'bike_id': 'dummy-bike-id',
//         'station_id': 'dummy-station-id',
//         'start_timestamp':
//             DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
//         'end_timestamp': DateTime.now().toIso8601String(),
//         'distance': 15.5,
//         'duration': 60.0,
//         'average_speed': 15.5,
//         'path': [
//           [17.4065, 78.4772],
//           [17.4075, 78.4782],
//           [17.4085, 78.4792],
//         ],
//         'max_elevation': 120,
//         'kcal': 350,
//       },
//       'message': 'Trip ended successfully'
//     };
//   }

//   static Map<String, dynamic> getTripLocationsResponse() {
//     return {
//       'success': true,
//       'data': List.generate(
//         10,
//         (i) => [17.4065 + (i * 0.001), 78.4772 + (i * 0.001)],
//       ),
//       'message': 'Trip locations fetched successfully'
//     };
//   }

//   static Map<String, dynamic> putTripLocationResponse() {
//     return {
//       'success': true,
//       'data': {
//         'average_speed': 18.5,
//         'distance': 12.3,
//         'duration': 45.0,
//         'max_elevation': 110,
//         'kcal': 220,
//         'bike_id': 'bike-123',
//       },
//       'message': 'Location updated successfully'
//     };
//   }

//   static Map<String, dynamic> getUserSubscriptionsResponse() {
//     final now = DateTime.now();
//     final endDate = now.add(const Duration(days: 30));

//     return {
//       'success': true,
//       'data': List.generate(
//         2,
//         (index) => {
//           'user_subscriptions': {
//             'id': 'subscription-$index',
//             'user_id': 'dummy-user-id',
//             'subscription_id': 'plan-$index',
//             'start_date': DateTimeUtils.formatDate(now),
//             'end_date': DateTimeUtils.formatDate(endDate),
//           },
//           'subscriptions': {
//             'id': 'plan-$index',
//             'monthly_fee': 199.0 + (index * 100),
//             'discount': 10.0 * index,
//             'name': 'Premium Plan ${index + 1}',
//             'bike_id': 'bike-type-$index',
//             'type': index == 0 ? 'monthly' : 'yearly',
//             'security_deposit': 999.0 + (index * 500),
//           }
//         },
//       ),
//       'message': 'User subscriptions fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getFaqResponse() {
//     return {
//       'success': true,
//       'data': [
//         {
//           'id': 'faq-1',
//           'question': 'How do I rent a bike?',
//           'answer':
//               'You can rent a bike by selecting a station on the map, choosing a bike, and then selecting a plan that suits your needs.'
//         },
//         {
//           'id': 'faq-2',
//           'question': 'What if the bike breaks down during my rental period?',
//           'answer':
//               'If the bike breaks down, please report it through the app and we will assist you as soon as possible.'
//         },
//         {
//           'id': 'faq-3',
//           'question': 'How do I end my trip?',
//           'answer':
//               'To end your trip, simply lock the bike at any of our designated stations and tap "End Trip" in the app.'
//         },
//         {
//           'id': 'faq-4',
//           'question': 'What payment methods are accepted?',
//           'answer':
//               'We accept credit/debit cards, UPI, and wallet payments through our app.'
//         },
//         {
//           'id': 'faq-5',
//           'question': 'Is there a late return fee?',
//           'answer':
//               'Yes, there is a late return fee if you exceed your rental period. Please check the rates in the Plan Details section.'
//         }
//       ],
//       'message': 'FAQs fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getTimeTraveledResponse() {
//     final now = DateTime.now();

//     return {
//       'success': true,
//       'data': List.generate(
//         7,
//         (index) {
//           final date = now.subtract(Duration(days: 6 - index));
//           return {
//             'date': DateTimeUtils.formatDateYMD(date),
//             'day_of_week': DateTimeUtils.getDayOfWeek(date),
//             'time_travelled': 0.5 + (Random().nextDouble() * 3.5),
//           };
//         },
//       ),
//       'message': 'Time travelled data fetched successfully'
//     };
//   }

//   static Map<String, dynamic> getLoginResponse() {
//     return {
//       'success': true,
//       'data': {'account_exists': true, 'test_phone': true},
//       'message': 'Login successful'
//     };
//   }

//   static Map<String, dynamic> getOtpVerificationResponse(bool accountExists) {
//     return {
//       'success': true,
//       'data': {
//         'account_exists': accountExists,
//         'token': 'dummy-auth-token-${DateTime.now().millisecondsSinceEpoch}'
//       },
//       'message': 'OTP verified successfully'
//     };
//   }

//   static Map<String, dynamic> getSignupResponse() {
//     return {
//       'success': true,
//       'data': 'dummy-auth-token-${DateTime.now().millisecondsSinceEpoch}',
//       'message': 'User registered successfully'
//     };
//   }

//   static List<dynamic> getSearchResults(String query) {
//     final users = (getAllUsersResponse()['data'] as List)
//         .map((user) => User.fromJson(user))
//         .toList();
//     final groups = (getGroupsResponse()['groups'] as List)
//         .map((group) => AllGroup.fromJson(group))
//         .toList();

//     final results = <dynamic>[];

//     if (query.isNotEmpty) {
//       results.addAll(users.where((user) =>
//           user.firstName.toLowerCase().contains(query.toLowerCase()) ||
//           user.lastName.toLowerCase().contains(query.toLowerCase())));

//       results.addAll(groups.where(
//           (group) => group.name.toLowerCase().contains(query.toLowerCase())));
//     }

//     return results;
//   }

//   static getTripSummaryResponse() {}

//   static getBikeData(String id) {}
// }

// class DateTimeUtils {
//   static String formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }

//   static String formatDateYMD(DateTime date) {
//     return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//   }

//   static String getDayOfWeek(DateTime date) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[date.weekday - 1];
//   }
// }
