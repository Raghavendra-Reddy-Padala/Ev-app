import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final String description;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  String getFormattedTimestamp() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(timestamp);
  }
}

class TransactionResponse {
  final bool success;
  final List<Transaction> transactions;
  final String message;

  TransactionResponse({
    required this.success,
    required this.transactions,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': transactions.map((transaction) => transaction.toJson()).toList(),
      'message': message,
    };
  }

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return TransactionResponse(
      success: json['success'] ?? false,
      transactions: data != null && data is List
          ? data
              .map((transactionJson) => Transaction.fromJson(transactionJson))
              .toList()
          : [],
      message: json['message'] ?? '',
    );
  }
}
