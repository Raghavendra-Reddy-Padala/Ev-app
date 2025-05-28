// import 'package:bolt_ui_kit/bolt_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:mjollnir/features/friends/controller/groups_controller.dart';
// import 'package:mjollnir/shared/components/header/header.dart';
// import 'package:mjollnir/shared/components/profile/user_progress_card.dart';
// import 'package:mjollnir/shared/constants/colors.dart';

// class GroupUserPage extends StatelessWidget {
//   final String name;
//   final String id;
//   const GroupUserPage({super.key, required this.name, required this.id});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SafeArea(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: ScreenUtil().screenHeight * 0.02),
//             Header(heading: name),
//             _UI(name: name, id: id),
//           ],
//         ),
//       ),
//     ));
//   }
// }

// class _UI extends StatelessWidget {
//   final String id;
//   final String name;

//   _UI({required this.name, required this.id});

//   final GroupController groupController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     final FriendUserActivityController activityController =
//         Get.put(FriendUserActivityController());

//     activityController.generateRandomData();

//     Future<void> pickDateRange(BuildContext context) async {
//       final DateTimeRange? picked = await showDateRangePicker(
//         context: context,
//         firstDate: DateTime(2023, 1),
//         lastDate: DateTime(2024, 12),
//         initialDateRange: activityController.selectedDateRange.value,
//       );

//       if (picked != null &&
//           picked != activityController.selectedDateRange.value) {
//         activityController.setDateRange(picked);
//       }
//     }

//     // Main UI layout
//     return Padding(
//       padding:
//           EdgeInsets.symmetric(horizontal: ScreenUtil().screenHeight * 0.02),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 0.02),
//           Container(
//             height: ScreenUtil().screenHeight * 0.18,
//             padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(12)),
//               image: DecorationImage(
//                 image: AssetImage('assets/images/account_bg.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: GroupUserSection(name: name, groupId: id),
//           ),
//           const SizedBox(height: 0.01),
//           const UserProgressCard(
//             currentPoints: 0,
//             nextLevelPoints: 1,

//           ),
//           const SizedBox(height: 0.01),
//           Center(
//             child: Obx(() {
//               return TripSummaryGraph(
//                 // data: activityController.data,
//                 // xLabels: activityController.xLabels,
//                 selectedDateRange: activityController.selectedDateRange.value,
//                 pickDateRange: pickDateRange,
//               );
//             }),
//           ),
//           SizedBox(height: 10.h),
//           Column(
//             children: [
//               GroupActivityRow(id: id, name: name),
//               SizedBox(height: 10.h),
//               GroupMembersRow(id: id, name: name),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class GroupActivityRow extends StatefulWidget {
//   final String id;
//   final String name;
//   GroupActivityRow({required this.id, required this.name});

//   @override
//   State<GroupActivityRow> createState() => _GroupActivityRowState();
// }

// class _GroupActivityRowState extends State<GroupActivityRow> {
//   final GroupController groupController = Get.find<GroupController>();
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       groupController.fetchGroupMembersDetails(widget.id);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetX<GroupController>(
//       init: Get.find<GroupController>(),
//       builder: (controller) {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (controller.errorMessage.value.isNotEmpty) {
//           return Center(
//             child: Text('Error: ${controller.errorMessage.value}'),
//           );
//         }

//         final memberDetails = controller.groupMembersDetails.value;
//         if (memberDetails == null) {
//           return const Center(child: Text('No group members found'));
//         }
//         if (memberDetails.members.isEmpty) {
//           return const Center(child: Text('No group members found'));
//         }

//         final displayedMembers = memberDetails.members.take(3).toList();

//         return Container(
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20.r),
//               color: EVColors.accent1),
//           padding: EdgeInsets.all(ScreenUtil().screenWidth * 0.02),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Activity",
//                 style: CustomTextTheme.bodyMediumPBold.copyWith(
//                   color: Colors.black,
//                 ),
//               ),
//               Row(children: [
//                 Row(
//                   children: displayedMembers.map((member) {
//                     return CircleAvatar(
//                       radius: 15,
//                       backgroundImage: NetworkImage(member.avatar),
//                     );
//                   }).toList(),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     // Navigate to MemberDetailPage when Activity is tapped
//                     // This page already shows each user's activity
//                     Get.to(
//                       () => MemberDetailPage(
//                         groupMembers: memberDetails,
//                         name: widget.name,
//                       ),
//                     );
//                   },
//                   child: const Icon(
//                     Icons.arrow_forward_ios,
//                     size: 18,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ]),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class GroupMembersRow extends StatefulWidget {
//   final String id;
//   final String name;
//   GroupMembersRow({required this.id, required this.name});

//   @override
//   State<GroupMembersRow> createState() => _GroupMembersRowState();
// }

// class _GroupMembersRowState extends State<GroupMembersRow> {
//   final GroupController groupController = Get.find<GroupController>();
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       groupController.fetchGroupMembersDetails(widget.id);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetX<GroupController>(
//       init: Get.find<GroupController>(),
//       builder: (controller) {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (controller.errorMessage.value.isNotEmpty) {
//           return Center(
//             child: Text('Error: ${controller.errorMessage.value}'),
//           );
//         }

//         final memberDetails = controller.groupMembersDetails.value;
//         if (memberDetails == null) {
//           return const Center(child: Text('No group members found'));
//         }
//         if (memberDetails.members.isEmpty) {
//           return const Center(child: Text('No group members found'));
//         }

//         final displayedMembers = memberDetails.members.take(3).toList();

//         return Container(
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20.r),
//               color: AppColors.accent1),
//           padding: EdgeInsets.all(ScreenUtil().screenWidth * 0.02),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Members",
//                 style: AppTextThemes.bodyMedium().copyWith(
//                   color: Colors.black,
//                 ),
//               ),
//               Row(children: [
//                 Row(
//                   children: displayedMembers.map((member) {
//                     return CircleAvatar(
//                       radius: 15,
//                       backgroundImage: NetworkImage(member.avatar),
//                     );
//                   }).toList(),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     Get.to(
//                       () => GroupMembersPage(
//                         groupMembers: memberDetails,
//                         name: widget.name,
//                       ),
//                     );
//                   },
//                   child: const Icon(
//                     Icons.arrow_forward_ios,
//                     size: 18,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ]),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }