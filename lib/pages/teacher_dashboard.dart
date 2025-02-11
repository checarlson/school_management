import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:school_management/pages/loginpage.dart';
import 'package:school_management/pages/selection_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List<String> assignedClasses = [];
  bool isLoading = true;
  late final String user;

  @override
  void initState() {
    super.initState();
    fetchAssignedClasses();
  }

  Future<void> fetchAssignedClasses() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch current logged-in user
      final ParseUser? currentUser =
          await ParseUser.currentUser() as ParseUser?;

      user = currentUser!.username.toString();

      // Query classes assigned to the teacher
      final QueryBuilder<ParseObject> queryClasses =
          QueryBuilder<ParseObject>(ParseObject('Subjects'))
            ..whereEqualTo('teacher', currentUser.username);

      final ParseResponse response = await queryClasses.query();
      if (response.success && response.results != null) {
        setState(() {
          assignedClasses = (response.results! as List<ParseObject>)
              .map((e) =>
                  e.get<String>('class') ?? 'Unknown Class') // Cast to String
              .toSet() // Convert to Set to remove duplicates
              .toList(); // Convert back to List
        });
      }
    } catch (e) {
      // Handle any errors
      debugPrint('Error fetching classes: $e');
    }

    setState(() {
      isLoading = false;
      // user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              final currentUser = await ParseUser.currentUser() as ParseUser?;
              if (currentUser != null) {
                await currentUser.logout();
              }
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Welcome Mr/Mme $user',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                assignedClasses.isEmpty
                    ? const Center(child: Text('No classes assigned.'))
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: assignedClasses.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  title: Text(assignedClasses[index]),
                                  trailing: const Icon(Icons.arrow_forward),
                                  onTap: () {
                                    // Navigate to student list for the selected class
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CombinedSelectionScreen(
                                          className: assignedClasses[index],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
}
