import 'enums.dart';
import 'comment.dart';
import 'review.dart';

class Requirement {
  final String id; // e.g. REQ-001, FR-001
  final String title;
  final String description;
  final RequirementType type;
  final String sourceLocation;
  final int? startLine;
  final int? endLine;
  final ReviewStatus status;
  final RequirementReview? review;
  final List<ReviewComment> comments;

  const Requirement({
    required this.id,
    required this.title,
    required this.description,
    this.type = RequirementType.functional,
    this.sourceLocation = '',
    this.startLine,
    this.endLine,
    this.status = ReviewStatus.notReviewed,
    this.review,
    this.comments = const [],
  });

  Requirement copyWith({
    String? id,
    String? title,
    String? description,
    RequirementType? type,
    String? sourceLocation,
    int? startLine,
    int? endLine,
    ReviewStatus? status,
    RequirementReview? review,
    List<ReviewComment>? comments,
  }) {
    return Requirement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      sourceLocation: sourceLocation ?? this.sourceLocation,
      startLine: startLine ?? this.startLine,
      endLine: endLine ?? this.endLine,
      status: status ?? this.status,
      review: review ?? this.review,
      comments: comments ?? this.comments,
    );
  }

  factory Requirement.fromJson(Map<String, dynamic> json) {
    return Requirement(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: RequirementType.fromString(json['type'] as String?),
      sourceLocation: json['sourceLocation'] as String? ?? '',
      startLine: (json['startLine'] as num?)?.toInt(),
      endLine: (json['endLine'] as num?)?.toInt(),
      status: ReviewStatus.fromString(json['status'] as String?),
      review: json['review'] != null
          ? RequirementReview.fromJson(json['review'] as Map<String, dynamic>)
          : null,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => ReviewComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'sourceLocation': sourceLocation,
    if (startLine != null) 'startLine': startLine,
    if (endLine != null) 'endLine': endLine,
    'status': status.name,
    if (review != null) 'review': review!.toJson(),
    'comments': comments.map((e) => e.toJson()).toList(),
  };
}
