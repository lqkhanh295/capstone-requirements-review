import '../../domain/models/models.dart';

class DetectedSection {
  final String title;
  final RequirementType inferredType;
  final int startLine;
  final int endLine;
  final List<String> lines;

  DetectedSection({
    required this.title,
    required this.inferredType,
    required this.startLine,
    required this.endLine,
    required this.lines,
  });
}

class SectionDetector {
  static final Map<RequirementType, List<RegExp>> sectionKeywords = {
    RequirementType.security: [
      RegExp(r'(security|bảo mật|authentication|authorization|access control)', caseSensitive: false),
    ],
    RequirementType.performance: [
      RegExp(r'(performance|hiệu năng|speed|tải|latency|throughput|response time)', caseSensitive: false),
    ],
    RequirementType.usability: [
      RegExp(r'(usability|khả năng sử dụng|ui/ux|giao diện|accessibility)', caseSensitive: false),
    ],
    RequirementType.nonFunctional: [
      RegExp(r'(non-functional|non functional|nonfunctional|phi chức năng|nfr|quality attributes)', caseSensitive: false),
    ],
    RequirementType.business: [
      RegExp(r'(business requirement|yêu cầu nghiệp vụ|quy trình nghiệp vụ|business rule)', caseSensitive: false),
    ],
    RequirementType.technical: [
      RegExp(r'(technical requirement|yêu cầu kỹ thuật|kiến trúc|công nghệ|infrastructure)', caseSensitive: false),
    ],
    RequirementType.functional: [
      RegExp(r'(functional requirement|yêu cầu chức năng|chức năng hệ thống|system features|user requirements)', caseSensitive: false),
    ],
  };

  /// Detects whether a single line looks like a section header
  static bool isSectionHeader(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.length > 120) return false;

    // A requirement ID is never a section header
    if (RegExp(r'^(?:\[|\()?(REQ|FR|NFR|BR|TR|SR|PERF|SEC|UC|RQ)[-_ ]?\d+', caseSensitive: false).hasMatch(trimmed)) {
      return false;
    }

    // Markdown headers: #, ##, ###
    if (RegExp(r'^#{1,4}\s+').hasMatch(trimmed)) {
      return true;
    }

    // Bullet points or numbered lists are not section headers
    if (RegExp(r'^(\*|-|\+)\s+').hasMatch(trimmed)) {
      return false;
    }

    // Sentences containing modal verbs (shall, must, should, will) are requirements, not headers
    if (RegExp(r'\b(shall|must|will|should|phải|cần phải)\b', caseSensitive: false).hasMatch(trimmed)) {
      return false;
    }

    // Numbered sections: 1. , 3.2 , Section 4
    if (RegExp(r'^(Section|Chương|Phần|\d+(\.\d+)*)\s*[:\.\-]?\s+[A-Z\p{Lu}]', unicode: true).hasMatch(trimmed)) {
      return true;
    }

    // ALL CAPS Short header: e.g. "FUNCTIONAL REQUIREMENTS"
    if (RegExp(r'^[A-Z0-9\s\-–—]{4,60}$').hasMatch(trimmed) && !trimmed.contains('.')) {
      return true;
    }

    // Check if line matches any section keyword header (short title without terminating period)
    if (trimmed.length < 60 && !trimmed.endsWith('.')) {
      for (final patterns in sectionKeywords.values) {
        for (final pattern in patterns) {
          if (pattern.hasMatch(trimmed)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Infer RequirementType from a section title or context string
  static RequirementType inferTypeFromHeader(String title) {
    final clean = title.toLowerCase();

    // Check more specific types first (security, performance, usability, non-functional)
    for (final entry in sectionKeywords.entries) {
      for (final pattern in entry.value) {
        if (pattern.hasMatch(clean)) {
          return entry.key;
        }
      }
    }

    return RequirementType.functional;
  }

  /// Splits document lines into detected sections
  static List<DetectedSection> detectSections(List<String> rawLines) {
    final List<DetectedSection> sections = [];
    String currentTitle = 'General Requirements';
    RequirementType currentType = RequirementType.functional;
    int sectionStart = 0;
    List<String> currentLines = [];

    for (int i = 0; i < rawLines.length; i++) {
      final line = rawLines[i];
      final trimmed = line.trim();

      if (isSectionHeader(trimmed)) {
        // If we have accumulated lines from a previous section, finalize it
        if (currentLines.isNotEmpty) {
          sections.add(DetectedSection(
            title: currentTitle,
            inferredType: currentType,
            startLine: sectionStart + 1,
            endLine: i,
            lines: List.from(currentLines),
          ));
        }

        // Start new section
        currentTitle = trimmed.replaceAll(RegExp(r'^[#\s\d\.\-:]+'), '').trim();
        if (currentTitle.isEmpty) currentTitle = trimmed;
        currentType = inferTypeFromHeader(trimmed);
        sectionStart = i;
        currentLines = [];
      } else {
        currentLines.add(line);
      }
    }

    // Add remaining section
    if (currentLines.isNotEmpty) {
      sections.add(DetectedSection(
        title: currentTitle,
        inferredType: currentType,
        startLine: sectionStart + 1,
        endLine: rawLines.length,
        lines: currentLines,
      ));
    }

    return sections;
  }
}
