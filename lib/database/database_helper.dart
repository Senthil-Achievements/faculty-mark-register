import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../models/faculty.dart';
import '../models/subject.dart';
import '../models/student.dart';
import '../models/assessment.dart';
import '../models/marks.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('faculty_marks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // Web platform
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop platforms
      databaseFactory = databaseFactoryFfi;
      final dbPath = await databaseFactory.getDatabasesPath();
      final path = join(dbPath, filePath);

      return await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    } else {
      // Mobile platforms (Android/iOS)
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE faculty (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        department TEXT,
        profile_picture TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        roll_no TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE assessments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        max_marks REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE marks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        assessment_id INTEGER NOT NULL,
        marks REAL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (assessment_id) REFERENCES assessments (id) ON DELETE CASCADE,
        UNIQUE(student_id, assessment_id)
      )
    ''');
  }

  // Faculty operations
  Future<Faculty?> getFaculty() async {
    final db = await database;
    final maps = await db.query('faculty', limit: 1);
    if (maps.isEmpty) return null;
    return Faculty.fromMap(maps.first);
  }

  Future<int> insertFaculty(Faculty faculty) async {
    final db = await database;
    return await db.insert('faculty', faculty.toMap());
  }

  Future<int> updateFaculty(Faculty faculty) async {
    final db = await database;
    return await db.update(
      'faculty',
      faculty.toMap(),
      where: 'id = ?',
      whereArgs: [faculty.id],
    );
  }

  // Subject operations
  Future<List<Subject>> getAllSubjects() async {
    final db = await database;
    final maps = await db.query('subjects', orderBy: 'created_at DESC');
    return maps.map((map) => Subject.fromMap(map)).toList();
  }

  Future<Subject?> getSubject(int id) async {
    final db = await database;
    final maps = await db.query('subjects', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Subject.fromMap(maps.first);
  }

  Future<int> insertSubject(Subject subject) async {
    final db = await database;
    return await db.insert('subjects', subject.toMap());
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await database;
    return await db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // Student operations
  Future<List<Student>> getStudentsBySubject(int subjectId) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'roll_no ASC',
    );
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<Student?> getStudent(int id) async {
    final db = await database;
    final maps = await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Student.fromMap(maps.first);
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // Assessment operations
  Future<List<Assessment>> getAssessmentsBySubject(int subjectId) async {
    final db = await database;
    final maps = await db.query(
      'assessments',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => Assessment.fromMap(map)).toList();
  }

  Future<Assessment?> getAssessment(int id) async {
    final db = await database;
    final maps =
        await db.query('assessments', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Assessment.fromMap(maps.first);
  }

  Future<int> insertAssessment(Assessment assessment) async {
    final db = await database;
    return await db.insert('assessments', assessment.toMap());
  }

  Future<int> updateAssessment(Assessment assessment) async {
    final db = await database;
    return await db.update(
      'assessments',
      assessment.toMap(),
      where: 'id = ?',
      whereArgs: [assessment.id],
    );
  }

  Future<int> deleteAssessment(int id) async {
    final db = await database;
    return await db.delete('assessments', where: 'id = ?', whereArgs: [id]);
  }

  // Marks operations
  Future<Marks?> getMarks(int studentId, int assessmentId) async {
    final db = await database;
    final maps = await db.query(
      'marks',
      where: 'student_id = ? AND assessment_id = ?',
      whereArgs: [studentId, assessmentId],
    );
    if (maps.isEmpty) return null;
    return Marks.fromMap(maps.first);
  }

  Future<List<Marks>> getMarksByStudent(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'marks',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => Marks.fromMap(map)).toList();
  }

  Future<int> insertOrUpdateMarks(Marks marks) async {
    final db = await database;
    return await db.insert(
      'marks',
      marks.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double> calculateStudentAverage(int studentId) async {
    final marksList = await getMarksByStudent(studentId);
    if (marksList.isEmpty) return 0.0;

    final validMarks = marksList.where((m) => m.marks != null).toList();
    if (validMarks.isEmpty) return 0.0;

    final total =
        validMarks.fold<double>(0.0, (sum, m) => sum + (m.marks ?? 0.0));
    return total / validMarks.length;
  }

  Future<Map<String, dynamic>> getStudentCompleteData(int studentId) async {
    final student = await getStudent(studentId);
    if (student == null) return {};

    final marksList = await getMarksByStudent(studentId);
    final assessmentIds = marksList.map((m) => m.assessmentId).toList();

    List<Assessment> assessments = [];
    for (final id in assessmentIds) {
      final assessment = await getAssessment(id);
      if (assessment != null) assessments.add(assessment);
    }

    final average = await calculateStudentAverage(studentId);

    return {
      'student': student,
      'marks': marksList,
      'assessments': assessments,
      'average': average,
    };
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
