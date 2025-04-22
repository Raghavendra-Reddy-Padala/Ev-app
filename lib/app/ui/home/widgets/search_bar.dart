import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final getStationsController = Get.find<GetStationsController>();
    final searchText = ''.obs;

    homeController.searchController.addListener(() {
      searchText.value = homeController.searchController.text;
    });

    return Column(
      children: [
        _buildSearchField(homeController, getStationsController, searchText),
        _buildSearchResults(homeController),
      ],
    );
  }

  Widget _buildSearchField(HomeController homeController,
      GetStationsController stationsController, RxString searchText) {
    return Container(
      width: ScreenUtil().screenWidth - 20.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: homeController.searchController,
        decoration: InputDecoration(
          hintText: 'Search for a station...',
          prefixIcon: const SizedBox(),
          suffixIcon:
              _buildSuffixIcon(homeController, stationsController, searchText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (query) {
          _updateFilteredStations(homeController, stationsController, query);
        },
      ),
    );
  }

  Widget _buildSuffixIcon(HomeController homeController,
      GetStationsController stationsController, RxString searchText) {
    return Obx(() => searchText.value.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              homeController.searchController.clear();
              _updateFilteredStations(homeController, stationsController, '');
            },
          )
        : const Icon(Icons.location_on));
  }

  Widget _buildSearchResults(HomeController homeController) {
    return Obx(() {
      if (homeController.filteredStations.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 4.0),
        decoration: _getResultsContainerDecoration(),
        constraints: BoxConstraints(maxHeight: 200.h),
        child: _buildResultsList(homeController),
      );
    });
  }

  BoxDecoration _getResultsContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  ListView _buildResultsList(HomeController homeController) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: homeController.filteredStations.length,
      itemBuilder: (context, index) {
        final station = homeController.filteredStations[index];
        return _buildResultItem(homeController, station);
      },
    );
  }

  Widget _buildResultItem(HomeController homeController, dynamic station) {
    return ListTile(
      title: Text(station.name),
      subtitle: Text(
          '${station.currentCapacity}/${station.capacity} bikes available'),
      onTap: () => _onStationSelect(homeController, station),
    );
  }

  void _onStationSelect(HomeController homeController, dynamic station) {
    homeController.searchController.clear();
    _updateFilteredStations(
        homeController, Get.find<GetStationsController>(), '');

    final stationLocation = LatLng(
        double.tryParse(station.locationLatitude) ?? 0.0,
        double.tryParse(station.locationLongitude) ?? 0.0);
    homeController.goToLocation(stationLocation);

    Get.to(() => StationBikesView(station: station));
  }

  void _updateFilteredStations(HomeController homeController,
      GetStationsController stationsController, String query) {
    if (query.isEmpty) {
      homeController.filteredStations.clear();
    } else {
      final filtered = stationsController.nearbyStations
          .where((station) =>
              station.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      homeController.filteredStations.assignAll(filtered);
    }
  }
}
