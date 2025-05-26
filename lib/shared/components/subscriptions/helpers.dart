import 'package:flutter/material.dart';

import '../../models/subscriptions/subscriptions_model.dart';

class SubscriptionStatus {
  final String displayText;
  final Color backgroundColor;
  final Color indicatorColor;
  final bool isActive;

  const SubscriptionStatus({
    required this.displayText,
    required this.backgroundColor,
    required this.indicatorColor,
    required this.isActive,
  });

  static const active = SubscriptionStatus(
    displayText: 'Active',
    backgroundColor: Color(0xFF4CAF50),
    indicatorColor: Color(0xFF81C784),
    isActive: true,
  );

  static const expired = SubscriptionStatus(
    displayText: 'Expired',
    backgroundColor: Color(0xFFF44336),
    indicatorColor: Color(0xFFE57373),
    isActive: false,
  );

  static const expiringSoon = SubscriptionStatus(
    displayText: 'Expiring Soon',
    backgroundColor: Color(0xFFFF9800),
    indicatorColor: Color(0xFFFFB74D),
    isActive: true,
  );
}

class SubscriptionStatusHelper {
  static SubscriptionStatus getStatus(UserSubscriptionData subscription) {
    final DateTime currentDate = DateTime.now();
    final DateTime endDate = DateHelper.parseDate(subscription.endDate);
    final int daysUntilExpiry = endDate.difference(currentDate).inDays;

    if (endDate.isBefore(currentDate)) {
      return SubscriptionStatus.expired;
    } else if (daysUntilExpiry <= 7) {
      return SubscriptionStatus.expiringSoon;
    } else {
      return SubscriptionStatus.active;
    }
  }
}

class DateHelper {
  static DateTime parseDate(String dateStr) {
    try {
      final List<String> parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      throw const FormatException("Invalid date format");
    } catch (e) {
      debugPrint('Error parsing date: $dateStr - $e');
      return DateTime.now();
    }
  }

  static String formatShortDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  static String formatLongDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
