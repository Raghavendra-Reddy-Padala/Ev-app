import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/bikes/controller/bike_controller.dart';
import 'package:mjollnir/shared/components/bike/bike_card.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/models/stations/station.dart';

class StationBikesView extends StatelessWidget {
  final Station station;

  const StationBikesView({super.key, required this.station});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _UI(station: station),
      ),
    );
  }
}

class _UI extends StatelessWidget {
  final Station station;

  const _UI({required this.station});

  Future<void> _fetchBikes(BuildContext context) async {
    String? authToken = LocalStorage().getToken();
    if (authToken == null) {
      AppLogger.e('Auth token is null');
      return;
    }
    final BikeController bikeController = Get.find<BikeController>();

    await bikeController.fetchBikesByStationId(
      station.id,
      
    );

    if (bikeController.errorMessage.isNotEmpty) {
    AppLogger.e(bikeController.errorMessage.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BikeController bikeController = Get.find<BikeController>();
    return FutureBuilder<void>(
      future: _fetchBikes(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (bikeController.errorMessage.isNotEmpty) {
          return Center(child: Text(bikeController.errorMessage.value));
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              Header(
                heading: station.name,
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children:[
                    ...bikeController.bikes.map(
                      (bike) => BikeCard(
                        bike: bike,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
