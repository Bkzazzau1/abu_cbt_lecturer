class ExamOfficerCourseRegistration {
  const ExamOfficerCourseRegistration({
    required this.courseCode,
    required this.courseTitle,
    required this.level,
    required this.semester,
    required this.regularCount,
    required this.carryoverCount,
    required this.lecturers,
  });

  final String courseCode;
  final String courseTitle;
  final String level;
  final String semester;
  final int regularCount;
  final int carryoverCount;
  final List<String> lecturers;

  int get totalRegistered => regularCount + carryoverCount;
}

class ExamOfficerLevelStudent {
  const ExamOfficerLevelStudent({
    required this.matricNumber,
    required this.name,
    required this.level,
    required this.registeredCourseCount,
    this.carryoverCourseCodes = const [],
  });

  final String matricNumber;
  final String name;
  final String level;
  final int registeredCourseCount;
  final List<String> carryoverCourseCodes;

  bool get hasCarryover => carryoverCourseCodes.isNotEmpty;
}

class ExamOfficerAcademicRegistry {
  ExamOfficerAcademicRegistry._();

  static final ExamOfficerAcademicRegistry instance =
      ExamOfficerAcademicRegistry._();

  static const levels = ['100 Level', '200 Level', '300 Level', '400 Level'];

  static const Map<String, int> _cohortCounts = {
    '100 Level': 214,
    '200 Level': 198,
    '300 Level': 176,
    '400 Level': 143,
  };

  static const List<ExamOfficerCourseRegistration> _courses = [
    ExamOfficerCourseRegistration(
      courseCode: 'CSC 101',
      courseTitle: 'Introduction to Computer Science',
      level: '100 Level',
      semester: 'Semester 1',
      regularCount: 214,
      carryoverCount: 18,
      lecturers: ['Dr. Hauwa Musa', 'Dr. Ibrahim Sani'],
    ),
    ExamOfficerCourseRegistration(
      courseCode: 'CSC 103',
      courseTitle: 'Programming Fundamentals',
      level: '100 Level',
      semester: 'Semester 1',
      regularCount: 211,
      carryoverCount: 12,
      lecturers: ['Dr. Yusuf Abdullahi'],
    ),
    ExamOfficerCourseRegistration(
      courseCode: 'MTH 101',
      courseTitle: 'Elementary Mathematics',
      level: '100 Level',
      semester: 'Semester 1',
      regularCount: 205,
      carryoverCount: 27,
      lecturers: ['Dr. Zainab Ibrahim'],
    ),
    ExamOfficerCourseRegistration(
      courseCode: 'CSC 201',
      courseTitle: 'Data Structures',
      level: '200 Level',
      semester: 'Semester 1',
      regularCount: 198,
      carryoverCount: 23,
      lecturers: ['Dr. Amina Bello', 'Dr. Yusuf Abdullahi'],
    ),
    ExamOfficerCourseRegistration(
      courseCode: 'CSC 203',
      courseTitle: 'Object-Oriented Programming',
      level: '200 Level',
      semester: 'Semester 1',
      regularCount: 194,
      carryoverCount: 14,
      lecturers: ['Dr. Salisu Garba'],
    ),
    ExamOfficerCourseRegistration(
      courseCode: 'MTH 201',
      courseTitle: 'Discrete Mathematics',
      level: '200 Level',
      semester: 'Semester 1',
      regularCount: 190,
      carryoverCount: 19,
      lecturers: ['Dr. Maryam Lawal'],
    ),
    ExamOfficerCourseRegistration(
      courseCode: 'CSC 305',
      courseTitle: 'Database Systems',
      level: '300 Level',
      semester: 'Semester 1',
      regularCount: 176,
      carryoverCount: 31,
      lecturers: ['Dr. Amina Bello', 'Dr. Grace Adamu'],
    ),
    ExamOfficerCourseRegistration(
      courseCode: 'CSC 307',
      courseTitle: 'Operating Systems',
      level: '300 Level',
      semester: 'Semester 1',
      regularCount: 171,
      carryoverCount: 18,
      lecturers: ['Dr. Usman Kabir'],
    ),
    ExamOfficerCourseRegistration(
      courseCode: 'CSC 411',
      courseTitle: 'Artificial Intelligence',
      level: '400 Level',
      semester: 'Semester 2',
      regularCount: 143,
      carryoverCount: 22,
      lecturers: ['Dr. Amina Bello', 'Dr. Sani Bello'],
    ),
    ExamOfficerCourseRegistration(
      courseCode: 'CSC 413',
      courseTitle: 'Software Engineering',
      level: '400 Level',
      semester: 'Semester 2',
      regularCount: 138,
      carryoverCount: 11,
      lecturers: ['Dr. Fatima Abdullahi'],
    ),
  ];

  static const List<ExamOfficerLevelStudent> _students = [
    ExamOfficerLevelStudent(matricNumber: '2026/C/CSC/0001', name: 'Aisha Muhammad', level: '100 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2026/C/CSC/0002', name: 'Abdullahi Musa', level: '100 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2026/C/CSC/0003', name: 'Maryam Usman', level: '100 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2026/C/CSC/0004', name: 'Samuel John', level: '100 Level', registeredCourseCount: 7),
    ExamOfficerLevelStudent(matricNumber: '2026/C/CSC/0005', name: 'Zainab Bello', level: '100 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2025/C/CSC/0021', name: 'Ibrahim Lawal', level: '200 Level', registeredCourseCount: 9, carryoverCourseCodes: ['CSC 101']),
    ExamOfficerLevelStudent(matricNumber: '2025/C/CSC/0022', name: 'Rukayya Sani', level: '200 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2025/C/CSC/0023', name: 'Daniel Peter', level: '200 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2025/C/CSC/0024', name: 'Fatima Garba', level: '200 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2025/C/CSC/0025', name: 'Yusuf Ahmed', level: '200 Level', registeredCourseCount: 9, carryoverCourseCodes: ['MTH 101']),
    ExamOfficerLevelStudent(matricNumber: '2024/C/CSC/0041', name: 'Hauwa Ibrahim', level: '300 Level', registeredCourseCount: 9, carryoverCourseCodes: ['CSC 201']),
    ExamOfficerLevelStudent(matricNumber: '2024/C/CSC/0042', name: 'Musa Abdullahi', level: '300 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2024/C/CSC/0043', name: 'Grace James', level: '300 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2024/C/CSC/0044', name: 'Sadiq Umar', level: '300 Level', registeredCourseCount: 9, carryoverCourseCodes: ['CSC 203']),
    ExamOfficerLevelStudent(matricNumber: '2024/C/CSC/0045', name: 'Amina Kabir', level: '300 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2023/C/CSC/0061', name: 'Halima Yusuf', level: '400 Level', registeredCourseCount: 9, carryoverCourseCodes: ['CSC 305']),
    ExamOfficerLevelStudent(matricNumber: '2023/C/CSC/0062', name: 'Michael Joseph', level: '400 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2023/C/CSC/0063', name: 'Suleiman Garba', level: '400 Level', registeredCourseCount: 8),
    ExamOfficerLevelStudent(matricNumber: '2023/C/CSC/0064', name: 'Esther Paul', level: '400 Level', registeredCourseCount: 9, carryoverCourseCodes: ['CSC 307']),
    ExamOfficerLevelStudent(matricNumber: '2023/C/CSC/0065', name: 'Muhammad Sani', level: '400 Level', registeredCourseCount: 8),
  ];

  List<ExamOfficerCourseRegistration> get courses => List.unmodifiable(_courses);
  List<ExamOfficerLevelStudent> get students => List.unmodifiable(_students);

  int cohortCount(String level) => _cohortCounts[level] ?? 0;

  int get totalLevelStudents =>
      _cohortCounts.values.fold<int>(0, (sum, value) => sum + value);

  int get totalCourseRegistrations =>
      _courses.fold<int>(0, (sum, item) => sum + item.totalRegistered);

  int get totalCarryoverRegistrations =>
      _courses.fold<int>(0, (sum, item) => sum + item.carryoverCount);

  List<ExamOfficerCourseRegistration> coursesForLevel(String level) =>
      _courses.where((item) => item.level == level).toList(growable: false);

  List<ExamOfficerLevelStudent> studentsForLevel(String level) =>
      _students.where((item) => item.level == level).toList(growable: false);

  ExamOfficerCourseRegistration? registrationFor(String courseCode) {
    final key = _normalise(courseCode);
    for (final course in _courses) {
      if (_normalise(course.courseCode) == key) return course;
    }
    return null;
  }
}

String _normalise(String value) => value.replaceAll(' ', '').toUpperCase();
