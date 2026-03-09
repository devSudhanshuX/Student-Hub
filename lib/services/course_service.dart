import '../models/course_model.dart';

class CourseService {
  final List<Course> _courses = [
    Course(id: 'c1', name: 'M.Tech Information', description: 'Master of Technology postgraduate engineering program focused on advanced technical and engineering skills.'),
    Course(id: 'c2', name: 'BCA Information', description: 'Bachelor of Computer Applications program focused on programming, software development, and computer fundamentals.'),
    Course(id: 'c3', name: 'B.Tech Information', description: 'Bachelor of Technology engineering program covering various engineering and technical subjects.'),
    Course(id: 'c4', name: 'Polytechnic Information', description: 'Diploma level technical education program focused on practical engineering and technical skills.'),
    Course(id: 'c5', name: 'Data Science Information', description: 'Course focused on data analysis, machine learning, statistics, and data processing.'),
  ];

  Future<List<Course>> getCourses() async {
    // In a real app, you would fetch this from a database or API
    await Future.delayed(const Duration(milliseconds: 500));
    return _courses;
  }
}
