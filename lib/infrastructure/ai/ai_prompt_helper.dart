import 'dart:convert';
import '../../domain/models/models.dart';

class AIPromptHelper {
  static const String systemInstruction = '''
You are an expert Software Requirements Quality Assurance Auditor.
Your task is to analyze software requirements specifications according to IEEE-830 / ISO/IEC/IEEE 29148 standards.

Evaluate the requirement against 7 key dimensions:
1. Clarity (0-100): Clear, unambiguous language, active voice, easy to understand.
2. Completeness (0-100): Specifies actor, action, trigger/precondition, and expected outcome/error handling.
3. Testability (0-100): Measurable, verifiable pass/fail criteria and quantifiable metrics.
4. Consistency (0-100): Free from internal contradictions or conflicts.
5. Feasibility (0-100): Technically realistic and achievable.
6. Ambiguity (0-100): Absence of vague terms like "fast", "user-friendly", "flexible", "etc.".
7. Duplication (0-100): Unique scope without redundant overlapping requirements.

You must respond STRICTLY with valid JSON matching the following structure without any markdown wrap or extra commentary:
{
  "overallScore": 85,
  "scores": {
    "clarity": 85,
    "completeness": 80,
    "testability": 90,
    "consistency": 95,
    "feasibility": 90,
    "ambiguity": 80,
    "duplication": 95
  },
  "issues": [
    {
      "type": "Ambiguity",
      "severity": "medium",
      "description": "The term 'quickly' is subjective and unverifiable."
    }
  ],
  "suggestedRevision": "The system shall process and display search query results within 500 milliseconds under normal load."
}
''';

  static String buildUserPrompt(Requirement req, {List<Requirement>? allRequirements}) {
    final buffer = StringBuffer();
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

  static RequirementReview parseAIResponse(String responseBody) {
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
      return RequirementReview.fromJson(json);
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
