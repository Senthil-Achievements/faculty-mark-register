import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/faculty.dart';
import '../models/subject.dart';
import '../models/student.dart';
import '../models/assessment.dart';
import '../models/marks.dart';
import 'export_helper_web.dart' if (dart.library.io) 'export_helper_stub.dart';

class BackupHelper {
  /// Export complete database backup as JSON
  static Future<String> exportFullBackup() async {
    try {
      final db = DatabaseHelper.instance;

      // Get all data from database
      final faculty = await db.getFaculty();
      final subjects = await db.getAllSubjects();

      List<Map<String, dynamic>> subjectsWithData = [];

      for (var subject in subjects) {
        final students = await db.getStudentsBySubject(subject.id!);
        final assessments = await db.getAssessmentsBySubject(subject.id!);

        List<Map<String, dynamic>> studentsWithMarks = [];
        for (var student in students) {
          final marksList = await db.getMarksByStudent(student.id!);
          studentsWithMarks.add({
            'student': student.toMap(),
            'marks': marksList.map((m) => m.toMap()).toList(),
          });
        }

        subjectsWithData.add({
          'subject': subject.toMap(),
          'assessments': assessments.map((a) => a.toMap()).toList(),
          'students': studentsWithMarks,
        });
      }

      // Create backup data structure
      final backupData = {
        'version': '1.0',
        'backup_date': DateTime.now().toIso8601String(),
        'faculty': faculty?.toMap(),
        'subjects': subjectsWithData,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'faculty_marks_backup_$timestamp.json';

      return await _saveBackupFile(jsonString, fileName);
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Import/Restore complete database from backup JSON
  static Future<void> importFullBackup(String jsonContent) async {
    try {
      final backupData = jsonDecode(jsonContent) as Map<String, dynamic>;
      final db = DatabaseHelper.instance;

      // Optional: Clear existing data first (uncomment if needed)
      // await _clearDatabase();

      // Restore faculty
      if (backupData['faculty'] != null) {
        final facultyData = backupData['faculty'] as Map<String, dynamic>;
        final faculty = Faculty.fromMap(facultyData);
        try {
          await db.insertFaculty(faculty);
        } catch (e) {
          // Faculty might already exist
          debugPrint('Faculty already exists: $e');
        }
      }

      // Restore subjects, students, assessments, and marks
      final subjects = backupData['subjects'] as List<dynamic>;

      for (var subjectData in subjects) {
        final subjectMap = subjectData['subject'] as Map<String, dynamic>;
        final subject = Subject(name: subjectMap['name']);
        final subjectId = await db.insertSubject(subject);

        // Restore assessments
        final assessments = subjectData['assessments'] as List<dynamic>;
        Map<int, int> assessmentIdMap = {}; // old ID -> new ID

        for (var assessmentMap in assessments) {
          final oldAssessmentId = assessmentMap['id'];
          final assessment = Assessment(
            subjectId: subjectId,
            name: assessmentMap['name'],
            maxMarks: assessmentMap['max_marks'],
          );
          final newAssessmentId = await db.insertAssessment(assessment);
          assessmentIdMap[oldAssessmentId] = newAssessmentId;
        }

        // Restore students and their marks
        final students = subjectData['students'] as List<dynamic>;

        for (var studentData in students) {
          final studentMap = studentData['student'] as Map<String, dynamic>;
          final student = Student(
            subjectId: subjectId,
            name: studentMap['name'],
            rollNo: studentMap['roll_no'],
          );
          final studentId = await db.insertStudent(student);

          // Restore marks
          final marksList = studentData['marks'] as List<dynamic>;
          for (var marksMap in marksList) {
            final oldAssessmentId = marksMap['assessment_id'];
            final newAssessmentId = assessmentIdMap[oldAssessmentId];

            if (newAssessmentId != null) {
              final marks = Marks(
                studentId: studentId,
                assessmentId: newAssessmentId,
                marks: marksMap['marks'],
              );
              await db.insertOrUpdateMarks(marks);
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  static Future<String> _saveBackupFile(String content, String fileName) async {
    if (kIsWeb) {
      return downloadFileWeb(content, fileName, 'json');
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(content);
        return file.path;
      } catch (e) {
        throw Exception('Failed to save backup file: $e');
      }
    }
  }

  static Future<void> _clearDatabase() async {
    // This method can be used to clear all data before restoring
    // Implement if you want to replace all data on restore
  }
}
