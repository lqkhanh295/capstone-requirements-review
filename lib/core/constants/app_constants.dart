class AppConstants {
  // Application Info
  static const String appName = 'Capstone Requirements Review';
  static const String appVersion = '1.0.0';

  // File Upload Constraints (FR-001, FR-003)
  static const List<String> supportedExtensions = ['pdf', 'docx', 'txt', 'md'];
  static const int maxFileSizeBytes = 20 * 1024 * 1024; // 20 MB max file size
  static const String maxFileSizeReadable = '20 MB';

  // Parser Settings
  static const String defaultRequirementPrefix = 'REQ';
}
