import 'package:intl/intl.dart';

class Controllers {
  Future<void> initControllers() async {
    // Initialize controllers here
  }
  Future<void> deleteController() async {
    // Delete controller here
  }
}

class BalanceFormatter {
  static String formatBalance(double balance) {
    if (balance >= 1000000000) {
      return '₹ ${(balance / 1000000000).toStringAsFixed(1)}B';
    } else if (balance >= 1000000) {
      return '₹ ${(balance / 1000000).toStringAsFixed(1)}M';
    } else if (balance >= 1000) {
      return '₹ ${(balance / 1000).toStringAsFixed(1)}K';
    } else {
      return "₹ ${balance.toString()}";
    }
  }

  static String formatTransactionAmount(String amount) {
    String sanitizedAmount = amount.replaceAll(" rs", "").trim();
    double value = double.parse(sanitizedAmount);

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toString();
    }
  }
}

class GraphDataProcessor {
  // Process raw trip data into graph data format
  static Map<int, double> processData(List<dynamic> rawData) {
    Map<int, double> processedData = {};

    for (int i = 0; i < rawData.length; i++) {
      final item = rawData[i];
      final double value = _extractValue(item);
      processedData[i] = value;
    }

    return processedData;
  }

  // Extract numeric value from raw data item
  static double _extractValue(dynamic item) {
    if (item is Map) {
      if (item.containsKey('distance')) {
        return double.tryParse(item['distance'].toString()) ?? 0.0;
      } else if (item.containsKey('value')) {
        return double.tryParse(item['value'].toString()) ?? 0.0;
      }
    } else if (item is num) {
      return item.toDouble();
    }

    return 0.0;
  }

  // Generate x-axis labels from dates
  static Map<int, String> generateDateLabels(List<DateTime> dates,
      {String format = 'dd/MM'}) {
    Map<int, String> labels = {};
    final DateFormat formatter = DateFormat(format);

    for (int i = 0; i < dates.length; i++) {
      labels[i] = formatter.format(dates[i]);
    }

    return labels;
  }

  // Calculate total from graph data
  static double calculateTotal(Map<int, double> data) {
    return data.values.fold(0.0, (sum, value) => sum + value);
  }
}
