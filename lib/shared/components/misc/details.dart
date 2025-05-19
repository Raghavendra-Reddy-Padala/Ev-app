import 'package:bolt_ui_kit/bolt_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mjollnir/shared/models/user/user_model.dart';

class Details extends StatelessWidget {
  final Trip trip;
  
  const Details({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Content(
            trip: trip,
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}

class Content extends StatelessWidget {
  final Trip trip;
  const Content({super.key, required this.trip});

  String getFormattedStartTime() {
    if (trip.startTimestamp == null) return "Not Started";
    return DateFormat('MM-dd kk:mm a').format(trip.startTimestamp!);
  }

  String getFormattedEndTime() {
    if (trip.endTimestamp == null) return "In Progress";
    return DateFormat('MM-dd kk:mm a').format(trip.endTimestamp!);
  }

  String getFormattedDuration() {
    if (trip.startTimestamp == null) return "0 Min";
    
    Duration duration;
    if (trip.endTimestamp == null) {
      duration = DateTime.now().difference(trip.startTimestamp!);
    } else {
      duration = trip.endTimestamp!.difference(trip.startTimestamp!);
    }
    
    int hours = duration.inHours;
    int minutes = (duration.inMinutes % 60);
    
    if (hours > 0) {
      return "$hours Hrs $minutes Min";
    } else {
      return "$minutes Min";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to check screen width for responsive layouts
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;
    
    return isSmallScreen 
        ? _buildSmallScreenLayout()
        : _buildWideScreenLayout();
  }

  Widget _buildWideScreenLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RowHelper(
          title: "Start Time",
          value: trip.startTimestamp.toString(),
          title2: "End Time",
          value2: getFormattedEndTime(),
          title3: "Distance",
          value3: trip.distance.toString(),
        ),
        SizedBox(height: 16.h),
        RowHelper(
          title: "Run Time",
          value: trip.duration.toString(),
          title2: "Calories",
          value2: trip.kcal.toString(),
          title3: "Speed",
          value3: trip.averageSpeed.toString(),
        ),
        SizedBox(height: 16.h),
        RowHelperTwoColumns(
          title: "Maximum Elevation",
          value: trip.maxElevation.toDouble(),
          title2: "Carbon Footprint",
          value2: 10,
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSmallScreenRow("Start Time", trip.startTimestamp.toString()),
        _buildSmallScreenRow("End Time", getFormattedEndTime()),
        _buildSmallScreenRow("Distance", trip.distance.toString()),
        _buildSmallScreenRow("Run Time", trip.duration.toString()),
        _buildSmallScreenRow("Calories", trip.kcal.toString()),
        _buildSmallScreenRow("Speed", trip.averageSpeed.toString()),
        _buildSmallScreenRow("Maximum Elevation", trip.maxElevation.toString()),
        _buildSmallScreenRow("Carbon Footprint", "10"),
      ],
    );
  }

  Widget _buildSmallScreenRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme().textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          Text(
            _formatValueByTitle(title, value == "null" ? "" : value),
style: AppTheme.lightTheme().textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatValueByTitle(String title, String value) {
    if (title == "Start Time" || title == "End Time") {
      return formatDate(value);
    } else if (value.isEmpty || value == "null") {
      return "N/A";
    } else {
      try {
        double numValue = double.parse(value);
        switch (title) {
          case "Distance":
            return "${(numValue / 1000).toStringAsFixed(1)} Km";
          case "Calories":
            return "${numValue.round()} Kcal";
          case "Speed":
            return "${numValue.toStringAsFixed(1)} km/h";
          case "Maximum Elevation":
            return "${numValue.round()} m";
          case "Carbon Footprint":
            return "$numValue CO2";
          default:
            return value;
        }
      } catch (e) {
        return value;
      }
    }
  }

  String formatDate(String date) {
    if (date == "null" || date.isEmpty) {
      return "N/A";
    }
    
    try {
      DateTime parsed = DateTime.parse(date);
      String formattedDate = DateFormat('MM-dd kk:mm a').format(parsed);
      return formattedDate;
    } catch (e) {
      print("Error parsing date: $date - $e");
      return "Invalid Date";
    }
  }
}

class RowHelper extends StatelessWidget {
  final String title;
  final String value;
  final String title2;
  final String value2;
  final String title3;
  final String value3;

  const RowHelper({
    super.key,
    required this.title,
    required this.value,
    required this.title2,
    required this.value2,
    required this.title3,
    required this.value3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        
        // If width is too narrow, stack columns vertically
        if (availableWidth < 450) {
          return Column(
            children: [
              _buildColumnHelper(context, title, value),
              SizedBox(height: 16.h),
              _buildColumnHelper(context, title2, value2),
              SizedBox(height: 16.h),
              _buildColumnHelper(context, title3, value3),
            ],
          );
        }
        
        // Otherwise use the original row layout
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildColumnHelper(context, title, value),
            _buildColumnHelper(context, title2, value2),
            _buildColumnHelper(context, title3, value3),
          ],
        );
      }
    );
  }

  Widget _buildColumnHelper(BuildContext context, String title, String value) {
    return ColumnHelper(
      title: title,
      value: (title == "Start Time" || title == "End Time")
          ? formatDate(value == "null" ? "" : value)
          : _formatValue(
              title,
              value.isEmpty || value == "null" ? 0.0 : double.parse(value),
            ),
    );
  }

  String formatDistance(double distance) {
    return "${(distance / 1000).toStringAsFixed(1)} Km"; // Convert meters to kilometers
  }

  String formatDate(String date) {
    if (date == "null" || date.isEmpty) {
      return "N/A";
    }
    
    try {
      DateTime parsed = DateTime.parse(date);
      String formattedDate = DateFormat('MM-dd kk:mm a').format(parsed);
      return formattedDate;
    } catch (e) {
      print("Error parsing date: $date - $e");
      return "Invalid Date";
    }
  }

  String formatCalories(double calories) {
    return "${calories.round()} Kcal";
  }

  String formatSpeed(double speed) {
    return "${speed.toStringAsFixed(1)} km/h";
  }

  String _formatValue(String title, double value) {
    switch (title) {
      case "Distance":
        return formatDistance(value);
      case "Calories":
        return formatCalories(value);
      case "Speed":
        return formatSpeed(value);
      case "Maximum Elevation":
        return "${value.round()} m";
      case "Carbon Footprint":
        return "$value CO2";
      default:
        return value.toString();
    }
  }
}

class RowHelperTwoColumns extends StatelessWidget {
  final String title;
  final double value;
  final String title2;
  final double value2;

  const RowHelperTwoColumns({
    super.key,
    required this.title,
    required this.value,
    required this.title2,
    required this.value2,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is too narrow, stack columns vertically
        if (constraints.maxWidth < 350) {
          return Column(
            children: [
              ColumnHelper(
                title: title,
                value: _formatValue(title, value),
              ),
              SizedBox(height: 16.h),
              ColumnHelper(
                title: title2,
                value: _formatValue(title2, value2),
              ),
            ],
          );
        }
        
        // Otherwise use the original row layout
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColumnHelper(
              title: title,
              value: _formatValue(title, value),
            ),
            SizedBox(width: 40.w),
            ColumnHelper(
              title: title2,
              value: _formatValue(title2, value2),
            ),
          ],
        );
      }
    );
  }

  String _formatValue(String title, double value) {
    switch (title) {
      case "Maximum Elevation":
        return "${value.round()} m";
      case "Carbon Footprint":
        return "$value CO2";
      default:
        return value.toString();
    }
  }
}

// Helper class for the columns
class ColumnHelper extends StatelessWidget {
  final String title;
  final String value;

  const ColumnHelper({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTheme.lightTheme().textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTheme.lightTheme().textTheme.bodySmall?.copyWith(
            color: (Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}