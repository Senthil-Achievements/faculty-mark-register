class Faculty {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? department;
  final String? profilePicture;
  final DateTime createdAt;

  Faculty({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.department,
    this.profilePicture,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Faculty.fromMap(Map<String, dynamic> map) {
    return Faculty(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      department: map['department'],
      profilePicture: map['profile_picture'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
