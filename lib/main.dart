import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' show Platform;
import 'screens/setup_screen.dart';
import 'screens/home_screen.dart';
import 'database/database_helper.dart';
import 'utils/neon_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for different platforms
  if (kIsWeb) {
    // Web platform
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Mobile platforms (Android/iOS) use the default sqflite

  // Initialize database
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('Database initialization error: $e');
  }

  runApp(const FacultyMarksApp());
}

class FacultyMarksApp extends StatelessWidget {
  const FacultyMarksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faculty Marks Manager',
      debugShowCheckedModeBanner: false,
      theme: NeonTheme.darkTheme,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _isLoading = true;
  bool _hasSetup = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    try {
      final db = DatabaseHelper.instance;
      final faculty = await db.getFaculty();
      if (mounted) {
        setState(() {
          _hasSetup = faculty != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking setup: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error initializing app',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _checkSetup();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _hasSetup ? const HomeScreen() : const SetupScreen();
  }
}
