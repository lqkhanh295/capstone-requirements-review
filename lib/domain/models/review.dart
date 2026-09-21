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
  final int ambiguity;
  final int duplication;
  final Map<String, int> dynamicScores;

  const QualityScores({
    this.clarity = 80,
    this.completeness = 80,
    this.testability = 80,
    this.consistency = 80,
    this.feasibility = 80,
    this.ambiguity = 85,
    this.duplication = 90,
    this.dynamicScores = const {},
  });

  int getScore(String criterionId) {
    if (dynamicScores.containsKey(criterionId)) {
      return dynamicScores[criterionId]!;
    }
    switch (criterionId.toLowerCase()) {
      case 'clarity':
        return clarity;
      case 'completeness':
      case 'crud_completeness':
        return completeness;
      case 'testability':
        return testability;
      case 'consistency':
      case 'clarity_consistency':
        return consistency;
      case 'feasibility':
      case 'feasibility_security':
        return feasibility;
      case 'ambiguity':
        return ambiguity;
      case 'duplication':
        return duplication;
      default:
        if (dynamicScores.isNotEmpty) {
          return dynamicScores.values.reduce((a, b) => a + b) ~/ dynamicScores.length;
        }
        return (clarity + completeness + testability) ~/ 3;
    }
  }

  QualityScores copyWith({
    int? clarity,
    int? completeness,
    int? testability,
    int? consistency,
    int? feasibility,
    int? ambiguity,
    int? duplication,
    Map<String, int>? dynamicScores,
  }) {
    return QualityScores(
      clarity: clarity ?? this.clarity,
      completeness: completeness ?? this.completeness,
      testability: testability ?? this.testability,
      consistency: consistency ?? this.consistency,
      feasibility: feasibility ?? this.feasibility,
      ambiguity: ambiguity ?? this.ambiguity,
      duplication: duplication ?? this.duplication,
      dynamicScores: dynamicScores ?? this.dynamicScores,
    );
  }

  factory QualityScores.fromJson(Map<String, dynamic> json) {
    final dyn = <String, int>{};
    for (final entry in json.entries) {
      if (entry.value is num) {
        dyn[entry.key] = (entry.value as num).toInt();
      }
    }

    final clarityVal = (json['clarity'] as num?)?.toInt() ?? dyn['clarity_consistency'] ?? dyn['clarity'] ?? 80;
    final compVal = (json['completeness'] as num?)?.toInt() ?? dyn['crud_completeness'] ?? dyn['completeness'] ?? 80;
    final testVal = (json['testability'] as num?)?.toInt() ?? dyn['testability'] ?? 80;
    final consVal = (json['consistency'] as num?)?.toInt() ?? dyn['clarity_consistency'] ?? dyn['consistency'] ?? 80;
    final feasVal = (json['feasibility'] as num?)?.toInt() ?? dyn['feasibility_security'] ?? dyn['feasibility'] ?? 80;
    final ambVal = (json['ambiguity'] as num?)?.toInt() ?? dyn['ambiguity'] ?? 85;
    final dupVal = (json['duplication'] as num?)?.toInt() ?? dyn['duplication'] ?? 90;

    return QualityScores(
      clarity: clarityVal,
      completeness: compVal,
      testability: testVal,
      consistency: consVal,
      feasibility: feasVal,
      ambiguity: ambVal,
      duplication: dupVal,
      dynamicScores: dyn,
    );
  }

  Map<String, dynamic> toJson() => {
    'clarity': clarity,
    'completeness': completeness,
    'testability': testability,
    'consistency': consistency,
    'feasibility': feasibility,
    'ambiguity': ambiguity,
    'duplication': duplication,
    if (dynamicScores.isNotEmpty) 'dynamicScores': dynamicScores,
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
