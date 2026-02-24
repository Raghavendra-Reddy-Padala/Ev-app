import 'package:flutter/material.dart';

class ActivityGraphData {
  final Map<int, double> data;
  final Map<int, String> xLabels;
  final DateTimeRange dateRange;
  final String metric; // 'distance', 'time', 'calories', 'trips'
  final double totalValue;
  final String unit;

  ActivityGraphData({
    required this.data,
    required this.xLabels,
    required this.dateRange,
    required this.metric,
    required this.totalValue,
    required this.unit,
  });

  factory ActivityGraphData.fromJson(
      Map<String, dynamic> json, DateTimeRange dateRange, String metric) {
    final Map<int, double> data = {};
    final Map<int, String> xLabels = {};

    final rawData = json['data'];
    final rawLabels = json['x_labels'];

    if (rawData != null) {
      if (rawData is List) {
        // Array format: [{value: ..., label: ...}, ...]
        for (int i = 0; i < rawData.length; i++) {
          final item = rawData[i];
          data[i] = (item['value'] ?? 0.0).toDouble();
          xLabels[i] = item['label'] ?? '';
        }
      } else if (rawData is Map) {
        // Map format from backend: {"0": 5.2, "1": 3.1, ...}
        rawData.forEach((key, value) {
          final index = int.tryParse(key.toString()) ?? 0;
          data[index] = (value ?? 0.0).toDouble();
        });
        // Parse x_labels map
        if (rawLabels != null && rawLabels is Map) {
          rawLabels.forEach((key, value) {
            final index = int.tryParse(key.toString()) ?? 0;
            xLabels[index] = value?.toString() ?? '';
          });
        }
      }
    }

    // If no labels were parsed, generate day labels from date range
    if (xLabels.isEmpty && data.isNotEmpty) {
      for (final key in data.keys) {
        final date = dateRange.start.add(Duration(days: key));
        xLabels[key] = _formatDateLabel(date, dateRange.end.difference(dateRange.start).inDays + 1);
      }
    }

    return ActivityGraphData(
      data: data,
      xLabels: xLabels,
      dateRange: dateRange,
      metric: metric,
      totalValue: (json['total_value'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? _getUnitForMetric(metric),
    );
  }

  factory ActivityGraphData.dummy(DateTimeRange dateRange, String metric) {
    final days = dateRange.end.difference(dateRange.start).inDays + 1;
    final Map<int, double> data = {};
    final Map<int, String> xLabels = {};
    double totalValue = 0;
    String unit = '';

    for (int i = 0; i < days && i < 7; i++) {
      final date = dateRange.start.add(Duration(days: i));
      final dayValue = _generateDummyValue(metric, i);

      data[i] = dayValue;
      xLabels[i] = _formatDateLabel(date, days);
      totalValue += dayValue;
    }

    unit = _getUnitForMetric(metric);

    return ActivityGraphData(
      data: data,
      xLabels: xLabels,
      dateRange: dateRange,
      metric: metric,
      totalValue: totalValue,
      unit: unit,
    );
  }

  static double _generateDummyValue(String metric, int index) {
    final baseValues = {
      'distance': [2.5, 4.2, 1.8, 6.1, 3.7, 5.3, 7.2],
      'time': [0.8, 1.2, 0.6, 1.8, 1.1, 1.5, 2.1],
      'calories': [120, 180, 85, 250, 150, 200, 300],
      'trips': [1, 2, 1, 3, 2, 2, 4],
    };

    final values = baseValues[metric] ?? [1, 2, 3, 4, 5, 6, 7];
    return values[index % values.length].toDouble();
  }

  static String _formatDateLabel(DateTime date, int totalDays) {
    if (totalDays <= 7) {
      // Show day names for week view
      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return dayNames[date.weekday - 1];
    } else if (totalDays <= 31) {
      // Show dates for month view
      return '${date.day}';
    } else {
      // Show month/day for longer periods
      return '${date.month}/${date.day}';
    }
  }

  static String _getUnitForMetric(String metric) {
    switch (metric) {
      case 'distance':
        return 'km';
      case 'time':
        return 'hrs';
      case 'calories':
        return 'kcal';
      case 'trips':
        return 'trips';
      default:
        return '';
    }
  }
}
