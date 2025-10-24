import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/student.dart';
import '../models/subject.dart';
import '../models/assessment.dart';
import '../models/marks.dart';
import '../utils/export_helper.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;
  final Subject subject;

  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.subject,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  List<Marks> _marksList = [];
  List<Assessment> _assessments = [];
  double _average = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final db = DatabaseHelper.instance;
    final marksList = await db.getMarksByStudent(widget.student.id!);
    final average = await db.calculateStudentAverage(widget.student.id!);

    List<Assessment> assessments = [];
    for (var marks in marksList) {
      final assessment = await db.getAssessment(marks.assessmentId);
      if (assessment != null) {
        assessments.add(assessment);
      }
    }

    setState(() {
      _marksList = marksList;
      _assessments = assessments;
      _average = average;
      _isLoading = false;
    });
  }

  Future<void> _exportStudentData() async {
    if (_marksList.isEmpty) {
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
      final filePath = await ExportHelper.exportStudentData(
        widget.student,
        widget.subject,
        _marksList,
        _assessments,
        _average,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportStudentData,
            tooltip: 'Export Student Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                child: Text(
                                  widget.student.name[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.student.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Roll No: ${widget.student.rollNo}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Subject: ${widget.subject.name}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Performance Summary Card
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(
                            'Assessments',
                            _marksList.length.toString(),
                            Icons.assignment,
                          ),
                          _buildStat(
                            'Completed',
                            _marksList
                                .where((m) => m.marks != null)
                                .length
                                .toString(),
                            Icons.check_circle,
                          ),
                          _buildStat(
                            'Average',
                            _average.toStringAsFixed(1),
                            Icons.analytics,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Marks Breakdown
                  Text(
                    'Marks Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  if (_marksList.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.assignment_outlined,
                                  size: 60, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No marks recorded yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _marksList.length,
                      itemBuilder: (context, index) {
                        final marks = _marksList[index];
                        final assessment = _assessments.firstWhere(
                          (a) => a.id == marks.assessmentId,
                        );

                        final percentage = marks.marks != null
                            ? (marks.marks! / assessment.maxMarks) * 100
                            : null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        assessment.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      marks.marks != null
                                          ? '${marks.marks!.toStringAsFixed(1)} / ${assessment.maxMarks}'
                                          : 'Not Marked',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: marks.marks != null
                                            ? (percentage! >= 60
                                                ? Colors.green
                                                : percentage >= 40
                                                    ? Colors.orange
                                                    : Colors.red)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                if (percentage != null) ...[
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey[300],
                                    color: percentage >= 60
                                        ? Colors.green
                                        : percentage >= 40
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
