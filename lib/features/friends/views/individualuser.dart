import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/profile_controller.dart';
import 'package:mjollnir/shared/components/activity/activity_graph.dart';
import 'package:mjollnir/shared/components/bike/trip_summary_graph.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/components/profile/invite_friends.dart';
import 'package:mjollnir/shared/components/profile/user_header.dart';
import 'package:mjollnir/shared/components/profile/user_progress_card.dart';

class IndividualUserPage extends StatelessWidget {
  final String name;
  final String distance;
  final int points ;
  const IndividualUserPage(
      {super.key, required this.name, required this.distance,required this.points});

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
           const  SizedBox(height:0.02),
            Header(heading: name),
            _UI(name: name, distance: distance,points: points,),
          ],
        ),
      ),
    ));
  }
}

class _UI extends StatelessWidget {
  final String distance;
  final String name;
  final int points;
  _UI({required this.name, required this.distance,required this.points});

  @override
  Widget build(BuildContext context) {
   

     final currentLevel = (points / 100).floor() + 1;
      final nextLevelPoints = currentLevel * 100;

    

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.02),
          Container(
            height: screenHeight * 0.18,
            padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              image: DecorationImage(
                image: AssetImage('assets/images/account_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: UserHeader(
              distance:double.parse(distance) ,
  trips: double.parse(distance).toInt(), // or whatever makes sense for trips
              name: name,
              followers: 0,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
        
           UserProgressCard(
            nextLevelPoints: nextLevelPoints,
        currentPoints: currentLevel,
            level: points,

          ),
          SizedBox(height: screenHeight * 0.01),
          Center(
            
            child: Obx(() {
            final summary = ProfileController().tripSummary.value;
              return ActivityGraphWidget(
        tripSummary:summary ,
        onDateRangeChanged: (dateRange) {},
      );
            }),
          ),
          // SizedBox(height: screenHeight * 0.01),
          // const InviteFriendsCard(
          //   referralCode: ,
          //   onCopyCode: ,
          //   onShare: ,

            
          // ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}