import 'dart:convert';
import '../../domain/models/models.dart';

class AIPromptHelper {
  static String get systemInstruction => buildSystemInstruction(Rubric.fptCapstone);

  static String buildSystemInstruction([Rubric? rubric]) {
    final activeRubric = rubric ?? Rubric.fptCapstone;
    final buffer = StringBuffer();
    buffer.writeln('You are an expert Software Requirements Quality Assurance Auditor.');
    buffer.writeln('Your task is to analyze software requirements specifications strictly according to:');
    buffer.writeln('${activeRubric.name} - ${activeRubric.organization}');
    buffer.writeln('${activeRubric.description}\n');
    buffer.writeln('Evaluate the requirement against the following dimensions:');
    for (int i = 0; i < activeRubric.criteria.length; i++) {
      final c = activeRubric.criteria[i];
      buffer.writeln('${i + 1}. ${c.name} (${c.id}) [Weight ${(c.weight * 100).toInt()}%]: ${c.description}. Guidelines: ${c.promptGuideline}');
    }
    buffer.writeln('\nYou must respond STRICTLY with valid JSON matching the following structure without any markdown wrap or extra commentary:');
    buffer.writeln('{');
    buffer.writeln('  "overallScore": 85,');
    buffer.writeln('  "scores": {');
    final scorePairs = activeRubric.criteria.map((c) => '    "${c.id}": 85').join(',\n');
    buffer.writeln(scorePairs);
    buffer.writeln('  },');
    buffer.writeln('  "issues": [');
    buffer.writeln('    {');
    buffer.writeln('      "type": "${activeRubric.criteria.first.name}",');
    buffer.writeln('      "severity": "medium",');
    buffer.writeln('      "description": "Specific issue description."');
    buffer.writeln('    }');
    buffer.writeln('  ],');
    buffer.writeln('  "suggestedRevision": "The system shall process and display search query results within 500 milliseconds under normal load."');
    buffer.writeln('}');
    return buffer.toString();
  }

  static String buildUserPrompt(Requirement req, {List<Requirement>? allRequirements, Rubric? rubric}) {
    final buffer = StringBuffer();
    if (rubric != null) {
      buffer.writeln('Apply standard: ${rubric.name}');
    }
    buffer.writeln('Analyze the following requirement:');
    buffer.writeln('ID: ${req.id}');
    buffer.writeln('Type: ${req.type.label}');
    buffer.writeln('Title: ${req.title}');
    buffer.writeln('Description: ${req.description}');

    if (allRequirements != null && allRequirements.length > 1) {
      buffer.writeln('\nContext - Other requirements in the specification (for consistency & duplication check):');
      for (final other in allRequirements.take(15)) {
        if (other.id != req.id) {
          buffer.writeln('- [${other.id}] ${other.title}: ${other.description}');
        }
      }
    }

    return buffer.toString();
  }

  static RequirementReview parseAIResponse(String responseBody, [Rubric? rubric]) {
    try {
      // Strip markdown code fences if present e.g. ```json ... ```
      var cleaned = responseBody.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      // Find first '{' and last '}'
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        cleaned = cleaned.substring(start, end + 1);
      }

      final Map<String, dynamic> json = jsonDecode(cleaned) as Map<String, dynamic>;
      final parsedReview = RequirementReview.fromJson(json);

      if (rubric != null && parsedReview.scores.dynamicScores.isNotEmpty) {
        double weightedSum = 0.0;
        double totalWeight = 0.0;
        for (final criterion in rubric.criteria) {
          final score = parsedReview.scores.getScore(criterion.id);
          weightedSum += score * criterion.weight;
          totalWeight += criterion.weight;
        }
        if (totalWeight > 0) {
          final computedOverall = (weightedSum / totalWeight).round();
          return parsedReview.copyWith(overallScore: computedOverall);
        }
      }

      return parsedReview;
    } catch (e) {
      // Fallback in case of parse anomaly
      return RequirementReview(
        overallScore: 70,
        scores: const QualityScores(
          clarity: 70,
          completeness: 70,
          testability: 70,
          consistency: 70,
          feasibility: 70,
          ambiguity: 70,
          duplication: 70,
        ),
        issues: [
          ReviewIssue(
            type: 'AI Parse Note',
            severity: IssueSeverity.low,
            description: 'AI output parsed with fallback: $e',
          ),
        ],
        suggestedRevision: reqFallbackText(responseBody),
      );
    }
  }

  static String? reqFallbackText(String response) {
    if (response.contains('suggestedRevision')) {
      final match = RegExp(r'"suggestedRevision"\s*:\s*"([^"]+)"').firstMatch(response);
      if (match != null) return match.group(1);
    }
    return null;
  }
}
