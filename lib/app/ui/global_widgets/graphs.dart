import 'package:flutter/material.dart';

class GraphView extends StatelessWidget {
  final Map<int, double> data;
  final Map<int, String> xLabels;
  final bool showYAxisLabels;
  final bool showHorizontalLines;
  final bool showLogo;
  final bool useParentColor;

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
    if (data.isEmpty) {
      return Center(
          child: Text("No data available", style: CustomTextTheme.bodySmallP));
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: _buildContainerDecoration(context),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 35),
            child: Stack(
              children: [
                _buildBarChart(),
                _buildBottomDivider(),
              ],
            ),
          ),
          if (showLogo) _buildLogoWatermark(),
        ],
      ),
    );
  }

  BoxDecoration _buildContainerDecoration(BuildContext context) {
    final Color backgroundColor = useParentColor
        ? Theme.of(context).scaffoldBackgroundColor
        : Colors.white;

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16.0),
    );
  }

  Widget _buildBarChart() {
    final List<MapEntry<int, double>> dataEntries = data.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: _createBarGroups(dataEntries),
        minY: 0,
        borderData: FlBorderData(show: false),
        titlesData: _createTitlesData(),
        gridData: _createGridData(),
      ),
    );
  }

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
                EVColors.primary.withOpacity(0.0),
                EVColors.primary,
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

  FlTitlesData _createTitlesData() {
    return FlTitlesData(
      bottomTitles: _createBottomTitles(),
      leftTitles: _createLeftTitles(),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  AxisTitles _createBottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => _buildBottomTitle(value),
        reservedSize: 28,
      ),
    );
  }

  Widget _buildBottomTitle(double value) {
    final int idx = value.toInt();
    final List<MapEntry<int, double>> dataEntries = data.entries.toList();

    if (idx < 0 || idx >= dataEntries.length) {
      return const SizedBox.shrink();
    }

    final originalKey = dataEntries[idx].key;
    final label = xLabels[originalKey] ?? 'N/A';

    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Text(
        label,
        style: CustomTextTheme.bodySmallP.copyWith(
          fontSize: 9.sp,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  AxisTitles _createLeftTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: showYAxisLabels,
        reservedSize: 40,
        getTitlesWidget: (value, meta) {
          return Text(
            '\${value.toInt()} Hr',
            style: CustomTextTheme.bodySmallP,
          );
        },
      ),
    );
  }

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

  Widget _buildBottomDivider() {
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

  Widget _buildLogoWatermark() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: ScreenUtil().screenWidth * 0.35,
          height: ScreenUtil().screenWidth * 0.05,
          child: const CompanyLogo(),
        ),
      ),
    );
  }
}
