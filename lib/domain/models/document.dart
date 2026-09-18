import 'requirement.dart';

class Document {
  final String id;
  final String name;
  final String filePath;
  final String fileType; // PDF, DOCX, TXT, MD
  final int fileSize;
  final DateTime importedAt;
  final List<Requirement> requirements;

  const Document({
    required this.id,
    required this.name,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.importedAt,
    this.requirements = const [],
  });

  Document copyWith({
    String? id,
    String? name,
    String? filePath,
    String? fileType,
    int? fileSize,
    DateTime? importedAt,
    List<Requirement>? requirements,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      importedAt: importedAt ?? this.importedAt,
      requirements: requirements ?? this.requirements,
    );
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      fileType: json['fileType'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      importedAt: json['importedAt'] != null
          ? DateTime.tryParse(json['importedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => Requirement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'filePath': filePath,
    'fileType': fileType,
    'fileSize': fileSize,
    'importedAt': importedAt.toIso8601String(),
    'requirements': requirements.map((e) => e.toJson()).toList(),
  };
}
