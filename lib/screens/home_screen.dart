import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/faculty.dart';
import '../models/subject.dart';
import '../utils/backup_helper.dart';
import 'subject_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Faculty? _faculty;
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper.instance;
    final faculty = await db.getFaculty();
    final subjects = await db.getAllSubjects();
    setState(() {
      _faculty = faculty;
      _subjects = subjects;
      _isLoading = false;
    });
  }

  Future<void> _addSubject() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subject Name',
            hintText: 'e.g., Mathematics',
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a subject name')),
                );
                return;
              }
              final subject = Subject(name: controller.text.trim());
              await DatabaseHelper.instance.insertSubject(subject);
              if (context.mounted) Navigator.pop(context, true);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) _loadData();
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Are you sure you want to delete "${subject.name}"?\n\nThis will also delete all students, assessments, and marks related to this subject.',
        ),
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
      await DatabaseHelper.instance.deleteSubject(subject.id!);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${subject.name} deleted')),
        );
      }
    }
  }

  Future<void> _backupDatabase() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final filePath = await BackupHelper.exportFullBackup();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully!\n$filePath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      String? jsonContent;

      if (file.bytes != null) {
        // Web platform
        jsonContent = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        // Mobile/Desktop platform
        final fileData = await File(file.path!).readAsString();
        jsonContent = fileData;
      }

      if (jsonContent == null) {
        throw Exception('Could not read file');
      }

      // Confirm restore
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Backup'),
          content: const Text(
            'This will add all data from the backup file to your current database.\n\n'
            'Your existing data will NOT be deleted.\n\n'
            'Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      await BackupHelper.importFullBackup(jsonContent);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Reload data
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Faculty Marks Manager'),
            if (_faculty != null)
              Text(
                _faculty!.name,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'backup') {
                _backupDatabase();
              } else if (value == 'restore') {
                _restoreDatabase();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'backup',
                child: ListTile(
                  leading: Icon(Icons.backup),
                  title: Text('Backup All Data'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'restore',
                child: ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('Restore from Backup'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _subjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book_outlined,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No subjects yet',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your first subject',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _subjects.length,
                          itemBuilder: (context, index) {
                            final subject = _subjects[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(subject.name[0].toUpperCase()),
                                ),
                                title: Text(
                                  subject.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _deleteSubject(subject),
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SubjectScreen(subject: subject),
                                    ),
                                  );
                                  _loadData();
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
          // Footer credit
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              'Built by Senthil',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSubject,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }
}
