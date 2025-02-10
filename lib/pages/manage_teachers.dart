import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  _ManageTeachersScreenState createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  List<ParseObject> teachers = [];
  List<ParseObject> filteredTeachers = [];
  bool isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  /* Future<void> fetchTeachers() async {
    final ParseCloudFunction function = ParseCloudFunction('getAllTeachers');
    final ParseResponse result = await function.execute();

    if (result.success && result.result != null) {
      setState(() {
        teachers = (result.result as List)
            .map((e) => ParseObject('_User')..set('username', e['username']))
            .cast<ParseObject>()
            .toList();
        filteredTeachers = teachers;
      });
      print("Teachers List: $teachers");
    } else {
      print("Failed to fetch teachers.");
    }
  } */

  Future<void> fetchTeachers() async {
    final ParseCloudFunction function = ParseCloudFunction('getAllTeachers');
    final ParseResponse result = await function.execute();

    if (result.success && result.result != null) {
      setState(() {
        teachers = (result.result as List)
            .map((e) => ParseObject('_User')
              ..objectId = e['objectId'] // ✅ Ensure objectId is set
              ..set('username', e['username']))
            .cast<ParseObject>()
            .toList();
        filteredTeachers = teachers;
      });
      print("Teachers List: $teachers");
    } else {
      print("Failed to fetch teachers.");
    }
  }

  void filterTeachers(String query) {
    setState(() {
      searchQuery = query;
      filteredTeachers = teachers
          .where((teacher) => teacher
              .get<String>('username')!
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteTeacher(ParseObject teacher) async {
    setState(() {
      isLoading = true;
    });

    final response = await teacher.delete();
    if (response.success) {
      fetchTeachers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to delete teacher: ${response.error!.message}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  /* void showEditTeacherDialog(ParseObject teacher) {
    final usernameController =
        TextEditingController(text: teacher.get<String>('username'));
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Teacher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isNotEmpty) {
                final ParseUser user = ParseUser(
                  usernameController.text.trim(),
                  passwordController.text.trim(),
                  null,
                );
                user.password = passwordController.text.trim();
                final response = await user.save();
                if (response.success) {
                  fetchTeachers();
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Failed to update teacher: ${response.error!.message}')),
                  );
                }
              } else {
                teacher.set('username', usernameController.text.trim());
                final response = await teacher.save();
                if (response.success) {
                  fetchTeachers();
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Failed to update teacher: ${response.error!.message}')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  } */

  void showEditTeacherDialog(ParseObject teacher) {
    final usernameController =
        TextEditingController(text: teacher.get<String>('username'));
    final passwordController = TextEditingController();

    // Ensure teacher has an objectId before proceeding
    if (teacher.objectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Teacher ID not found!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Teacher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final String newUsername = usernameController.text.trim();
              final String newPassword = passwordController.text.trim();
              final String teacherId =
                  teacher.objectId!; // Now guaranteed to exist

              final ParseCloudFunction function =
                  ParseCloudFunction('updateTeacher');
              final ParseResponse response =
                  await function.execute(parameters: {
                'objectId': teacherId,
                'username': newUsername,
                if (newPassword.isNotEmpty) 'password': newPassword,
              });

              if (response.success) {
                fetchTeachers(); // Refresh the list
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to update teacher: ${response.error!.message}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showAddTeacherDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Teacher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final teacher = ParseUser.createUser(
                usernameController.text.trim(),
                passwordController.text.trim(),
                null,
              )..set('role', 'teacher');

              final response = await teacher.signUp(allowWithoutEmail: true);
              if (response.success) {
                fetchTeachers();
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to add teacher: ${response.error!.message}')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Teachers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddTeacherDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterTeachers,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher = filteredTeachers[index];
                      return Column(
                        children: [
                          Dismissible(
                            key: Key(teacher.objectId ?? ''),
                            background: Container(
                              color: Colors.green,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.edit, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                showEditTeacherDialog(teacher);
                                return false;
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                final bool? res = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm"),
                                      content: const Text(
                                          "Are you sure you want to delete this teacher?"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (res == true) {
                                  deleteTeacher(teacher);
                                }
                                return res;
                              }
                              return false;
                            },
                            child: ListTile(
                              title: Text(teacher
                                      .get<String>('username')
                                      ?.toUpperCase() ??
                                  ''),
                            ),
                          ),
                          const Divider(
                            thickness: 1.5,
                          ), // Add divider here
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
