class Faq {
  final String tableName;
  final String id;
  final String question;
  final String answer;

  Faq({
    required this.tableName,
    required this.id,
    required this.question,
    required this.answer,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      tableName: json['TableName']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Faq{id: $id, question: $question, answer: $answer}';
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      limit: json['limit'] ?? 10,
    );
  }
}

class FaqData {
  final List<Faq> data;
  final Pagination pagination;

  FaqData({
    required this.data,
    required this.pagination,
  });

  factory FaqData.fromJson(Map<String, dynamic> json) {
    return FaqData(
      data: (json['data'] as List?)?.map((item) => Faq.fromJson(item as Map<String, dynamic>)).toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class FaqResponse {
  final bool success;
  final FaqData data;
  final String message;
  final dynamic error;

  FaqResponse({
    required this.success,
    required this.data,
    required this.message,
    this.error,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    return FaqResponse(
      success: json['success'] ?? false,
      data: FaqData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
      message: json['message']?.toString() ?? '',
      error: json['error'],
    );
  }
}