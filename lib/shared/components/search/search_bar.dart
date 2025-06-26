import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mjollnir/features/home/controller/station_controller.dart';
import 'package:mjollnir/features/home/views/stationbikesview.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<StationController>();
    final getStationsController = Get.find<StationController>();
    final searchText = ''.obs;
    final isFocused = false.obs;
    final showDropdown = false.obs;
    
    homeController.searchController.addListener(() {
      searchText.value = homeController.searchController.text;
      // Only show dropdown if focused, has minimum 2 characters, and has results
      showDropdown.value = isFocused.value && 
                          searchText.value.length >= 2 && 
                          homeController.filteredStations.isNotEmpty;
    });

    return GestureDetector(
      onTap: () {
        // Close dropdown when tapping outside
        if (showDropdown.value) {
          showDropdown.value = false;
          isFocused.value = false;
          FocusScope.of(context).unfocus();
        }
      },
      child: SizedBox(
        width: ScreenUtil().screenWidth * 0.50,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: homeController.searchController,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for stations...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 22.w,
                  ),
                  suffixIcon: Obx(() => searchText.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade600,
                            size: 20.w,
                          ),
                          onPressed: () {
                            homeController.searchController.clear();
                            _updateFilteredStations(homeController, getStationsController, '');
                            showDropdown.value = false;
                            isFocused.value = false;
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : Container(
                          padding: EdgeInsets.all(12.w),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey.shade600,
                            size: 22.w,
                          ),
                        ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onTap: () {
                  isFocused.value = true;
                  // Only show dropdown if there's text with minimum length
                  if (searchText.value.length >= 2) {
                    showDropdown.value = true;
                  }
                },
                onChanged: (query) {
                  _updateFilteredStations(homeController, getStationsController, query);
                  
                  // Show dropdown only if focused, minimum 2 characters, and has results
                  showDropdown.value = isFocused.value && 
                                      query.length >= 2 && 
                                      homeController.filteredStations.isNotEmpty;
                },
                onSubmitted: (value) {
                  showDropdown.value = false;
                  isFocused.value = false;
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            
            // Enhanced Dropdown Results - Only show when conditions are met
            Obx(() {
              if (!showDropdown.value) {
                return const SizedBox.shrink();
              }
              
              return Container(
                margin: EdgeInsets.only(top: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  maxHeight: 220.h,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: homeController.filteredStations.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final station = homeController.filteredStations[index];
                      final availableBikes = station.currentCapacity;
                      final totalCapacity = station.capacity;
                      final isLowCapacity = availableBikes < (totalCapacity * 0.3);
                      
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Clear search and close dropdown
                            homeController.searchController.clear();
                            _updateFilteredStations(homeController, getStationsController, '');
                            showDropdown.value = false;
                            isFocused.value = false;
                            FocusScope.of(context).unfocus();
                            
                            // Navigate to station details view only
                            Get.to(() => StationBikesView(station: station));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            child: Row(
                              children: [
                                // Station Icon
                                Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: BoxDecoration(
                                    color: isLowCapacity 
                                        ? Colors.orange.shade50 
                                        : Colors.green.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.directions_bike,
                                    color: isLowCapacity 
                                        ? Colors.orange.shade600 
                                        : Colors.green.shade600,
                                    size: 22.w,
                                  ),
                                ),
                                
                                SizedBox(width: 16.w),
                                
                                // Station Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        station.name,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.pedal_bike,
                                            size: 14.w,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '$availableBikes/$totalCapacity bikes available',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Arrow Icon
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14.w,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
            
            // Map Navigation Button - Only show when dropdown is visible
            Obx(() {
              if (!showDropdown.value || homeController.filteredStations.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 8.h),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to map and close dropdown
                    if (homeController.filteredStations.isNotEmpty) {
                      final station = homeController.filteredStations.first;
                      final stationLocation = LatLng(
                        double.tryParse(station.locationLatitude) ?? 0.0,
                        double.tryParse(station.locationLongitude) ?? 0.0,
                      );
                      
                      homeController.searchController.clear();
                      _updateFilteredStations(homeController, getStationsController, '');
                      showDropdown.value = false;
                      isFocused.value = false;
                      FocusScope.of(context).unfocus();
                      homeController.goToLocation(stationLocation);
                    }
                  },
                  icon: Icon(
                    Icons.map,
                    size: 18.w,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Show on Map',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _updateFilteredStations(StationController homeController, StationController stationsController, String query) {
    if (query.isEmpty || query.length < 2) {
      homeController.filteredStations.clear();
    } else {
      final filtered = stationsController.nearbyStations
          .where((station) => station.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      homeController.filteredStations.assignAll(filtered);
    }
  }
}