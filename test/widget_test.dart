// This is a basic Flutter widget test for Faculty Marks App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:faculty_marks_app/main.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Faculty Marks App initializes correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FacultyMarksApp());

    // Wait for initialization
    await tester.pump();

    // Give extra time for database operations
    await tester.pump(const Duration(seconds: 1));

    // Verify that the app shows a scaffold
    expect(
      find.byType(Scaffold),
      findsAtLeastNWidgets(1),
      reason: 'App should display at least one screen',
    );
  });
}
