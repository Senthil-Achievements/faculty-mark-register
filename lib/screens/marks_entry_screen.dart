import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/subject.dart';
import '../models/student.dart';
import '../models/assessment.dart';
import '../models/marks.dart';

class MarksEntryScreen extends StatefulWidget {
  final Subject subject;
  final List<Student> students;
  final List<Assessment> assessments;

  const MarksEntryScreen({
    super.key,
    required this.subject,
    required this.students,
    required this.assessments,
  });

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  Assessment? _selectedAssessment;
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, double?> _marksData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.assessments.isNotEmpty) {
      _selectedAssessment = widget.assessments.first;
      _loadMarks();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMarks() async {
    if (_selectedAssessment == null) return;

    setState(() => _isLoading = true);

    for (var student in widget.students) {
      final marks = await DatabaseHelper.instance.getMarks(
        student.id!,
        _selectedAssessment!.id!,
      );
      _marksData[student.id!] = marks?.marks;
      _controllers[student.id!] = TextEditingController(
        text: marks?.marks?.toString() ?? '',
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveMarks() async {
    setState(() => _isLoading = true);

    for (var student in widget.students) {
      final controller = _controllers[student.id!];
      if (controller == null) continue;

      double? marksValue;
      if (controller.text.trim().isNotEmpty) {
        marksValue = double.tryParse(controller.text.trim());
        if (marksValue != null && marksValue > _selectedAssessment!.maxMarks) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Marks for ${student.name} exceed maximum marks (${_selectedAssessment!.maxMarks})',
                ),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      final marks = Marks(
        studentId: student.id!,
        assessmentId: _selectedAssessment!.id!,
        marks: marksValue,
      );
      await DatabaseHelper.instance.insertOrUpdateMarks(marks);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marks saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Marks'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveMarks,
            icon: const Icon(Icons.save),
            tooltip: 'Save Marks',
          ),
        ],
      ),
      body: widget.assessments.isEmpty
          ? Center(
              child: Text(
                'No assessments available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : Column(
              children: [
                // Assessment Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Assessment>(
                          isExpanded: true,
                          value: _selectedAssessment,
                          items: widget.assessments.map((assessment) {
                            return DropdownMenuItem(
                              value: assessment,
                              child: Text(
                                '${assessment.name} (Max: ${assessment.maxMarks})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          onChanged: (assessment) {
                            setState(() {
                              _selectedAssessment = assessment;
                              _loadMarks();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Student List with Marks Entry
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: widget.students.length,
                          itemBuilder: (context, index) {
                            final student = widget.students[index];
                            final controller = _controllers[student.id!];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Roll: ${student.rollNo}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          labelText: 'Marks',
                                          hintText: '0',
                                          suffixText:
                                              '/${_selectedAssessment!.maxMarks}',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Save Button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveMarks,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Save Marks'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
