class DocumentParseException implements Exception {
  final String message;
  final dynamic details;

  DocumentParseException(this.message, [this.details]);

  @override
  String toString() => 'DocumentParseException: $message ${details != null ? '($details)' : ''}';
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
