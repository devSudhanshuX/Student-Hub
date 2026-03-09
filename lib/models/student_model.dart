class Student {
  final String id;
  final String uid; // User who created this student
  final String name;
  final String email;
  final String role; // e.g., "Primary", "Secondary", "Advanced"
  final DateTime createdAt;
  final DateTime? updatedAt;

  Student({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      id: id,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
                DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
                ? map['updatedAt']
                : DateTime.tryParse(map['updatedAt'].toString()))
          : null,
    );
  }

  Student copyWith({
    String? id,
    String? uid,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
