import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:xml/xml.dart';
import '../database/database_helper.dart';
import '../models/subject.dart';
import '../models/student.dart';
import '../models/assessment.dart';
import '../models/marks.dart';

class ImportHelper {
  /// Import students and marks from CSV content
  /// Expected CSV format:
  /// Roll No, Student Name, Assessment1 (Max), Assessment2 (Max), ..., Average
  static Future<Map<String, dynamic>> importFromCSV(
    String csvContent,
    Subject subject,
  ) async {
    try {
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(csvContent);

      if (rows.isEmpty || rows.length < 2) {
        throw Exception('CSV file is empty or invalid');
      }

      final headerRow = rows[0];
      final dataRows = rows.sublist(1);

      // Parse assessment names and max marks from header
      List<Map<String, dynamic>> assessmentInfo = [];
      for (int i = 2; i < headerRow.length - 1; i++) {
        // Skip Roll No, Name, and Average
        final headerText = headerRow[i].toString();
        final match = RegExp(r'(.+?)\s*\((\d+\.?\d*)\)').firstMatch(headerText);

        if (match != null) {
          assessmentInfo.add({
            'name': match.group(1)!.trim(),
            'maxMarks': double.parse(match.group(2)!),
          });
        }
      }

      if (assessmentInfo.isEmpty) {
        throw Exception('No valid assessments found in CSV header');
      }

      final db = DatabaseHelper.instance;

      // Create assessments
      List<Assessment> assessments = [];
      for (var info in assessmentInfo) {
        final assessment = Assessment(
          subjectId: subject.id!,
          name: info['name'],
          maxMarks: info['maxMarks'],
        );
        final assessmentId = await db.insertAssessment(assessment);
        assessments.add(assessment.copyWith(id: assessmentId));
      }

      int importedStudents = 0;
      int importedMarks = 0;
      List<String> errors = [];

      // Import students and marks
      for (var row in dataRows) {
        if (row.length < 2) continue; // Skip invalid rows

        try {
          final rollNo = row[0].toString().trim();
          final name = row[1].toString().trim();

          if (rollNo.isEmpty || name.isEmpty) continue;

          // Create student
          final student = Student(
            subjectId: subject.id!,
            name: name,
            rollNo: rollNo,
          );
          final studentId = await db.insertStudent(student);
          importedStudents++;

          // Import marks for each assessment
          for (int i = 0; i < assessments.length; i++) {
            final marksIndex = i + 2; // Skip Roll No and Name columns
            if (marksIndex < row.length) {
              final marksValue = row[marksIndex];
              if (marksValue != null &&
                  marksValue.toString().trim().isNotEmpty) {
                try {
                  final marks = Marks(
                    studentId: studentId,
                    assessmentId: assessments[i].id!,
                    marks: double.parse(marksValue.toString()),
                  );
                  await db.insertOrUpdateMarks(marks);
                  importedMarks++;
                } catch (e) {
                  errors
                      .add('Invalid marks for $name in ${assessments[i].name}');
                }
              }
            }
          }
        } catch (e) {
          errors.add('Error importing row: $e');
        }
      }

      return {
        'success': true,
        'studentsImported': importedStudents,
        'marksImported': importedMarks,
        'assessmentsCreated': assessments.length,
        'errors': errors,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generate a template CSV for teachers to fill
  static String generateImportTemplate() {
    List<List<dynamic>> rows = [];

    // Header row with example assessments
    rows.add([
      'Roll No',
      'Student Name',
      'Assignment 1 (20)',
      'Quiz 1 (10)',
      'Mid Term (50)',
      'Final Exam (100)',
      'Average'
    ]);

    // Example data rows
    rows.add(['001', 'John Doe', '18', '9', '45', '85', '']);
    rows.add(['002', 'Jane Smith', '19', '10', '48', '90', '']);
    rows.add(['003', 'Bob Johnson', '17', '8', '42', '80', '']);

    return const ListToCsvConverter().convert(rows);
  }

  /// Import from Excel file bytes
  static Future<Map<String, dynamic>> importFromExcel(
    Uint8List bytes,
    Subject subject,
  ) async {
    try {
      final excel = Excel.decodeBytes(bytes);

      // Get the first sheet
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet == null || sheet.rows.isEmpty) {
        throw Exception('Excel sheet is empty');
      }

      // Convert Excel rows to List<List<dynamic>>
      List<List<dynamic>> rows = [];
      for (var row in sheet.rows) {
        List<dynamic> rowData = [];
        for (var cell in row) {
          rowData.add(cell?.value?.toString() ?? '');
        }
        rows.add(rowData);
      }

      // Use the same CSV import logic
      final csvContent = const ListToCsvConverter().convert(rows);
      return await importFromCSV(csvContent, subject);
    } catch (e) {
      return {
        'success': false,
        'error': 'Excel import failed: $e',
      };
    }
  }

  /// Import from XML content
  static Future<Map<String, dynamic>> importFromXML(
    String xmlContent,
    Subject subject,
  ) async {
    try {
      final document = XmlDocument.parse(xmlContent);
      final subjectElement = document.findElements('subject').first;

      // Parse assessments
      final assessmentsElements =
          subjectElement.findElements('assessments').first;
      List<Map<String, dynamic>> assessmentInfo = [];

      for (var assessmentElem
          in assessmentsElements.findElements('assessment')) {
        final name = assessmentElem.findElements('name').first.innerText;
        final maxMarks = double.parse(
            assessmentElem.findElements('max_marks').first.innerText);
        assessmentInfo.add({'name': name, 'maxMarks': maxMarks});
      }

      final db = DatabaseHelper.instance;
      List<Assessment> assessments = [];

      for (var info in assessmentInfo) {
        final assessment = Assessment(
          subjectId: subject.id!,
          name: info['name'],
          maxMarks: info['maxMarks'],
        );
        final assessmentId = await db.insertAssessment(assessment);
        assessments.add(assessment.copyWith(id: assessmentId));
      }

      int importedStudents = 0;
      int importedMarks = 0;
      List<String> errors = [];

      // Parse students
      final studentsElements = subjectElement.findElements('students').first;
      for (var studentElem in studentsElements.findElements('student')) {
        try {
          final rollNo = studentElem.findElements('roll_no').first.innerText;
          final name = studentElem.findElements('name').first.innerText;

          final student = Student(
            subjectId: subject.id!,
            name: name,
            rollNo: rollNo,
          );
          final studentId = await db.insertStudent(student);
          importedStudents++;

          // Import marks
          final marksElements = studentElem.findElements('marks').first;
          for (var marksElem
              in marksElements.findElements('assessment_marks')) {
            try {
              final assessmentName =
                  marksElem.findElements('assessment_name').first.innerText;
              final marksText = marksElem.findElements('marks').first.innerText;

              if (marksText.isNotEmpty) {
                final assessment =
                    assessments.firstWhere((a) => a.name == assessmentName);
                final marks = Marks(
                  studentId: studentId,
                  assessmentId: assessment.id!,
                  marks: double.parse(marksText),
                );
                await db.insertOrUpdateMarks(marks);
                importedMarks++;
              }
            } catch (e) {
              errors.add('Error importing marks for $name');
            }
          }
        } catch (e) {
          errors.add('Error importing student: $e');
        }
      }

      return {
        'success': true,
        'studentsImported': importedStudents,
        'marksImported': importedMarks,
        'assessmentsCreated': assessments.length,
        'errors': errors,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'XML import failed: $e',
      };
    }
  }
}

extension on Assessment {
  Assessment copyWith({int? id}) {
    return Assessment(
      id: id ?? this.id,
      subjectId: subjectId,
      name: name,
      maxMarks: maxMarks,
      createdAt: createdAt,
    );
  }
}
