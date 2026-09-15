import 'enums.dart';

class ReviewIssue {
  final String type; // e.g., 'ambiguity', 'completeness', 'testability'
  final IssueSeverity severity;
  final String description;

  const ReviewIssue({
    required this.type,
    required this.severity,
    required this.description,
  });

  ReviewIssue copyWith({
    String? type,
    IssueSeverity? severity,
    String? description,
  }) {
    return ReviewIssue(
      type: type ?? this.type,
      severity: severity ?? this.severity,
      description: description ?? this.description,
    );
  }

  factory ReviewIssue.fromJson(Map<String, dynamic> json) {
    return ReviewIssue(
      type: json['type'] as String? ?? 'general',
      severity: IssueSeverity.fromString(json['severity'] as String?),
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

  QualityScores copyWith({
    int? clarity,
    int? completeness,
    int? testability,
    int? consistency,
    int? feasibility,
  }) {
    return QualityScores(
      clarity: clarity ?? this.clarity,
      completeness: completeness ?? this.completeness,
      testability: testability ?? this.testability,
      consistency: consistency ?? this.consistency,
      feasibility: feasibility ?? this.feasibility,
    );
  }

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

  RequirementReview copyWith({
    int? overallScore,
    QualityScores? scores,
    List<ReviewIssue>? issues,
    String? suggestedRevision,
  }) {
    return RequirementReview(
      overallScore: overallScore ?? this.overallScore,
      scores: scores ?? this.scores,
      issues: issues ?? this.issues,
      suggestedRevision: suggestedRevision ?? this.suggestedRevision,
    );
  }

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
