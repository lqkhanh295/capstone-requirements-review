import '../../domain/models/models.dart';
import 'section_detector.dart';

class RequirementExtractor {
  // Regex patterns matching existing Requirement IDs:
  // Examples: REQ-001, REQ_001, FR-001, NFR-001, BR-001, TR-001, SR-001, UC-001, RQ-1, FEAT-01, FUNC-01, SYS-01
  static final RegExp idPattern = RegExp(
    r'(?:\[|\()?(REQ|FR|NFR|BR|TR|SR|PERF|SEC|UC|RQ|FEAT|FUNC|SYS|CR)[-_ ]?(\d+)(?:\]|\))?',
    caseSensitive: false,
  );

  // Table row pattern: | ID | Title | Description | ...
  static final RegExp tableRowPattern = RegExp(r'^\s*\|(.+)\|\s*$');

  /// Extracts requirements from detected sections and raw content
  static List<Requirement> extract({
    required List<DetectedSection> sections,
    String? sourceName,
  }) {
    final List<Requirement> result = [];
    int autoIdCounter = 1;

    for (final section in sections) {
      final sectionReqs = _extractFromSection(
        section: section,
        autoIdCounterStart: autoIdCounter,
        sourceName: sourceName,
      );

      for (final req in sectionReqs) {
        result.add(req);
        // If an auto-generated ID was used, advance counter
        if (req.id.startsWith('REQ-') && int.tryParse(req.id.replaceFirst('REQ-', '')) != null) {
          final val = int.parse(req.id.replaceFirst('REQ-', ''));
          if (val >= autoIdCounter) {
            autoIdCounter = val + 1;
          }
        }
      }
    }

    // Fallback: If no requirements were extracted from sections (e.g. unstructured text)
    if (result.isEmpty) {
      final allLines = sections.expand((s) => s.lines).toList();
      return _extractFromRawLines(allLines, sourceName: sourceName);
    }

    return result;
  }

  static List<Requirement> _extractFromSection({
    required DetectedSection section,
    required int autoIdCounterStart,
    String? sourceName,
  }) {
    final List<Requirement> list = [];
    int currentAutoId = autoIdCounterStart;

    // Buffer for collecting a multi-line requirement
    String? currentId;
    String? currentTitle;
    final List<String> currentDescLines = [];
    RequirementType currentType = section.inferredType;
    int reqStartLine = section.startLine;

    void commitRequirement() {
      if (currentTitle != null || currentDescLines.isNotEmpty) {
        final id = currentId ?? 'REQ-${currentAutoId.toString().padLeft(3, '0')}';
        if (currentId == null) currentAutoId++;

        final title = (currentTitle != null && currentTitle!.isNotEmpty)
            ? currentTitle!
            : (currentDescLines.isNotEmpty ? _extractTitleFromText(currentDescLines.first) : 'Requirement $id');

        // Filter out table headers, border separators, and empty cell fragments
        final cleanTitle = title.replaceAll(RegExp(r'[│─┌┐└┘├┤┬┴┼\|\-\+\s]'), '');
        final lowerTitle = title.toLowerCase().trim();
        final isPseudoHeader = cleanTitle.isEmpty ||
            lowerTitle.contains('description / source context') ||
            lowerTitle.contains('description/source context') ||
            lowerTitle.contains('suggested revision') ||
            lowerTitle.contains('detected issues');

        if (isPseudoHeader) {
          currentId = null;
          currentTitle = null;
          currentDescLines.clear();
          currentType = section.inferredType;
          return;
        }

        final desc = currentDescLines.isNotEmpty
            ? formatDescription(currentDescLines)
            : title;

        final sourceLoc = sourceName != null
            ? '$sourceName (${section.title}, Line $reqStartLine)'
            : '${section.title}, Line $reqStartLine';

        list.add(Requirement(
          id: id.toUpperCase(),
          title: title,
          description: desc,
          type: currentType,
          sourceLocation: sourceLoc,
          status: ReviewStatus.notReviewed,
        ));
      }
      currentId = null;
      currentTitle = null;
      currentDescLines.clear();
      currentType = section.inferredType;
    }

    for (int i = 0; i < section.lines.length; i++) {
      final rawLine = section.lines[i];
      final line = rawLine.trim();
      final currentLineNumber = section.startLine + i;

      if (line.isEmpty) {
        continue;
      }

      // Check for Markdown table row
      if (tableRowPattern.hasMatch(line)) {
        final tableReq = _parseTableRow(line, section, currentLineNumber, sourceName, currentAutoId);
        if (tableReq != null) {
          commitRequirement();
          list.add(tableReq);
          if (tableReq.id.startsWith('REQ-')) {
            final val = int.tryParse(tableReq.id.replaceFirst('REQ-', ''));
            if (val != null && val >= currentAutoId) {
              currentAutoId = val + 1;
            }
          }
          continue;
        }
      }

      // Check for explicit ID match at start of line
      final idMatch = idPattern.firstMatch(line);
      final isLineStartId = idMatch != null && idMatch.start < 8;

      if (isLineStartId) {
        commitRequirement();
        reqStartLine = currentLineNumber;

        final prefix = idMatch.group(1)!.toUpperCase();
        final number = int.tryParse(idMatch.group(2)!) ?? 1;
        currentId = '$prefix-${number.toString().padLeft(3, '0')}';
        currentType = _inferTypeFromPrefix(prefix, section.inferredType);

        // Extract remaining text on the same line as title
        final afterId = line.substring(idMatch.end).replaceAll(RegExp(r'^[:\.\-\s]+'), '').trim();
        if (afterId.isNotEmpty) {
          final parts = afterId.split(RegExp(r'(?<=[.!?])\s+'));
          currentTitle = parts.first;
          if (parts.length > 1) {
            currentDescLines.add(parts.sublist(1).join(' '));
          }
        }
        continue;
      }

      // Check for bullet point or numbered item indicating a requirement
      final isItemBullet = RegExp(r'^(\*|-|\+|\d+[\.\)])\s+').hasMatch(line);
      final containsRequirementKeyword = RegExp(r'(shall|must|should|cần phải|phải|hệ thống)', caseSensitive: false).hasMatch(line);

      if (isItemBullet && (containsRequirementKeyword || currentId != null)) {
        commitRequirement();
        reqStartLine = currentLineNumber;

        final cleanItem = line.replaceAll(RegExp(r'^(\*|-|\+|\d+[\.\)])\s+'), '').trim();
        final parts = cleanItem.split(RegExp(r'(?<=[.!?])\s+'));
        currentTitle = parts.first;
        if (parts.length > 1) {
          currentDescLines.add(parts.sublist(1).join(' '));
        } else {
          currentDescLines.add(cleanItem);
        }
        continue;
      }

      // Otherwise, line is part of description of current requirement
      if (currentTitle != null || currentId != null) {
        currentDescLines.add(line);
      }
    }

    // Commit any last requirement
    commitRequirement();

    return list;
  }

  static Requirement? _parseTableRow(
    String line,
    DetectedSection section,
    int lineNumber,
    String? sourceName,
    int autoId,
  ) {
    // Split by | and filter
    final parts = line.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length < 2) return null;

    // Ignore header separator rows |---|---|
    if (parts.any((p) => RegExp(r'^-{2,}$').hasMatch(p))) return null;

    // Look for ID in first or second column
    String? foundId;
    int idCol = -1;
    for (int i = 0; i < parts.length; i++) {
      final match = idPattern.firstMatch(parts[i]);
      if (match != null) {
        final prefix = match.group(1)!.toUpperCase();
        final num = int.tryParse(match.group(2)!) ?? 1;
        foundId = '$prefix-${num.toString().padLeft(3, '0')}';
        idCol = i;
        break;
      }
    }

    if (foundId == null) {
      // Check if table column looks like a requirement
      if (parts.length >= 2 && RegExp(r'(shall|must|should|phải)', caseSensitive: false).hasMatch(line)) {
        foundId = 'REQ-${autoId.toString().padLeft(3, '0')}';
        idCol = -1;
      } else {
        return null;
      }
    }

    String title = '';
    String description = '';

    if (idCol == 0 && parts.length > 1) {
      title = parts[1];
      description = parts.length > 2 ? parts.sublist(2).join(' - ') : title;
    } else if (idCol == 1 && parts.length > 2) {
      title = parts[2];
      description = parts.length > 3 ? parts.sublist(3).join(' - ') : title;
    } else {
      title = parts[0];
      description = parts.sublist(1).join(' - ');
    }

    // Filter out table header rows or pseudo-columns
    final cleanTitle = title.replaceAll(RegExp(r'[│─┌┐└┘├┤┬┴┼\|\-\+\s]'), '');
    final lowerTitle = title.toLowerCase().trim();
    if (cleanTitle.isEmpty ||
        lowerTitle.contains('description / source context') ||
        lowerTitle.contains('description/source context') ||
        lowerTitle.contains('suggested revision') ||
        lowerTitle.contains('detected issues') ||
        lowerTitle == 'title' ||
        lowerTitle == 'requirement' ||
        lowerTitle == 'requirement id') {
      return null;
    }

    final reqType = _inferTypeFromPrefix(foundId, section.inferredType);
    final sourceLoc = sourceName != null
        ? '$sourceName (${section.title}, Row $lineNumber)'
        : '${section.title}, Row $lineNumber';

    return Requirement(
      id: foundId,
      title: title,
      description: description,
      type: reqType,
      sourceLocation: sourceLoc,
      status: ReviewStatus.notReviewed,
    );
  }

  /// Formats raw extracted lines into clean flowing sentences and paragraphs.
  /// Merges accidental line breaks while preserving bullet lists and multi-paragraph spacing.
  static String formatDescription(List<String> rawLines) {
    if (rawLines.isEmpty) return '';

    final List<String> paragraphs = [];
    final StringBuffer currentParagraph = StringBuffer();

    for (final rawLine in rawLines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        if (currentParagraph.isNotEmpty) {
          paragraphs.add(currentParagraph.toString().trim());
          currentParagraph.clear();
        }
        continue;
      }

      final isBullet = RegExp(r'^(\*|-|\+|\u2022|\d+[\.\)])\s+').hasMatch(line);
      if (isBullet) {
        if (currentParagraph.isNotEmpty) {
          paragraphs.add(currentParagraph.toString().trim());
          currentParagraph.clear();
        }
        paragraphs.add(line);
      } else {
        if (currentParagraph.isNotEmpty) {
          final cur = currentParagraph.toString();
          if (!cur.endsWith(' ') && !cur.endsWith('\n')) {
            currentParagraph.write(' ');
          }
        }
        currentParagraph.write(line);
      }
    }

    if (currentParagraph.isNotEmpty) {
      paragraphs.add(currentParagraph.toString().trim());
    }

    return paragraphs.join('\n\n');
  }

  static List<Requirement> _extractFromRawLines(List<String> lines, {String? sourceName}) {
    final List<Requirement> list = [];
    int autoId = 1;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (RegExp(r'(shall|must|should|phải|yêu cầu)', caseSensitive: false).hasMatch(line) && line.length > 20) {
        final id = 'REQ-${autoId.toString().padLeft(3, '0')}';
        autoId++;

        list.add(Requirement(
          id: id,
          title: _extractTitleFromText(line),
          description: line,
          type: RequirementType.functional,
          sourceLocation: sourceName != null ? '$sourceName (Line ${i + 1})' : 'Line ${i + 1}',
          status: ReviewStatus.notReviewed,
        ));
      }
    }

    return list;
  }

  static RequirementType _inferTypeFromPrefix(String prefix, RequirementType fallback) {
    final p = prefix.toUpperCase();
    if (p.startsWith('FR') || p.startsWith('FUNC') || p.startsWith('FEAT')) return RequirementType.functional;
    if (p.startsWith('NFR')) return RequirementType.nonFunctional;
    if (p.startsWith('SEC') || p.startsWith('SR')) return RequirementType.security;
    if (p.startsWith('PERF')) return RequirementType.performance;
    if (p.startsWith('BR') || p.startsWith('CR')) return RequirementType.business;
    if (p.startsWith('TR') || p.startsWith('SYS')) return RequirementType.technical;
    return fallback;
  }

  static String _extractTitleFromText(String text) {
    final clean = text.replaceAll(RegExp(r'^(\*|-|\+|\d+[\.\)])\s+'), '').trim();
    final firstSentence = clean.split(RegExp(r'(?<=[.!?])\s+')).first;
    if (firstSentence.length > 80) {
      return '${firstSentence.substring(0, 77)}...';
    }
    return firstSentence;
  }
}
