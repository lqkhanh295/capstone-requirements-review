// Core Data Models according to Capstone Requirements Review SRS v1.0 Section 12

enum RequirementType {
  functional,
  nonFunctional,
  business,
  technical,
  security,
  performance,
  usability,
  other;

  String get label {
    switch (this) {
      case RequirementType.functional:
        return 'Functional';
      case RequirementType.nonFunctional:
        return 'Non-functional';
      case RequirementType.business:
        return 'Business';
      case RequirementType.technical:
        return 'Technical';
      case RequirementType.security:
        return 'Security';
      case RequirementType.performance:
        return 'Performance';
      case RequirementType.usability:
        return 'Usability';
      case RequirementType.other:
        return 'Other';
    }
  }
}

enum ReviewStatus {
  notReviewed,
  passed,
  needsReview,
  failed;

  String get label {
    switch (this) {
      case ReviewStatus.notReviewed:
        return 'Not Reviewed';
      case ReviewStatus.passed:
        return 'Passed';
      case ReviewStatus.needsReview:
        return 'Needs Review';
      case ReviewStatus.failed:
        return 'Failed';
    }
  }
}

enum IssueSeverity {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case IssueSeverity.low:
        return 'Low';
      case IssueSeverity.medium:
        return 'Medium';
      case IssueSeverity.high:
        return 'High';
    }
  }
}

class ReviewIssue {
  final String type; // e.g., 'ambiguity', 'completeness'
  final IssueSeverity severity;
  final String description;

  const ReviewIssue({
    required this.type,
    required this.severity,
    required this.description,
  });

  factory ReviewIssue.fromJson(Map<String, dynamic> json) {
    IssueSeverity severity = IssueSeverity.medium;
    if (json['severity'] == 'low') severity = IssueSeverity.low;
    if (json['severity'] == 'high') severity = IssueSeverity.high;

    return ReviewIssue(
      type: json['type'] as String? ?? 'general',
      severity: severity,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'severity': severity.name,
    'description': description,
  };
}

class QualityScores {
  final int clarity;
  final int completeness;
  final int testability;
  final int consistency;
  final int feasibility;

  const QualityScores({
    required this.clarity,
    required this.completeness,
    required this.testability,
    required this.consistency,
    required this.feasibility,
  });

  factory QualityScores.fromJson(Map<String, dynamic> json) {
    return QualityScores(
      clarity: (json['clarity'] as num?)?.toInt() ?? 0,
      completeness: (json['completeness'] as num?)?.toInt() ?? 0,
      testability: (json['testability'] as num?)?.toInt() ?? 0,
      consistency: (json['consistency'] as num?)?.toInt() ?? 0,
      feasibility: (json['feasibility'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'clarity': clarity,
    'completeness': completeness,
    'testability': testability,
    'consistency': consistency,
    'feasibility': feasibility,
  };
}

class RequirementReview {
  final int overallScore;
  final QualityScores scores;
  final List<ReviewIssue> issues;
  final String? suggestedRevision;

  const RequirementReview({
    required this.overallScore,
    required this.scores,
    required this.issues,
    this.suggestedRevision,
  });

  factory RequirementReview.fromJson(Map<String, dynamic> json) {
    final scoresData = json['scores'] as Map<String, dynamic>? ?? {};
    final issuesData = (json['issues'] as List<dynamic>?) ?? [];

    return RequirementReview(
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
      scores: QualityScores.fromJson(scoresData),
      issues: issuesData
          .map((item) => ReviewIssue.fromJson(item as Map<String, dynamic>))
          .toList(),
      suggestedRevision: json['suggestedRevision'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'overallScore': overallScore,
    'scores': scores.toJson(),
    'issues': issues.map((e) => e.toJson()).toList(),
    if (suggestedRevision != null) 'suggestedRevision': suggestedRevision,
  };
}

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
}

class Requirement {
  final String id; // e.g. REQ-001
  final String title;
  final String description;
  final RequirementType type;
  final String sourceLocation;
  final ReviewStatus status;
  final RequirementReview? review;
  final List<ReviewComment> comments;

  const Requirement({
    required this.id,
    required this.title,
    required this.description,
    this.type = RequirementType.functional,
    this.sourceLocation = '',
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
      status: status ?? this.status,
      review: review ?? this.review,
      comments: comments ?? this.comments,
    );
  }
}

class Document {
  final String id;
  final String name;
  final String filePath;
  final String fileType; // PDF, DOCX, TXT, MD
  final int fileSize;
  final DateTime importedAt;
  final List<Requirement> requirements;

  const Document({
    required this.id,
    required this.name,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.importedAt,
    this.requirements = const [],
  });
}
