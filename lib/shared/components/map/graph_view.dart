import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mjollnir/shared/constants/constants.dart';
import '../../constants/colors.dart';

class GraphView extends StatelessWidget {
  final Map<int, double> data;

  /// Labels for the x-axis, where key corresponds to the key in [data].
  final Map<int, String> xLabels;

  /// Whether to show y-axis labels.
  final bool showYAxisLabels;

  /// Whether to show horizontal grid lines.
  final bool showHorizontalLines;

  /// Whether to show the company logo.
  final bool showLogo;

  /// Whether to use the parent's background color.
  final bool useParentColor;

  /// Creates a [GraphView] widget.
  const GraphView({
    super.key,
    required this.data,
    required this.xLabels,
    this.showYAxisLabels = false,
    this.showHorizontalLines = true,
    this.showLogo = true,
    this.useParentColor = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);

    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    final List<MapEntry<int, double>> dataEntries = data.entries.toList();

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          _buildChartContent(dataEntries),
          if (showLogo) _buildLogo(),
        ],
      ),
    );
  }

  /// Gets the background color based on settings.
  Color _getBackgroundColor(BuildContext context) {
    return useParentColor
        ? Theme.of(context).scaffoldBackgroundColor
        : Colors.white;
  }

  /// Builds the empty state widget when no data is available.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
        child: Text("No data available",
            style: Theme.of(context).textTheme.bodySmall));
  }

  /// Builds the chart content including the bar chart and baseline.
  Widget _buildChartContent(List<MapEntry<int, double>> dataEntries) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 35),
      child: Stack(
        children: [
          _buildBarChart(dataEntries),
          _buildBaseline(),
        ],
      ),
    );
  }

  /// Builds the bar chart using the provided data.
  Widget _buildBarChart(List<MapEntry<int, double>> dataEntries) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: _createBarGroups(dataEntries),
        minY: 0,
        borderData: FlBorderData(show: false),
        titlesData: _createTitlesData(dataEntries),
        gridData: _createGridData(),
      ),
    );
  }

  /// Creates bar chart groups from data entries.
  List<BarChartGroupData> _createBarGroups(
      List<MapEntry<int, double>> dataEntries) {
    return List.generate(dataEntries.length, (index) {
      final entry = dataEntries[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.0),
                AppColors.primary,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: ScreenUtil().screenHeight * 0.015,
          ),
        ],
      );
    });
  }

  /// Creates title data for the chart axes.
  FlTitlesData _createTitlesData(List<MapEntry<int, double>> dataEntries) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) =>
              _buildXAxisLabel(value, dataEntries),
          reservedSize: 28,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showYAxisLabels,
          reservedSize: 40,
          getTitlesWidget: _buildYAxisLabel,
        ),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  /// Builds an x-axis label widget.
  Widget _buildXAxisLabel(
      double value, List<MapEntry<int, double>> dataEntries) {
    final int idx = value.toInt();

    if (idx < 0 || idx >= dataEntries.length) {
      return const SizedBox.shrink();
    }

    final originalKey = dataEntries[idx].key;
    final label = xLabels[originalKey] ?? 'N/A';
    var style = TextStyle(
      fontSize: 9.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );

    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Text(
        label,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds a y-axis label widget.
  Widget _buildYAxisLabel(double value, TitleMeta meta) {
    return Text(
      '${value.toInt()} Hr',
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
    );
  }

  /// Creates grid data for the chart.
  FlGridData _createGridData() {
    return FlGridData(
      show: showHorizontalLines,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.withOpacity(0.5),
          strokeWidth: 0.5,
        );
      },
    );
  }

  /// Builds the baseline for the x-axis.
  Widget _buildBaseline() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 30,
      child: Container(
        height: 1.5,
        color: Colors.grey.withOpacity(0.2),
      ),
    );
  }

  /// Builds the company logo.
  Widget _buildLogo() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: ScreenUtil().screenWidth * 0.35,
          height: ScreenUtil().screenWidth * 0.05,
          child: Image.asset(Constants.currentLogo),
        ),
      ),
    );
  }
}
