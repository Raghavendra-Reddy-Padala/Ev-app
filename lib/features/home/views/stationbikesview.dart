import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/core/storage/local_storage.dart';
import 'package:mjollnir/core/utils/logger.dart';
import 'package:mjollnir/features/bikes/controller/bike_controller.dart';
import 'package:mjollnir/features/home/views/planview.dart';
import 'package:mjollnir/shared/components/bike/bike_card.dart';
import 'package:mjollnir/shared/components/header/header.dart';
import 'package:mjollnir/shared/constants/colors.dart';
import 'package:mjollnir/shared/models/stations/station.dart';

class StationBikesView extends StatelessWidget {
  final Station station;

  const StationBikesView({super.key, required this.station});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
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
    authToken ??= "";
    final BikeController bikeController = Get.find<BikeController>();

    await bikeController.fetchBikesByStationId(station.id);

    if (bikeController.errorMessage.isNotEmpty) {
      AppLogger.e(bikeController.errorMessage.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BikeController bikeController = Get.find<BikeController>();
    
    return Column(
      children: [
        // Header
        Header(
          heading: station.name,
        ),
        
        // Content
        Expanded(
          child: FutureBuilder<void>(
            future: _fetchBikes(context),
            builder: (context, snapshot) {
              return Obx(() {
                if (bikeController.isLoading.value) {
                  return  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }
                
                if (bikeController.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          bikeController.errorMessage.value,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => _fetchBikes(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (bikeController.bikes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bike_outlined,
                          size: 48.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No bikes available at this station',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'Available Bikes',
                      //   style: TextStyle(
                      //     fontSize: 20.sp,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.black,
                      //   ),
                      // ),
                      SizedBox(height: 16.h),
                      
                      ...bikeController.bikes.map(
                        (bike) => BikeCard(
                          bike: bike,
                          onSelectPlan: () {
                   Get.to(() => PlanType(bike: bike));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}