import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';
import 'add_student_screen.dart';
import 'login_screen.dart';
import 'student_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _studentService = StudentService();

  User? _currentUser;
  bool _isLoading = true;
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      final effectiveUser =
          user ??
          User(
            uid: 'local',
            email: '',
            mobileNumber: '',
            createdAt: DateTime.now(),
          );
      setState(() {
        _currentUser = effectiveUser;
        _isLoading = false;
      });
      _loadStudents();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadStudents() async {
    if (_currentUser == null) return;
    try {
      final students = await _studentService.getStudentsByUser(
        _currentUser!.uid,
      );
      setState(() {
        _students = students;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await _authService.logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _deleteStudent(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await _studentService.deleteStudent(student.id);
        _loadStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.list, color: Colors.white),
            SizedBox(width: 8),
            Text('Student List'),
          ],
        ),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {},
                child: const Text('Profile'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('No user logged in'))
              : Column(
                  children: [

                    // ── Student List Container ────────────────────────────
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Header
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'THE Students List',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // List or empty state
                            Expanded(
                              child: _students.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.school_outlined,
                                            size: 80,
                                            color: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No students added yet',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Tap the button below to add your first student',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ListView.builder(
                                        itemCount: _students.length,
                                        itemBuilder: (context, index) {
                                          final student = _students[index];
                                          return Card(
                                            margin: const EdgeInsets.all(8),
                                            elevation: 2,
                                            child: ListTile(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StudentDetailScreen(
                                                          student: student,
                                                        ),
                                                  ),
                                                );
                                              },
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.green,
                                                child: Text(
                                                  student.name.isNotEmpty
                                                      ? student.name[0].toUpperCase()
                                                      : '?',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                student.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 4),
                                                  Text(student.email),
                                                  const SizedBox(height: 4),
                                                  Chip(
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    label: Text(student.role),
                                                  ),
                                                ],
                                              ),
                                              trailing: PopupMenuButton(
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AddStudentScreen(
                                                                    currentUser:
                                                                        _currentUser!,
                                                                    studentToEdit:
                                                                        student,
                                                                  ),
                                                            ),
                                                          )
                                                          .then((_) =>
                                                              _loadStudents());
                                                    },
                                                    child: const Text('Edit'),
                                                  ),
                                                  PopupMenuItem(
                                                    onTap: () =>
                                                        _deleteStudent(student),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 12),

                            // Add Student Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddStudentScreen(
                                                  currentUser: _currentUser!,
                                                ),
                                          ),
                                        )
                                        .then((_) => _loadStudents());
                                  },
                                  child: const Text('Add Student'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

