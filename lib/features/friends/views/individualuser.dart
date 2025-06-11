import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/account/controllers/profile_controller.dart';
import 'package:mjollnir/shared/components/activity/activity_graph.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/components/profile/user_header.dart';
import 'package:mjollnir/shared/components/profile/user_progress_card.dart';

class IndividualUserPage extends StatelessWidget {
  final String name;
  final String distance;
  final int trips;
  final int followers;
  final int points;
  final String avatharurl;
  final String uid;
  const IndividualUserPage(
      {super.key,
      required this.name,
      required this.trips,
      required this.followers,
      required this.distance,
      required this.avatharurl,
      required this.uid,
      required this.points});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Header(heading: name),
            _UI(
              uid: uid,
              trips: trips,
              followers: followers,
              avatharurl: avatharurl,
              name: name,
              distance: distance,
              points: points,
            ),
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
  final String avatharurl;
   final int trips;
  final int followers;
  final String uid;
  const _UI({required this.name, required this.distance, required this.points,required  this.avatharurl, required this.trips, required this.followers,required this.uid});

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
          SizedBox(height: screenHeight * 0.01),
          Container(
            height: screenHeight * 0.18,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration:  BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              image: DecorationImage(
                image: Image.asset("assets/images/account_bg.png")
                    .image,
                fit: BoxFit.cover,
              ),
            ),
            child: UserHeader(
              avatarUrl: avatharurl,
              distance: double.parse(distance),
              trips:  trips, 
              name: name,
              followers: followers.toInt(),
              uid:uid ,
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
                tripSummary: summary,
                onDateRangeChanged: (dateRange) {},
              );
            }),
          ),
          

          // ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}
