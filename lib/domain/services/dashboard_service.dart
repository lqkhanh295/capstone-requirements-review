import '../models/models.dart';

class RequirementIssueItem {
  final String requirementId;
  final String requirementTitle;
  final String issueType;
  final IssueSeverity severity;
  final String description;

  const RequirementIssueItem({
    required this.requirementId,
    required this.requirementTitle,
    required this.issueType,
    required this.severity,
    required this.description,
  });
}

class DashboardSummary {
  final String documentId;
  final String documentName;
  final DateTime reviewDate;
  final int totalRequirements;
  final int passedCount;
  final int needsReviewCount;
  final int failedCount;
  final int notReviewedCount;
  final int overallQualityScore;
  final List<RequirementIssueItem> recentIssues;
  final Map<RequirementType, int> typeBreakdown;
  final Map<String, double> averageMetricScores; // clarity, completeness, etc.

  const DashboardSummary({
    required this.documentId,
    required this.documentName,
    required this.reviewDate,
    required this.totalRequirements,
    required this.passedCount,
    required this.needsReviewCount,
    required this.failedCount,
    required this.notReviewedCount,
    required this.overallQualityScore,
    required this.recentIssues,
    required this.typeBreakdown,
    required this.averageMetricScores,
  });

  double get passedPercentage =>
      totalRequirements > 0 ? (passedCount / totalRequirements) * 100 : 0.0;
  double get needsReviewPercentage =>
      totalRequirements > 0 ? (needsReviewCount / totalRequirements) * 100 : 0.0;
  double get failedPercentage =>
      totalRequirements > 0 ? (failedCount / totalRequirements) * 100 : 0.0;
  double get notReviewedPercentage =>
      totalRequirements > 0 ? (notReviewedCount / totalRequirements) * 100 : 0.0;
}

class DashboardService {
  static DashboardSummary calculateSummary(Document document) {
    int passed = 0;
    int needsReview = 0;
    int failed = 0;
    int notReviewed = 0;

    int totalScoreSum = 0;
    int reviewedCount = 0;

    int claritySum = 0;
    int completenessSum = 0;
    int testabilitySum = 0;
    int consistencySum = 0;
    int feasibilitySum = 0;

    final Map<RequirementType, int> typeCounts = {
      for (var type in RequirementType.values) type: 0,
    };

    final List<RequirementIssueItem> issueItems = [];

    for (final req in document.requirements) {
      // Type breakdown
      typeCounts[req.type] = (typeCounts[req.type] ?? 0) + 1;

      // Status count
      switch (req.status) {
        case ReviewStatus.passed:
          passed++;
          break;
        case ReviewStatus.needsReview:
          needsReview++;
          break;
        case ReviewStatus.failed:
          failed++;
          break;
        case ReviewStatus.notReviewed:
          notReviewed++;
          break;
      }

      // Review score & metrics
      if (req.review != null) {
        reviewedCount++;
        totalScoreSum += req.review!.overallScore;
        claritySum += req.review!.scores.clarity;
        completenessSum += req.review!.scores.completeness;
        testabilitySum += req.review!.scores.testability;
        consistencySum += req.review!.scores.consistency;
        feasibilitySum += req.review!.scores.feasibility;

        // Collect issues
        for (final issue in req.review!.issues) {
          issueItems.add(
            RequirementIssueItem(
              requirementId: req.id,
              requirementTitle: req.title,
              issueType: issue.type,
              severity: issue.severity,
              description: issue.description,
            ),
          );
        }
      }
    }

    // Sort issues by severity: High -> Medium -> Low
    issueItems.sort((a, b) {
      final severityOrder = {
        IssueSeverity.high: 0,
        IssueSeverity.medium: 1,
        IssueSeverity.low: 2,
      };
      return (severityOrder[a.severity] ?? 3).compareTo(
        severityOrder[b.severity] ?? 3,
      );
    });

    final overallScore = reviewedCount > 0
        ? (totalScoreSum / reviewedCount).round()
        : 0;

    final avgMetrics = <String, double>{
      'Clarity': reviewedCount > 0 ? claritySum / reviewedCount : 0.0,
      'Completeness': reviewedCount > 0 ? completenessSum / reviewedCount : 0.0,
      'Testability': reviewedCount > 0 ? testabilitySum / reviewedCount : 0.0,
      'Consistency': reviewedCount > 0 ? consistencySum / reviewedCount : 0.0,
      'Feasibility': reviewedCount > 0 ? feasibilitySum / reviewedCount : 0.0,
    };

    return DashboardSummary(
      documentId: document.id,
      documentName: document.name,
      reviewDate: document.importedAt,
      totalRequirements: document.requirements.length,
      passedCount: passed,
      needsReviewCount: needsReview,
      failedCount: failed,
      notReviewedCount: notReviewed,
      overallQualityScore: overallScore,
      recentIssues: issueItems,
      typeBreakdown: typeCounts,
      averageMetricScores: avgMetrics,
    );
  }
}
