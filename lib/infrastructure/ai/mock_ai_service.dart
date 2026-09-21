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
    Rubric? rubric,
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

    // -----------------------------------------------------------------------
    // FPT Capstone Rubric Heuristics
    // -----------------------------------------------------------------------
    final hasExplicitActor = RegExp(
      r'\b(sinh viên|giảng viên|quản trị viên|người dùng|khách hàng|tác nhân|chuyên viên|admin|user|student|lecturer|staff|manager|customer|system|application|server)\b',
      caseSensitive: false,
    ).hasMatch(text);
    int actorScore = 92;
    if (!hasExplicitActor) {
      actorScore = 55;
    } else if (lower.contains('tất cả') || lower.contains('toàn bộ') || lower.contains('mọi chức năng')) {
      actorScore = 68;
    }

    final hasCrudAction = RegExp(
      r'\b(create|add|update|edit|delete|remove|search|filter|view|display|export|import|thêm|tạo|sửa|cập nhật|xóa|xem|hiển thị|tìm kiếm|lọc|xuất|nhập)\b',
      caseSensitive: false,
    ).hasMatch(text);
    final hasValidationOrFlow = RegExp(
      r'\b(lỗi|thất bại|không hợp lệ|xác thực|kiểm tra|thông báo|điều kiện|error|invalid|fail|validation|verify|validate|condition)\b',
      caseSensitive: false,
    ).hasMatch(text);

    int crudScore = 90;
    if (requirement.description.trim().length < 30) {
      crudScore = 48;
    } else if (!hasCrudAction) {
      crudScore = 62;
    } else if (!hasValidationOrFlow) {
      crudScore = 68;
    }

    int clarityConsistencyScore = max(
      35,
      ((clarityScore * 0.5 + consistencyScore * 0.5) - (foundAmbiguous.length * 10)).round(),
    );

    // -----------------------------------------------------------------------
    // Agile INVEST Rubric Heuristics
    // -----------------------------------------------------------------------
    final hasDependency = RegExp(
      r'\b(phụ thuộc|sau khi|tiếp nối|kèm theo|cần có|yêu cầu trước|depends on|after|requires|coupled)\b',
      caseSensitive: false,
    ).hasMatch(text);
    int independentScore = hasDependency ? 60 : 94;

    final hasValueClause = RegExp(
      r'\b(để|nhằm|giúp|cho phép|so that|in order to|as a|i want|với vai trò|nhờ đó)\b',
      caseSensitive: false,
    ).hasMatch(text);
    int valuableScore = hasValueClause ? 95 : 65;

    int estimableScore = (hasMetrics || (hasCriteria && requirement.description.length > 35)) ? 88 : 62;

    final conjCount = RegExp(r'\b(và|đồng thời|cũng như|and|plus|as well as)\b', caseSensitive: false).allMatches(text).length;
    int smallScore = (conjCount >= 3 || text.split(RegExp(r'\s+')).length > 55) ? 58 : 92;

    final hasRigidTech = RegExp(
      r'\b(pixel|px|#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})|rgb|thẻ html|table column|sql query|select \*|axios|stored procedure)\b',
      caseSensitive: false,
    ).hasMatch(text);
    int negotiableScore = hasRigidTech ? 62 : 90;

    // Specialize issues if a dedicated rubric is active
    final rubricIssues = <ReviewIssue>[];
    if (rubric?.id == 'fpt_capstone_srs') {
      if (actorScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'Actor & Scope',
          severity: IssueSeverity.medium,
          description: 'Chưa xác định rõ Actor/Role chịu trách nhiệm thực hiện hành động này trong hệ thống.',
        ));
      }
      if (crudScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'CRUD & Business Flow',
          severity: IssueSeverity.high,
          description: 'Mô tả nghiệp vụ chưa đầy đủ điều kiện tiên quyết, luồng ngoại lệ hoặc xử lý lỗi khi nhập liệu.',
        ));
      }
      if (testabilityScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'Testability',
          severity: IssueSeverity.high,
          description: 'Thiếu tiêu chí nghiệm thu định lượng cụ thể để thiết kế kịch bản kiểm thử (Test Case).',
        ));
      }
      if (clarityConsistencyScore < 80 && foundAmbiguous.isNotEmpty) {
        rubricIssues.add(ReviewIssue(
          type: 'Clarity & Consistency',
          severity: IssueSeverity.medium,
          description: 'Chứa từ ngữ định tính, mơ hồ: "${foundAmbiguous.join('", "')}".',
        ));
      }
      if (feasibilityScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'Feasibility',
          severity: IssueSeverity.high,
          description: 'Yêu cầu vượt quá giới hạn kỹ thuật hoặc khó hoàn thành trong một học kỳ đồ án.',
        ));
      }
    } else if (rubric?.id == 'agile_invest_standard') {
      if (independentScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'Independent',
          severity: IssueSeverity.medium,
          description: 'Story bị phụ thuộc vào chức năng khác. Nên tách độc lập để có thể release riêng.',
        ));
      }
      if (valuableScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'Valuable',
          severity: IssueSeverity.medium,
          description: 'Chưa làm rõ giá trị nghiệp vụ cho người dùng cuối (thiếu mệnh đề "So that / Để có thể...").',
        ));
      }
      if (estimableScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'Estimable',
          severity: IssueSeverity.medium,
          description: 'Đặc tả còn thiếu độ chi tiết để team phát triển ước lượng Story Points chính xác.',
        ));
      }
      if (smallScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'Small',
          severity: IssueSeverity.high,
          description: 'Story có phạm vi quá lớn (Epic), chứa nhiều chức năng gộp chung cần phân rã cho 1 Sprint.',
        ));
      }
      if (testabilityScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'Testable',
          severity: IssueSeverity.high,
          description: 'Thiếu Acceptance Criteria định lượng hoặc kịch bản Given-When-Then để nghiệm thu.',
        ));
      }
      if (negotiableScore < 80) {
        rubricIssues.add(const ReviewIssue(
          type: 'Negotiable',
          severity: IssueSeverity.medium,
          description: 'Story can thiệp quá sâu vào giải pháp kỹ thuật/giao diện, làm mất tính thương lượng giải pháp.',
        ));
      }
    }

    final finalIssues = rubricIssues.isNotEmpty ? rubricIssues : issues;

    // Calculate Scores across all possible criteria
    final dynScores = <String, int>{
      // IEEE-830
      'clarity': clarityScore,
      'completeness': completenessScore,
      'testability': testabilityScore,
      'consistency': consistencyScore,
      'feasibility': feasibilityScore,
      'ambiguity': ambiguityScore,
      'duplication': duplicationScore,

      // FPT Capstone
      'actor_scope': actorScore,
      'crud_completeness': crudScore,
      'clarity_consistency': clarityConsistencyScore,
      'feasibility_security': feasibilityScore,

      // Agile INVEST
      'independent': independentScore,
      'valuable': valuableScore,
      'estimable': estimableScore,
      'small': smallScore,
      'testable': testabilityScore,
      'negotiable': negotiableScore,
    };

    int overall;
    if (rubric != null && rubric.criteria.isNotEmpty) {
      double weightedSum = 0;
      double weightTotal = 0;
      for (final c in rubric.criteria) {
        final s = dynScores[c.id] ?? dynScores[c.id.toLowerCase()] ?? 80;
        weightedSum += s * c.weight;
        weightTotal += c.weight;
      }
      overall = weightTotal > 0
          ? (weightedSum / weightTotal).round().clamp(10, 100)
          : ((clarityScore + completenessScore + testabilityScore) / 3).round();
    } else {
      overall = (
        (clarityScore * 0.20) +
        (completenessScore * 0.20) +
        (testabilityScore * 0.20) +
        (consistencyScore * 0.15) +
        (feasibilityScore * 0.10) +
        (ambiguityScore * 0.15)
      ).round().clamp(10, 100);
    }

    // Construct QualityScores
    final scores = QualityScores(
      clarity: clarityScore,
      completeness: completenessScore,
      testability: testabilityScore,
      consistency: consistencyScore,
      feasibility: feasibilityScore,
      ambiguity: ambiguityScore,
      duplication: duplicationScore,
      dynamicScores: dynScores,
    );

    // Generate Suggested Revision
    final suggestedRevision = _generateSuggestedRevision(requirement, foundAmbiguous, hasMetrics);

    return RequirementReview(
      overallScore: overall,
      scores: scores,
      issues: finalIssues,
      suggestedRevision: suggestedRevision,
    );
  }

  @override
  Future<List<RequirementReview>> batchReviewRequirements(
    List<Requirement> requirements, {
    void Function(int completed, int total)? onProgress,
    bool Function()? shouldCancel,
    Rubric? rubric,
  }) async {
    final results = <RequirementReview>[];
    for (int i = 0; i < requirements.length; i++) {
      if (shouldCancel != null && shouldCancel()) {
        break;
      }
      final review = await reviewRequirement(
        requirements[i],
        allRequirements: requirements,
        rubric: rubric,
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
