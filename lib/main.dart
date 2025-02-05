import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:school_management/pages/loginpage.dart';

import 'pages/add_student.dart';
import 'pages/admin_dashboard.dart';
import 'pages/teacher_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String appId = "JtDx53oHL7YqmQjyBEPIAEC50DGzUwX8S3BMEUET";
  const String clientKey = "xe1UQtkB38VAf7cdgGcg0PqlVadXZn4XUqFQ0TT5";
  const String parseServerUrl = "https://parseapi.back4app.com/";

  await Parse().initialize(appId, parseServerUrl,
      clientKey: clientKey, autoSendSessionId: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> checkSession() async {
    final ParseUser? user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) {
      return '/login';
    } else {
      final role = user.get('role');
      if (role == 'admin') {
        return '/adminDashboard';
      } else if (role == 'teacher') {
        return '/teacherDashboard';
      }
    }
    return '/login'; // Fallback in case of unexpected behavior
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        // '/': (context) => const SplashScreen(),
        '/': (context) => const LoginScreen(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/addStudent': (context) => const AddStudentScreen(),
        '/teacherDashboard': (context) => const TeacherDashboard(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      const MyApp app = MyApp();
      final route = await app.checkSession();
      Navigator.pushReplacementNamed(context, route);
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Placeholder Widgets
/* class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login Screen')),
    );
  }
} */

/* class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('Admin Dashboard')),
    );
  }
} */

/* class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Dashboard')),
      body: const Center(child: Text('Teacher Dashboard')),
    );
  }
} */
