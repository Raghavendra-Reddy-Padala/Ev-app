class Faq {
  final String id;
  final String question;
  final String answer;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class FaqResponse {
  final bool success;
  final List<Faq> data;
  final String message;

  FaqResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    return FaqResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List).map((item) => Faq.fromJson(item)).toList(),
      message: json['message'] ?? '',
    );
  }
}
