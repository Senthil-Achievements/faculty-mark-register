class Marks {
  final int? id;
  final int studentId;
  final int assessmentId;
  final double? marks;
  final DateTime updatedAt;

  Marks({
    this.id,
    required this.studentId,
    required this.assessmentId,
    this.marks,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'assessment_id': assessmentId,
      'marks': marks,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Marks.fromMap(Map<String, dynamic> map) {
    return Marks(
      id: map['id'],
      studentId: map['student_id'],
      assessmentId: map['assessment_id'],
      marks: map['marks']?.toDouble(),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
