import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../database/database_helper.dart';
import '../models/subject.dart';
import '../models/student.dart';
import '../models/assessment.dart';
import '../utils/export_helper.dart';
import '../utils/import_helper.dart';
import '../utils/export_helper_web.dart'
    if (dart.library.io) '../utils/export_helper_stub.dart';
import 'student_list_screen.dart';
import 'marks_entry_screen.dart';
import 'student_detail_screen.dart';

class SubjectScreen extends StatefulWidget {
  final Subject subject;

  const SubjectScreen({super.key, required this.subject});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  List<Student> _students = [];
  List<Assessment> _assessments = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper.instance;
    final students = await db.getStudentsBySubject(widget.subject.id!);
    final assessments = await db.getAssessmentsBySubject(widget.subject.id!);
    setState(() {
      _students = students;
      _filteredStudents = students;
      _assessments = assessments;
      _isLoading = false;
    });
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students.where((student) {
          return student.name.toLowerCase().contains(query.toLowerCase()) ||
              student.rollNo.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _manageStudents() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentListScreen(subject: widget.subject),
      ),
    );
    _loadData();
  }

  Future<void> _manageAssessments() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentManagementScreen(subject: widget.subject),
      ),
    );
    _loadData();
  }

  Future<void> _enterMarks() async {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add students first')),
      );
      return;
    }
    if (_assessments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add assessments first')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarksEntryScreen(
          subject: widget.subject,
          students: _students,
          assessments: _assessments,
        ),
      ),
    );
    _loadData();
  }

  Future<void> _exportSubjectData() async {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Format'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'csv'),
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'xml'),
            child: const Text('XML'),
          ),
        ],
      ),
    );

    if (format == null) return;

    try {
      final filePath = await ExportHelper.exportSubjectData(
        widget.subject,
        _students,
        _assessments,
        format,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to: $filePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      final csvTemplate = ImportHelper.generateImportTemplate();

      // Create a simple export using the export helper
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'import_template_$timestamp.csv';

      // Save the template
      if (kIsWeb) {
        downloadFileWeb(csvTemplate, fileName, 'csv');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(csvTemplate);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Template downloaded! Fill it with your student data.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _importFromCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      String? csvContent;

      if (file.bytes != null) {
        csvContent = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        csvContent = await File(file.path!).readAsString();
      }

      if (csvContent == null) {
        throw Exception('Could not read file');
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      final importResult =
          await ImportHelper.importFromCSV(csvContent, widget.subject);

      if (mounted) {
        Navigator.pop(context); // Close loading

        if (importResult['success'] == true) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Successful'),
              content: Text(
                'Imported:\n'
                '• ${importResult['studentsImported']} students\n'
                '• ${importResult['assessmentsCreated']} assessments\n'
                '• ${importResult['marksImported']} marks\n'
                '${importResult['errors'].isNotEmpty ? "\nWarnings: ${importResult['errors'].length}" : ""}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: ${importResult['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _exportSubjectData();
              } else if (value == 'import') {
                _importFromCSV();
              } else if (value == 'template') {
                _downloadTemplate();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'template',
                child: ListTile(
                  leading: Icon(Icons.file_download),
                  title: Text('Download Template'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.upload_file),
                  title: Text('Import from CSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Data'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Students',
                          _students.length.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Assessments',
                          _assessments.length.toString(),
                          Icons.assignment,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _manageStudents,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Manage Students'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _manageAssessments,
                          icon: const Icon(Icons.playlist_add),
                          label: const Text('Assessments'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _enterMarks,
                    icon: const Icon(Icons.edit),
                    label: const Text('Enter Marks'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Search Bar
                if (_students.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterStudents('');
                                },
                              )
                            : null,
                      ),
                      onChanged: _filterStudents,
                    ),
                  ),

                const SizedBox(height: 16),

                // Student List
                Expanded(
                  child: _students.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No students added yet',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Manage Students" to add students',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : _filteredStudents.isEmpty
                          ? Center(
                              child: Text(
                                'No students found',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = _filteredStudents[index];
                                return FutureBuilder<double>(
                                  future: DatabaseHelper.instance
                                      .calculateStudentAverage(student.id!),
                                  builder: (context, snapshot) {
                                    final average = snapshot.data ?? 0.0;
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          child: Text(
                                              student.name[0].toUpperCase()),
                                        ),
                                        title: Text(
                                          student.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle:
                                            Text('Roll No: ${student.rollNo}'),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Average',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              average.toStringAsFixed(1),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: average >= 60
                                                    ? Colors.green
                                                    : average >= 40
                                                        ? Colors.orange
                                                        : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  StudentDetailScreen(
                                                student: student,
                                                subject: widget.subject,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Assessment Management Screen
class AssessmentManagementScreen extends StatefulWidget {
  final Subject subject;

  const AssessmentManagementScreen({super.key, required this.subject});

  @override
  State<AssessmentManagementScreen> createState() =>
      _AssessmentManagementScreenState();
}

class _AssessmentManagementScreenState
    extends State<AssessmentManagementScreen> {
  List<Assessment> _assessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    setState(() => _isLoading = true);
    final assessments = await DatabaseHelper.instance
        .getAssessmentsBySubject(widget.subject.id!);
    setState(() {
      _assessments = assessments;
      _isLoading = false;
    });
  }

  Future<void> _addAssessment() async {
    final nameController = TextEditingController();
    final marksController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Assessment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Assessment Name',
                hintText: 'e.g., Assignment 1',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: marksController,
              decoration: const InputDecoration(
                labelText: 'Maximum Marks',
                hintText: 'e.g., 100',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  marksController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final maxMarks = double.tryParse(marksController.text);
              if (maxMarks == null || maxMarks <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid marks')),
                );
                return;
              }

              final assessment = Assessment(
                subjectId: widget.subject.id!,
                name: nameController.text.trim(),
                maxMarks: maxMarks,
              );
              await DatabaseHelper.instance.insertAssessment(assessment);
              if (context.mounted) Navigator.pop(context, true);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) _loadAssessments();
  }

  Future<void> _deleteAssessment(Assessment assessment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assessment'),
        content: Text(
            'Delete "${assessment.name}"? All marks for this assessment will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteAssessment(assessment.id!);
      _loadAssessments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Assessments'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assessments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No assessments added yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add assessments',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _assessments.length,
                  itemBuilder: (context, index) {
                    final assessment = _assessments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.assignment),
                        ),
                        title: Text(
                          assessment.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Max Marks: ${assessment.maxMarks}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _deleteAssessment(assessment),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAssessment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
