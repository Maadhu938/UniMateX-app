class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String subjectCode;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.subjectCode,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';

  bool get isDueSoon {
    final now = DateTime.now();
    final diff = dueDate.difference(now);
    return diff.inDays <= 1 && diff.inDays >= 0;
  }

  factory AssignmentModel.fromDoc(String id, Map<String, dynamic> data) {
    return AssignmentModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subject: data['subject'] ?? '',
      subjectCode: data['subjectCode'] ?? '',
      dueDate: data['dueDate']?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'subjectCode': subjectCode,
      'dueDate': dueDate,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AssignmentModel copyWith({
    String? status,
  }) {
    return AssignmentModel(
      id: id,
      title: title,
      description: description,
      subject: subject,
      subjectCode: subjectCode,
      dueDate: dueDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
