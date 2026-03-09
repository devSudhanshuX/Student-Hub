import '../models/student_model.dart';

class StudentService {
  static final List<Student> _students = [];

  // Add a new student
  Future<String> addStudent(Student student) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newStudent = Student(
      id: id,
      uid: student.uid,
      name: student.name,
      email: student.email,
      role: student.role,
      createdAt: student.createdAt,
      updatedAt: student.updatedAt,
    );
    _students.add(newStudent);
    return id;
  }

  // Get all students for a user
  Future<List<Student>> getStudentsByUser(String uid) async {
    return _students.where((student) => student.uid == uid).toList();
  }

  // Get a single student by ID
  Future<Student?> getStudentById(String studentId) async {
    return _students.firstWhere((student) => student.id == studentId);
  }

  // Update a student
  Future<void> updateStudent(Student student) async {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
    }
  }

  // Delete a student
  Future<void> deleteStudent(String studentId) async {
    _students.removeWhere((student) => student.id == studentId);
  }

  // Stream of students for a user (simulate with Future for local)
  Stream<List<Student>> getStudentsStream(String uid) {
    return Stream.value(
      _students.where((student) => student.uid == uid).toList(),
    );
  }

  // Get distinct roles (for dropdown)
  Future<List<String>> getAllRoles(String uid) async {
    final roles = <String>{};
    for (var student in _students.where((s) => s.uid == uid)) {
      if (student.role.isNotEmpty) {
        roles.add(student.role);
      }
    }
    return roles.toList();
  }

  // Get default roles
  List<String> getDefaultRoles() {
    return ['Primary', 'Secondary', 'Advanced'];
  }
}
