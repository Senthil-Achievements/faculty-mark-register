class Student {
  final int? id;
  final int subjectId;
  final String name;
  final String rollNo;
  final DateTime createdAt;

  Student({
    this.id,
    required this.subjectId,
    required this.name,
    required this.rollNo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'roll_no': rollNo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      subjectId: map['subject_id'],
      name: map['name'],
      rollNo: map['roll_no'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
