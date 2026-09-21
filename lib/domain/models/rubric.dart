class RubricCriterion {
  final String id;
  final String name;
  final String description;
  final double weight; // e.g. 0.25 = 25%
  final String promptGuideline;

  const RubricCriterion({
    required this.id,
    required this.name,
    required this.description,
    required this.weight,
    required this.promptGuideline,
  });

  RubricCriterion copyWith({
    String? id,
    String? name,
    String? description,
    double? weight,
    String? promptGuideline,
  }) {
    return RubricCriterion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      promptGuideline: promptGuideline ?? this.promptGuideline,
    );
  }

  factory RubricCriterion.fromJson(Map<String, dynamic> json) {
    return RubricCriterion(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.2,
      promptGuideline: json['promptGuideline'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'weight': weight,
        'promptGuideline': promptGuideline,
      };
}

class Rubric {
  final String id;
  final String name;
  final String organization; // e.g. "FPT University", "IEEE", "Agile Alliance"
  final String description;
  final List<RubricCriterion> criteria;
  final bool isCustom;

  const Rubric({
    required this.id,
    required this.name,
    required this.organization,
    required this.description,
    required this.criteria,
    this.isCustom = false,
  });

  Rubric copyWith({
    String? id,
    String? name,
    String? organization,
    String? description,
    List<RubricCriterion>? criteria,
    bool? isCustom,
  }) {
    return Rubric(
      id: id ?? this.id,
      name: name ?? this.name,
      organization: organization ?? this.organization,
      description: description ?? this.description,
      criteria: criteria ?? this.criteria,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  factory Rubric.fromJson(Map<String, dynamic> json) {
    return Rubric(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      description: json['description'] as String? ?? '',
      criteria: (json['criteria'] as List<dynamic>?)
              ?.map((e) => RubricCriterion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'organization': organization,
        'description': description,
        'criteria': criteria.map((e) => e.toJson()).toList(),
        'isCustom': isCustom,
      };

  /// Preset: FPT University Capstone SRS Standard
  static const Rubric fptCapstone = Rubric(
    id: 'fpt_capstone_srs',
    name: 'FPT University Capstone SRS Standard',
    organization: 'FPT University (Software Engineering)',
    description:
        'Chuẩn chấm đề cương và SRS Đồ án tốt nghiệp tại Đại học FPT. Chú trọng phân định Actor, tính trọn vẹn của luồng CRUD, tính kiểm thử được và không mâu thuẫn giữa các thành viên.',
    criteria: [
      RubricCriterion(
        id: 'actor_scope',
        name: 'Actor & Scope Identification',
        description: 'Xác định rõ ràng vai trò (Actor/Role), quyền hạn và phạm vi ranh giới hệ thống.',
        weight: 0.15,
        promptGuideline:
            'Verify that the requirement clearly specifies the actor/role (e.g. Student, Lecturer, Admin) and stays within realistic project scope.',
      ),
      RubricCriterion(
        id: 'crud_completeness',
        name: 'CRUD & Business Flow Completeness',
        description: 'Mô tả trọn vẹn luồng xử lý chính, luồng thay thế (alternative), điều kiện tiên quyết và xử lý lỗi.',
        weight: 0.30,
        promptGuideline:
            'Ensure full business logic coverage: trigger, preconditions, step-by-step actions, postconditions, and error/exception handling.',
      ),
      RubricCriterion(
        id: 'testability',
        name: 'Testability & Measurable Criteria',
        description: 'Tiêu chí nghiệm thu định lượng, có thể kiểm chứng được bằng kịch bản test cụ thể.',
        weight: 0.25,
        promptGuideline:
            'Must contain verifiable, measurable pass/fail acceptance criteria without vague subjective claims.',
      ),
      RubricCriterion(
        id: 'clarity_consistency',
        name: 'Clarity & Cross Consistency',
        description: 'Văn phong rõ ràng, không dùng từ ngữ mơ hồ, không mâu thuẫn với các requirement khác trong đồ án.',
        weight: 0.15,
        promptGuideline:
            'Check for active voice, unambiguous terminology, and zero conflict or duplication with other requirements in the SRS.',
      ),
      RubricCriterion(
        id: 'feasibility',
        name: 'Feasibility & Project Constraints',
        description: 'Tính khả thi về mặt kỹ thuật, công nghệ và thời gian triển khai trong 1 học kỳ làm Capstone.',
        weight: 0.15,
        promptGuideline:
            'Assess if the feature is realistically implementable by an undergraduate team within a single semester given tech stack and security limits.',
      ),
    ],
  );

  /// Preset: IEEE-830 / ISO 29148 Standard
  static const Rubric ieee830 = Rubric(
    id: 'ieee_830_standard',
    name: 'IEEE-830 / ISO/IEC/IEEE 29148 Standard',
    organization: 'IEEE / ISO Standard',
    description:
        'Bộ tiêu chuẩn công nghiệp quốc tế đánh giá đặc tả phần mềm theo 7 chiều: Clarity, Completeness, Testability, Consistency, Feasibility, Ambiguity, Duplication.',
    criteria: [
      RubricCriterion(
        id: 'clarity',
        name: 'Clarity',
        description: 'Ngôn từ rõ ràng, chính xác, không gây hiểu lầm.',
        weight: 0.15,
        promptGuideline: 'Clear, concise, active voice language.',
      ),
      RubricCriterion(
        id: 'completeness',
        name: 'Completeness',
        description: 'Đầy đủ thông tin về tác nhân, hành động và kết quả mong muốn.',
        weight: 0.20,
        promptGuideline: 'Specifies actor, action, trigger, and expected outcome.',
      ),
      RubricCriterion(
        id: 'testability',
        name: 'Testability',
        description: 'Có thể thiết kế test case đo lường đạt/không đạt.',
        weight: 0.20,
        promptGuideline: 'Measurable, verifiable pass/fail criteria.',
      ),
      RubricCriterion(
        id: 'consistency',
        name: 'Consistency',
        description: 'Nhất quán với các yêu cầu khác, không mâu thuẫn thuật ngữ.',
        weight: 0.15,
        promptGuideline: 'Free from internal contradictions or conflicts.',
      ),
      RubricCriterion(
        id: 'feasibility',
        name: 'Feasibility',
        description: 'Khả thi về mặt kỹ thuật và kiến trúc.',
        weight: 0.10,
        promptGuideline: 'Technically realistic and achievable.',
      ),
      RubricCriterion(
        id: 'ambiguity',
        name: 'Unambiguity',
        description: 'Không chứa từ ngữ mơ hồ như "nhanh", "dễ dùng", "vân vân".',
        weight: 0.10,
        promptGuideline: 'Absence of vague subjective terms like "fast", "user-friendly".',
      ),
      RubricCriterion(
        id: 'duplication',
        name: 'Non-duplication',
        description: 'Không trùng lặp phạm vi với các yêu cầu khác.',
        weight: 0.10,
        promptGuideline: 'Unique scope without redundant overlapping requirements.',
      ),
    ],
  );

  /// Preset: Agile User Story (INVEST)
  static const Rubric agileInvest = Rubric(
    id: 'agile_invest_standard',
    name: 'Agile User Story (INVEST Criteria)',
    organization: 'Agile Alliance',
    description:
        'Bộ tiêu chí chuẩn cho Agile/Scrum: Independent (Độc lập), Negotiable (Có thể thương lượng), Valuable (Có giá trị), Estimable (Ước lượng được), Small (Vừa vặn), Testable (Kiểm thử được).',
    criteria: [
      RubricCriterion(
        id: 'independent',
        name: 'Independent',
        description: 'Có thể phát triển độc lập với các story khác mà không bị phụ thuộc vòng vo.',
        weight: 0.15,
        promptGuideline: 'Story can be delivered and released independently.',
      ),
      RubricCriterion(
        id: 'valuable',
        name: 'Valuable',
        description: 'Mang lại giá trị nghiệp vụ rõ ràng cho người dùng cuối hoặc stakeholder.',
        weight: 0.20,
        promptGuideline: 'Delivers clear end-user or business value in the format: As a... I want to... So that...',
      ),
      RubricCriterion(
        id: 'estimable',
        name: 'Estimable',
        description: 'Đủ rõ để nhóm phát triển có thể ước lượng story point và công sức.',
        weight: 0.15,
        promptGuideline: 'Requirements are clear enough for story point estimation.',
      ),
      RubricCriterion(
        id: 'small',
        name: 'Small (Sized appropriately)',
        description: 'Kích thước vừa vặn để hoàn thành trong một sprint.',
        weight: 0.15,
        promptGuideline: 'Appropriately scoped to be completed within one sprint.',
      ),
      RubricCriterion(
        id: 'testable',
        name: 'Testable',
        description: 'Có Acceptance Criteria rõ ràng theo chuẩn Given-When-Then.',
        weight: 0.20,
        promptGuideline: 'Clear acceptance criteria with Given-When-Then scenarios.',
      ),
      RubricCriterion(
        id: 'negotiable',
        name: 'Negotiable',
        description: 'Không quá cứng nhắc, cho phép trao đổi giải pháp kỹ thuật phù hợp.',
        weight: 0.15,
        promptGuideline: 'Focuses on the "what" and "why", leaving room for design conversation.',
      ),
    ],
  );

  static const List<Rubric> defaultRubrics = [
    fptCapstone,
    ieee830,
    agileInvest,
  ];
}
