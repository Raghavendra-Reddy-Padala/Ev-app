class WalletBalanceResponse {
  final bool success;
  final WalletData data;
  final String message;

  WalletBalanceResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      success: json['success'],
      data: WalletData.fromJson(json['data']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': data.toMap(),
      'message': message,
    };
  }
}

class WalletData {
  final String userId;
  final double balance;

  WalletData({
    required this.userId,
    required this.balance,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      userId: json['user_id'],
      balance: json['balance'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'balance': balance,
    };
  }
}

class OrderResponse {
  final bool success;
  final OrderData data;
  final String message;

  OrderResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      success: json['success'],
      data: OrderData.fromJson(json['data']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
    };
  }
}

class OrderData {
  final OrderDetails data;
  final String message;
  final bool success;

  OrderData({
    required this.data,
    required this.message,
    required this.success,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      data: OrderDetails.fromJson(json['data']),
      message: json['message'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'message': message,
      'success': success,
    };
  }
}

class OrderDetails {
  final String oid;

  OrderDetails({
    required this.oid,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      oid: json['oid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oid': oid,
    };
  }
}
