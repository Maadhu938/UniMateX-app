class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  factory NoteModel.fromDoc(String id, Map<String, dynamic> data) {
    return NoteModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  NoteModel copyWith({
    String? title,
    String? content,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
