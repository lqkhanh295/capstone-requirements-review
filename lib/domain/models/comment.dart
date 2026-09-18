class ReviewComment {
  final String id;
  final String author;
  final String text;
  final DateTime createdAt;

  const ReviewComment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  ReviewComment copyWith({
    String? id,
    String? author,
    String? text,
    DateTime? createdAt,
  }) {
    return ReviewComment(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ReviewComment.fromJson(Map<String, dynamic> json) {
    return ReviewComment(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? 'Reviewer',
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };
}
