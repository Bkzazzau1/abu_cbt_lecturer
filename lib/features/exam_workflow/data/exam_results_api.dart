import 'dart:convert';

/// Everything in this file runs locally — no backend is required to demo the
/// exam officer's result-collection screen. Result batches, per-student
/// scores, and marking scripts are all in-memory demo data. When a real
/// backend is ready, this is the file to swap back to `ApiClient` calls
/// against a documented `/api/results` contract.
class ExamResultsApi {
  ExamResultsApi();

  static final List<ExamResultBatch> _demoBatches = [
    ExamResultBatch(
      courseCode: 'CSC101',
      courseTitle: 'Introduction to Computer Science',
      department: 'Computing',
      level: '100',
      lecturer: 'Dr. A. Musa',
      stage: 'Ready for Release',
      issue:
          'Records reconciliation completed. Ready for exam officer release.',
      students: const [
        ExamResultStudent(
          matricNo: '2023/CSC/101',
          name: 'Aisha Yusuf',
          caScore: 27,
          examScore: 58,
        ),
        ExamResultStudent(
          matricNo: '2023/CSC/102',
          name: 'Bello Umar',
          caScore: 22,
          examScore: 49,
        ),
        ExamResultStudent(
          matricNo: '2023/CSC/103',
          name: 'Chidinma Okoro',
          caScore: 29,
          examScore: 61,
        ),
        ExamResultStudent(
          matricNo: '2023/CSC/104',
          name: 'Danladi Peter',
          caScore: 18,
          examScore: 33,
        ),
        ExamResultStudent(
          matricNo: '2023/CSC/105',
          name: 'Efe Williams',
          caScore: 25,
          examScore: 52,
        ),
        ExamResultStudent(
          matricNo: '2023/CSC/106',
          name: 'Fatima Garba',
          caScore: 28,
          examScore: 64,
        ),
      ],
    ),
    ExamResultBatch(
      courseCode: 'CSC201',
      courseTitle: 'Data and Web Programming',
      department: 'Computing',
      level: '200',
      lecturer: 'Dr. L. Ibrahim',
      stage: 'Moderator Query',
      issue: 'Two CA scores missing. Moderator queried grading consistency.',
      students: const [
        ExamResultStudent(
          matricNo: '2022/CSC/201',
          name: 'Grace Nnamdi',
          caScore: 24,
          examScore: 55,
        ),
        ExamResultStudent(
          matricNo: '2022/CSC/202',
          name: 'Hassan Bappa',
          caScore: 0,
          examScore: 0,
        ),
        ExamResultStudent(
          matricNo: '2022/CSC/203',
          name: 'Ijeoma Eze',
          caScore: 26,
          examScore: 47,
        ),
        ExamResultStudent(
          matricNo: '2022/CSC/204',
          name: 'Jamilu Sani',
          caScore: 0,
          examScore: 0,
        ),
        ExamResultStudent(
          matricNo: '2022/CSC/205',
          name: 'Kemi Adebayo',
          caScore: 21,
          examScore: 44,
        ),
      ],
    ),
    ExamResultBatch(
      courseCode: 'CSC305',
      courseTitle: 'Data Structures',
      department: 'Computing',
      level: '300',
      lecturer: 'Dr. A. Musa',
      stage: 'HoD Review',
      issue:
          'Lecturer submitted marks. HoD review pending before exam office release.',
      students: const [
        ExamResultStudent(
          matricNo: '2021/CSC/301',
          name: 'Lawal Idris',
          caScore: 27,
          examScore: 59,
        ),
        ExamResultStudent(
          matricNo: '2021/CSC/302',
          name: 'Maryam Hassan',
          caScore: 29,
          examScore: 63,
        ),
        ExamResultStudent(
          matricNo: '2021/CSC/303',
          name: 'Nnaemeka Obi',
          caScore: 20,
          examScore: 38,
        ),
        ExamResultStudent(
          matricNo: '2021/CSC/304',
          name: 'Omolara Ade',
          caScore: 25,
          examScore: 51,
        ),
        ExamResultStudent(
          matricNo: '2021/CSC/305',
          name: 'Peter Audu',
          caScore: 23,
          examScore: 46,
        ),
        ExamResultStudent(
          matricNo: '2021/CSC/306',
          name: 'Queen Etim',
          caScore: 28,
          examScore: 60,
        ),
      ],
    ),
    ExamResultBatch(
      courseCode: 'CSC401',
      courseTitle: 'Distributed Systems',
      department: 'Computing',
      level: '400',
      lecturer: 'Dr. A. Musa',
      stage: 'Records Reconcile',
      issue: 'One student has carryover status requiring records confirmation.',
      students: const [
        ExamResultStudent(
          matricNo: '2020/CSC/401',
          name: 'Ruth Danjuma',
          caScore: 27,
          examScore: 55,
        ),
        ExamResultStudent(
          matricNo: '2020/CSC/402',
          name: 'Sadiq Aliyu',
          caScore: 15,
          examScore: 20,
        ),
        ExamResultStudent(
          matricNo: '2020/CSC/403',
          name: 'Tolu Fashola',
          caScore: 26,
          examScore: 57,
        ),
        ExamResultStudent(
          matricNo: '2020/CSC/404',
          name: 'Uche Nwosu',
          caScore: 24,
          examScore: 49,
        ),
      ],
    ),
    ExamResultBatch(
      courseCode: 'MTH301',
      courseTitle: 'Numerical Methods',
      department: 'Mathematics',
      level: '300',
      lecturer: 'Prof. S. Bala',
      stage: 'Records Reconcile',
      issue:
          'Seven students have carryover/repeat status requiring records confirmation.',
      students: const [
        ExamResultStudent(
          matricNo: '2021/MTH/301',
          name: 'Victor Osei',
          caScore: 18,
          examScore: 25,
        ),
        ExamResultStudent(
          matricNo: '2021/MTH/302',
          name: 'Wuraola Bakare',
          caScore: 27,
          examScore: 58,
        ),
        ExamResultStudent(
          matricNo: '2021/MTH/303',
          name: 'Yakubu Musa',
          caScore: 19,
          examScore: 21,
        ),
        ExamResultStudent(
          matricNo: '2021/MTH/304',
          name: 'Zainab Lawal',
          caScore: 28,
          examScore: 62,
        ),
      ],
    ),
    ExamResultBatch(
      courseCode: 'GST303',
      courseTitle: 'Communication in English',
      department: 'General Studies',
      level: '300',
      lecturer: 'Mrs. H. John',
      stage: 'Ready for Release',
      issue:
          'Records reconciliation completed. Ready for exam officer release.',
      students: const [
        ExamResultStudent(
          matricNo: '2021/GST/301',
          name: 'Abdulkadir Musa',
          caScore: 26,
          examScore: 60,
        ),
        ExamResultStudent(
          matricNo: '2021/GST/302',
          name: 'Blessing Okon',
          caScore: 29,
          examScore: 65,
        ),
        ExamResultStudent(
          matricNo: '2021/GST/303',
          name: 'Chukwuemeka Nnaji',
          caScore: 24,
          examScore: 53,
        ),
      ],
    ),
  ];

  Future<List<ExamResultBatch>> fetchBatches() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_demoBatches);
  }

  /// CSV of every student's score for a single course batch.
  List<int> studentListCsvBytes(ExamResultBatch batch) {
    final buffer = StringBuffer()
      ..writeln('Matric No,Name,CA Score,Exam Score,Total,Grade');
    for (final student in batch.students) {
      buffer.writeln(
        '${student.matricNo},${student.name},${student.caScore},'
        '${student.examScore},${student.total},${student.grade}',
      );
    }
    return utf8.encode(buffer.toString());
  }

  /// CSV combining every course batch in [department] at [level] — the
  /// "complete level results" the exam officer can pull department-wide.
  List<int> levelResultsCsvBytes({
    required String department,
    required String level,
    required List<ExamResultBatch> batches,
  }) {
    final buffer = StringBuffer()
      ..writeln(
        'Course Code,Course Title,Matric No,Name,CA Score,Exam Score,Total,Grade',
      );
    for (final batch in batches.where(
      (item) => item.department == department && item.level == level,
    )) {
      for (final student in batch.students) {
        buffer.writeln(
          '${batch.courseCode},${batch.courseTitle},${student.matricNo},'
          '${student.name},${student.caScore},${student.examScore},'
          '${student.total},${student.grade}',
        );
      }
    }
    return utf8.encode(buffer.toString());
  }

  /// A single student's marked exam script — a plain-text placeholder in
  /// this demo build, standing in for the scanned/annotated script that
  /// would come from the Marking & Grading workspace once a backend and
  /// document store are wired in.
  List<int> markingScriptBytes(
    ExamResultBatch batch,
    ExamResultStudent student,
  ) {
    final buffer = StringBuffer()
      ..writeln('AHMADU BELLO UNIVERSITY, ZARIA')
      ..writeln('Marking script — ${batch.courseCode} ${batch.courseTitle}')
      ..writeln()
      ..writeln('Student: ${student.name}')
      ..writeln('Matric No: ${student.matricNo}')
      ..writeln('CA Score: ${student.caScore}')
      ..writeln('Exam Score: ${student.examScore}')
      ..writeln('Total: ${student.total} (${student.grade})')
      ..writeln()
      ..writeln(
        'This is a demo marking script placeholder — the real script image '
        'or PDF will be attached once lecturer marking is connected to a '
        'document store.',
      );
    return utf8.encode(buffer.toString());
  }

  void close() {}
}

class ExamResultStudent {
  const ExamResultStudent({
    required this.matricNo,
    required this.name,
    required this.caScore,
    required this.examScore,
  });

  final String matricNo;
  final String name;
  final int caScore;
  final int examScore;

  int get total => caScore + examScore;

  String get grade {
    if (caScore == 0 && examScore == 0) return '-';
    if (total >= 70) return 'A';
    if (total >= 60) return 'B';
    if (total >= 50) return 'C';
    if (total >= 45) return 'D';
    if (total >= 40) return 'E';
    return 'F';
  }
}

class ExamResultBatch {
  const ExamResultBatch({
    required this.courseCode,
    required this.courseTitle,
    required this.department,
    required this.level,
    required this.lecturer,
    required this.stage,
    required this.issue,
    required this.students,
  });

  final String courseCode;
  final String courseTitle;
  final String department;
  final String level;
  final String lecturer;
  final String stage;
  final String issue;
  final List<ExamResultStudent> students;

  int get missingScores =>
      students.where((s) => s.caScore == 0 && s.examScore == 0).length;

  String get passRateLabel {
    if (students.isEmpty) return '0%';
    final passed = students.where((s) => s.total >= 40).length;
    return '${((passed / students.length) * 100).round()}%';
  }
}
