// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../features/home/models/stations/station_model.dart';
// import '../../../features/home/views/stations_view/station_bikes_view.dart';
// import '../../../helpers/constants/colors.dart';
// import '../../../routing/navigator.dart';
// import '../../../ui/theme/text_theme/custom_text_theme.dart';
// import 'arrow_button.dart';
// import 'distance_widget.dart';

// class StationsWidget extends StatelessWidget {
//   final Station station;
//   final double distance;
//   const StationsWidget(
//       {super.key, required this.station, required this.distance});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(top: 10.h, left: 10.h, right: 10.h),
//       child: Container(
//         width: 300.w,
//         height: 90.w,
//         decoration: BoxDecoration(
//           color: EVColors.primary,
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(10.w),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Distance(
//                 distance: distance.toInt(),
//               ),
//               StationNameWidget(
//                 name: station.name,
//                 currentCapacity: station.currentCapacity,
//                 capacity: station.capacity,
//               ),
//               GestureDetector(
//                 onTap: () {
//                   NavigationService.pushTo(
//                     StationBikesView(station: station),
//                   );
//                 },
//                 child: SizedBox(
//                   height: 60.h,
//                   child: Row(
//                     children: [
//                       const VerticalDivider(
//                         color: Colors.white,
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(4.h),
//                         child: const Arrow(left: false),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class StationNameWidget extends StatelessWidget {
//   final String name;
//   final int currentCapacity;
//   final int capacity;
//   const StationNameWidget(
//       {super.key,
//       required this.name,
//       required this.currentCapacity,
//       required this.capacity});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 100.h,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 130.h,
//             height: 26.h,
//             child: Text(
//               name,
//               textAlign: TextAlign.center,
//               style: CustomTextTheme.headlineSmallPBold.copyWith(
//                   color: Colors.white,
//                   overflow: TextOverflow.ellipsis,
//                   fontSize: 16.sp),
//             ),
//           ),
//           SizedBox(height: 5.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconHelper(
//                 isElectric: true,
//                 value: capacity,
//               ),
//               SizedBox(width: 10.h),
//               IconHelper(
//                 isElectric: false,
//                 value: currentCapacity,
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

// class IconHelper extends StatelessWidget {
//   final bool isElectric;
//   final int value;
//   const IconHelper({super.key, required this.isElectric, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         (isElectric)
//             ? Icon(
//                 Icons.electric_bike,
//                 color: Colors.white,
//                 size: 20.w,
//               )
//             : const Icon(
//                 Icons.directions_bike_sharp,
//                 color: Colors.white,
//               ),
//         const SizedBox(
//           width: 2,
//         ),
//         Text(
//           ":  $value",
//           style: CustomTextTheme.bodyMediumP.copyWith(color: Colors.white),
//         )
//       ],
//     );
//   }
// }
