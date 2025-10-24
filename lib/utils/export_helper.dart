import 'dart:io';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/subject.dart';
import '../models/student.dart';
import '../models/assessment.dart';
import '../models/marks.dart';
import '../database/database_helper.dart';
import 'export_helper_web.dart' if (dart.library.io) 'export_helper_stub.dart';

class ExportHelper {
  static Future<String> exportSubjectData(
    Subject subject,
    List<Student> students,
    List<Assessment> assessments,
    String format,
  ) async {
    if (format == 'csv') {
      return await _exportSubjectToCSV(subject, students, assessments);
    } else {
      return await _exportSubjectToXML(subject, students, assessments);
    }
  }

  static Future<String> exportStudentData(
    Student student,
    Subject subject,
    List<Marks> marksList,
    List<Assessment> assessments,
    double average,
    String format,
  ) async {
    if (format == 'csv') {
      return await _exportStudentToCSV(
          student, subject, marksList, assessments, average);
    } else {
      return await _exportStudentToXML(
          student, subject, marksList, assessments, average);
    }
  }

  static Future<String> _exportSubjectToCSV(
    Subject subject,
    List<Student> students,
    List<Assessment> assessments,
  ) async {
    List<List<dynamic>> rows = [];

    // Header row
    List<dynamic> header = ['Roll No', 'Student Name'];
    for (var assessment in assessments) {
      header.add('${assessment.name} (${assessment.maxMarks})');
    }
    header.add('Average');
    rows.add(header);

    // Data rows
    for (var student in students) {
      List<dynamic> row = [student.rollNo, student.name];

      double totalMarks = 0;
      int count = 0;

      for (var assessment in assessments) {
        final marks =
            await DatabaseHelper.instance.getMarks(student.id!, assessment.id!);
        if (marks?.marks != null) {
          row.add(marks!.marks);
          totalMarks += marks.marks!;
          count++;
        } else {
          row.add('');
        }
      }

      final average = count > 0 ? totalMarks / count : 0;
      row.add(average.toStringAsFixed(2));
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    return await _saveFile(csv, '${subject.name}_marks', 'csv');
  }

  static Future<String> _exportSubjectToXML(
    Subject subject,
    List<Student> students,
    List<Assessment> assessments,
  ) async {
    StringBuffer xml = StringBuffer();
    xml.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    xml.writeln('<subject>');
    xml.writeln('  <name>${_escapeXml(subject.name)}</name>');
    xml.writeln(
        '  <export_date>${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}</export_date>');
    xml.writeln('  <assessments>');

    for (var assessment in assessments) {
      xml.writeln('    <assessment>');
      xml.writeln('      <name>${_escapeXml(assessment.name)}</name>');
      xml.writeln('      <max_marks>${assessment.maxMarks}</max_marks>');
      xml.writeln('    </assessment>');
    }

    xml.writeln('  </assessments>');
    xml.writeln('  <students>');

    for (var student in students) {
      xml.writeln('    <student>');
      xml.writeln('      <roll_no>${_escapeXml(student.rollNo)}</roll_no>');
      xml.writeln('      <name>${_escapeXml(student.name)}</name>');
      xml.writeln('      <marks>');

      double totalMarks = 0;
      int count = 0;

      for (var assessment in assessments) {
        final marks =
            await DatabaseHelper.instance.getMarks(student.id!, assessment.id!);
        xml.writeln('        <assessment_marks>');
        xml.writeln(
            '          <assessment_name>${_escapeXml(assessment.name)}</assessment_name>');
        xml.writeln('          <marks>${marks?.marks ?? ''}</marks>');
        xml.writeln('        </assessment_marks>');

        if (marks?.marks != null) {
          totalMarks += marks!.marks!;
          count++;
        }
      }

      final average = count > 0 ? totalMarks / count : 0;
      xml.writeln('      </marks>');
      xml.writeln('      <average>${average.toStringAsFixed(2)}</average>');
      xml.writeln('    </student>');
    }

    xml.writeln('  </students>');
    xml.writeln('</subject>');

    return await _saveFile(xml.toString(), '${subject.name}_marks', 'xml');
  }

  static Future<String> _exportStudentToCSV(
    Student student,
    Subject subject,
    List<Marks> marksList,
    List<Assessment> assessments,
    double average,
  ) async {
    List<List<dynamic>> rows = [];

    // Student Info
    rows.add(['Student Information']);
    rows.add(['Name', student.name]);
    rows.add(['Roll No', student.rollNo]);
    rows.add(['Subject', subject.name]);
    rows.add([
      'Export Date',
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
    ]);
    rows.add([]);

    // Marks
    rows.add(['Assessment', 'Marks Obtained', 'Maximum Marks', 'Percentage']);
    for (var marks in marksList) {
      final assessment =
          assessments.firstWhere((a) => a.id == marks.assessmentId);
      final percentage = marks.marks != null
          ? (marks.marks! / assessment.maxMarks) * 100
          : null;

      rows.add([
        assessment.name,
        marks.marks?.toStringAsFixed(2) ?? 'Not Marked',
        assessment.maxMarks,
        percentage != null ? '${percentage.toStringAsFixed(2)}%' : '-',
      ]);
    }

    rows.add([]);
    rows.add(['Average Marks', average.toStringAsFixed(2)]);

    String csv = const ListToCsvConverter().convert(rows);
    return await _saveFile(csv, '${student.name}_${student.rollNo}', 'csv');
  }

  static Future<String> _exportStudentToXML(
    Student student,
    Subject subject,
    List<Marks> marksList,
    List<Assessment> assessments,
    double average,
  ) async {
    StringBuffer xml = StringBuffer();
    xml.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    xml.writeln('<student_report>');
    xml.writeln('  <student>');
    xml.writeln('    <name>${_escapeXml(student.name)}</name>');
    xml.writeln('    <roll_no>${_escapeXml(student.rollNo)}</roll_no>');
    xml.writeln('  </student>');
    xml.writeln('  <subject>${_escapeXml(subject.name)}</subject>');
    xml.writeln(
        '  <export_date>${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}</export_date>');
    xml.writeln('  <assessments>');

    for (var marks in marksList) {
      final assessment =
          assessments.firstWhere((a) => a.id == marks.assessmentId);
      final percentage = marks.marks != null
          ? (marks.marks! / assessment.maxMarks) * 100
          : null;

      xml.writeln('    <assessment>');
      xml.writeln('      <name>${_escapeXml(assessment.name)}</name>');
      xml.writeln(
          '      <marks_obtained>${marks.marks ?? ''}</marks_obtained>');
      xml.writeln('      <max_marks>${assessment.maxMarks}</max_marks>');
      xml.writeln(
          '      <percentage>${percentage?.toStringAsFixed(2) ?? ''}</percentage>');
      xml.writeln('    </assessment>');
    }

    xml.writeln('  </assessments>');
    xml.writeln('  <average>${average.toStringAsFixed(2)}</average>');
    xml.writeln('</student_report>');

    return await _saveFile(
        xml.toString(), '${student.name}_${student.rollNo}', 'xml');
  }

  static Future<String> _saveFile(
      String content, String fileName, String extension) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedFileName =
        fileName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final fullFileName = '${sanitizedFileName}_$timestamp.$extension';

    if (kIsWeb) {
      // Web: Download the file
      return downloadFileWeb(content, fullFileName, extension);
    } else {
      // Mobile/Desktop: Save to file system
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fullFileName');
        await file.writeAsString(content);
        return file.path;
      } catch (e) {
        throw Exception('Failed to save file: $e');
      }
    }
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
