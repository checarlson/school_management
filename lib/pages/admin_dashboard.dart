import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:school_management/pages/loginpage.dart';
import 'package:school_management/pages/manage_students.dart';
import 'package:school_management/pages/view_evaluation_status.dart';
import 'package:school_management/pages/manage_class.dart';
import 'package:school_management/pages/manage_teachers.dart';
import 'package:school_management/pages/generate_class_list.dart';

import 'generate_report_card.dart';
import 'generate_master_sheet.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final currentUser = await ParseUser.currentUser() as ParseUser?;
              if (currentUser != null) {
                await currentUser.logout();
              }
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );

              // Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          children: [
            _buildDashboardItem(
              context,
              icon: Icons.person_add_alt_1_outlined,
              label: 'Manage Students',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageStudentsScreen()),
                );
              },
            ),
            _buildDashboardItem(
              context,
              icon: Icons.assignment_outlined,
              label: 'View Evaluation Status',
              onTap: () {
                // Implement navigation for evaluation status
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewEvaluationStatus()),
                );
              },
            ),
            _buildDashboardItem(
              context,
              icon: Icons.table_chart_outlined,
              label: 'Generate Master Sheet',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GenerateMasterSheetScreen()),
                );
              },
            ),
            _buildDashboardItem(
              context,
              icon: Icons.picture_as_pdf_outlined,
              label: 'Generate Report Cards',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GenerateReportCardScreen()),
                );
              },
            ),
            _buildDashboardItem(
              context,
              icon: Icons.class_,
              label: 'Manage Class',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageClassScreen()),
                );
              },
            ),
            _buildDashboardItem(
              context,
              icon: Icons.person,
              label: 'Manage Teachers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageTeachersScreen()),
                );
              },
            ),
            _buildDashboardItem(
              context,
              icon: Icons.list_alt,
              label: 'Generate Class List',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GenerateClassListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a dashboard item widget
  Widget _buildDashboardItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
