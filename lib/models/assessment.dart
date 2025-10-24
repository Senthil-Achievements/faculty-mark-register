class Assessment {
  final int? id;
  final int subjectId;
  final String name;
  final double maxMarks;
  final DateTime createdAt;

  Assessment({
    this.id,
    required this.subjectId,
    required this.name,
    required this.maxMarks,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'max_marks': maxMarks,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'],
      subjectId: map['subject_id'],
      name: map['name'],
      maxMarks: map['max_marks'].toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
