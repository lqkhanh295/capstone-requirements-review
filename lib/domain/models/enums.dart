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

  static RequirementType fromString(String? value) {
    if (value == null) return RequirementType.functional;
    final normalized = value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    for (final type in RequirementType.values) {
      if (type.name.toLowerCase() == normalized ||
          type.label.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '') == normalized) {
        return type;
      }
    }
    if (normalized.contains('nonfunc') || normalized.contains('nfr')) {
      return RequirementType.nonFunctional;
    }
    if (normalized.contains('sec')) {
      return RequirementType.security;
    }
    if (normalized.contains('perf')) {
      return RequirementType.performance;
    }
    if (normalized.contains('biz') || normalized.contains('business')) {
      return RequirementType.business;
    }
    if (normalized.contains('tech')) {
      return RequirementType.technical;
    }
    if (normalized.contains('usab')) {
      return RequirementType.usability;
    }
    return RequirementType.functional;
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

  static ReviewStatus fromString(String? value) {
    if (value == null) return ReviewStatus.notReviewed;
    final normalized = value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    for (final status in ReviewStatus.values) {
      if (status.name.toLowerCase() == normalized ||
          status.label.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '') == normalized) {
        return status;
      }
    }
    return ReviewStatus.notReviewed;
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

  static IssueSeverity fromString(String? value) {
    if (value == null) return IssueSeverity.medium;
    final normalized = value.trim().toLowerCase();
    for (final sev in IssueSeverity.values) {
      if (sev.name.toLowerCase() == normalized) {
        return sev;
      }
    }
    return IssueSeverity.medium;
  }
}
