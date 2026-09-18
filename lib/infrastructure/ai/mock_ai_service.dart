import 'dart:async';
import 'dart:math';
import '../../domain/models/models.dart';
import '../../domain/services/ai_service.dart';

class MockAIService implements AIService {
  @override
  AIProviderType get providerType => AIProviderType.mock;

  @override
  Future<bool> testConnection() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<RequirementReview> reviewRequirement(
    Requirement requirement, {
    List<Requirement>? allRequirements,
  }) async {
    // Simulate slight processing delay for realistic UX
    await Future.delayed(const Duration(milliseconds: 350));

    final text = '${requirement.title} ${requirement.description}'.trim();
    final lower = text.toLowerCase();

    final issues = <ReviewIssue>[];

    // 1. Ambiguity Analysis
    final ambiguousKeywords = [
      'user friendly', 'user-friendly', 'easy to use', 'fast', 'quick',
      'seamless', 'robust', 'flexible', 'efficient', 'intuitive',
      'as appropriate', 'as needed', 'etc', 'etc.', 'reasonable',
      'high performance', 'scalable', 'secure enough', 'sufficient'
    ];

    final foundAmbiguous = ambiguousKeywords.where((kw) => lower.contains(kw)).toList();
    int ambiguityScore = 95;
    if (foundAmbiguous.isNotEmpty) {
      ambiguityScore = max(30, 95 - (foundAmbiguous.length * 20));
      issues.add(ReviewIssue(
        type: 'Ambiguity',
        severity: foundAmbiguous.length > 1 ? IssueSeverity.high : IssueSeverity.medium,
        description: 'Contains subjective or ambiguous terms without concrete definition: "${foundAmbiguous.join('", "')}".',
      ));
    }

    // 2. Testability Analysis
    final hasMetrics = RegExp(r'\b(\d+(\.\d+)?\s*(ms|s|sec|seconds|minutes|%|kb|mb|gb|req/s|fps))\b', caseSensitive: false).hasMatch(text);
    final hasCriteria = RegExp(r'\b(shall|must|will|return|display|save|export|validate)\b', caseSensitive: false).hasMatch(text);
    
    int testabilityScore = 88;
    if (!hasMetrics && (lower.contains('fast') || lower.contains('quick') || lower.contains('performance') || lower.contains('response time'))) {
      testabilityScore = 45;
      issues.add(const ReviewIssue(
        type: 'Testability',
        severity: IssueSeverity.high,
        description: 'Performance requirement lacks quantifiable, measurable acceptance criteria (e.g., maximum response time in milliseconds or throughput in requests per second).',
      ));
    } else if (!hasCriteria) {
      testabilityScore = 60;
      issues.add(const ReviewIssue(
        type: 'Testability',
        severity: IssueSeverity.medium,
        description: 'Lacks explicit verifiable modal verbs (e.g., "The system shall...") making it difficult to formulate pass/fail test cases.',
      ));
    }

    // 3. Completeness Analysis
    int completenessScore = 90;
    final hasActor = RegExp(r'\b(the system|user|admin|system|reviewer|application|server)\b', caseSensitive: false).hasMatch(text);

    if (!hasActor) {
      completenessScore -= 25;
      issues.add(const ReviewIssue(
        type: 'Completeness',
        severity: IssueSeverity.medium,
        description: 'Actor / subject responsible for executing the action is not clearly stated.',
      ));
    }
    if (requirement.description.trim().length < 25) {
      completenessScore -= 30;
      issues.add(const ReviewIssue(
        type: 'Completeness',
        severity: IssueSeverity.high,
        description: 'Description is too brief to fully convey preconditions, triggers, and expected outputs.',
      ));
    }

    // 4. Clarity Analysis
    int clarityScore = 90;
    if (foundAmbiguous.isNotEmpty) {
      clarityScore -= foundAmbiguous.length * 15;
    }
    if (text.contains(';') || text.split('.').length > 4) {
      clarityScore = max(55, clarityScore - 10);
    }
    clarityScore = clarityScore.clamp(20, 100);

    // 5. Duplication Analysis
    int duplicationScore = 95;
    if (allRequirements != null && allRequirements.length > 1) {
      for (final other in allRequirements) {
        if (other.id == requirement.id) continue;
        final sim = _calculateSimilarity(text, '${other.title} ${other.description}');
        if (sim > 0.65) {
          duplicationScore = max(30, 100 - (sim * 80).round());
          issues.add(ReviewIssue(
            type: 'Duplication',
            severity: IssueSeverity.high,
            description: 'Potential duplicate or heavily overlapping scope with requirement ${other.id} ("${other.title}").',
          ));
          break;
        }
      }
    }

    // 6. Consistency Analysis
    int consistencyScore = 92;
    if (lower.contains('instant') && lower.contains('async')) {
      consistencyScore = 50;
      issues.add(const ReviewIssue(
        type: 'Consistency',
        severity: IssueSeverity.high,
        description: 'Conflicting terms found: simultaneous demand for "instantaneous" and "asynchronous" processing.',
      ));
    }

    // 7. Feasibility Analysis
    int feasibilityScore = 95;
    if (lower.contains('100% bug-free') || lower.contains('zero latency') || lower.contains('infinite')) {
      feasibilityScore = 30;
      issues.add(const ReviewIssue(
        type: 'Feasibility',
        severity: IssueSeverity.high,
        description: 'Unrealistic or practically unachievable technical expectation specified.',
      ));
    }

    // Calculate Overall Score (Weighted Average)
    final overall = (
      (clarityScore * 0.20) +
      (completenessScore * 0.20) +
      (testabilityScore * 0.20) +
      (consistencyScore * 0.15) +
      (feasibilityScore * 0.10) +
      (ambiguityScore * 0.15)
    ).round().clamp(10, 100);

    // Construct QualityScores
    final scores = QualityScores(
      clarity: clarityScore,
      completeness: completenessScore,
      testability: testabilityScore,
      consistency: consistencyScore,
      feasibility: feasibilityScore,
      ambiguity: ambiguityScore,
      duplication: duplicationScore,
    );

    // Generate Suggested Revision
    final suggestedRevision = _generateSuggestedRevision(requirement, foundAmbiguous, hasMetrics);

    return RequirementReview(
      overallScore: overall,
      scores: scores,
      issues: issues,
      suggestedRevision: suggestedRevision,
    );
  }

  @override
  Future<List<RequirementReview>> batchReviewRequirements(
    List<Requirement> requirements, {
    void Function(int completed, int total)? onProgress,
    bool Function()? shouldCancel,
  }) async {
    final results = <RequirementReview>[];
    for (int i = 0; i < requirements.length; i++) {
      if (shouldCancel != null && shouldCancel()) {
        break;
      }
      final review = await reviewRequirement(
        requirements[i],
        allRequirements: requirements,
      );
      results.add(review);
      onProgress?.call(i + 1, requirements.length);
    }
    return results;
  }

  String _generateSuggestedRevision(
    Requirement req,
    List<String> ambiguousWords,
    bool hasMetrics,
  ) {
    var revised = req.description.trim();
    if (revised.isEmpty) {
      revised = req.title;
    }

    // Replace ambiguous words with precise language
    if (ambiguousWords.contains('fast') || ambiguousWords.contains('quick')) {
      revised = revised.replaceAll(
        RegExp(r'\b(fast|quick)\b', caseSensitive: false),
        'within 500 milliseconds under normal system load',
      );
    }
    if (ambiguousWords.contains('user friendly') || ambiguousWords.contains('user-friendly') || ambiguousWords.contains('easy to use')) {
      revised = revised.replaceAll(
        RegExp(r'\b(user friendly|user-friendly|easy to use|intuitive)\b', caseSensitive: false),
        'compliant with standard Material Design accessibility guidelines with visible interactive feedback',
      );
    }
    if (ambiguousWords.contains('seamless')) {
      revised = revised.replaceAll(
        RegExp(r'\bseamless\b', caseSensitive: false),
        'uninterrupted background synchronization',
      );
    }
    if (ambiguousWords.contains('etc') || ambiguousWords.contains('etc.')) {
      revised = revised.replaceAll(
        RegExp(r',\s*etc\.?', caseSensitive: false),
        ' including PDF, DOCX, TXT, and Markdown formats',
      );
    }

    // Ensure it begins with standardized requirement syntax
    if (!revised.toLowerCase().startsWith('the system shall') &&
        !revised.toLowerCase().startsWith('the user shall') &&
        !revised.toLowerCase().startsWith('the application shall')) {
      revised = 'The system shall $revised';
    }

    return revised;
  }

  double _calculateSimilarity(String a, String b) {
    final wordsA = a.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 3).toSet();
    final wordsB = b.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 3).toSet();
    if (wordsA.isEmpty || wordsB.isEmpty) return 0.0;
    final intersection = wordsA.intersection(wordsB).length;
    final union = wordsA.union(wordsB).length;
    return intersection / union;
  }
}
