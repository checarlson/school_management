import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  _ManageStudentsScreenState createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  List<ParseObject> students = [];
  List<ParseObject> filteredStudents = [];
  bool isLoading = false;
  String searchQuery = '';
  String? selectedClass;
  final List<String> classes = [
    'Form 1',
    'Form 2',
    'Form 3',
    'Form 4',
    'Form 5',
    'Lower Sixth',
    'Upper Sixth',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchStudents() async {
    if (selectedClass == null) return;

    setState(() {
      isLoading = true;
    });

    final query = QueryBuilder<ParseObject>(
        ParseObject(selectedClass!.replaceAll(" ", "")))
      ..orderByAscending('name');

    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        students = response.results!.cast<ParseObject>();
        filteredStudents = students;
        isLoading = false;
      });
    }
  }

  void filterStudents(String query) {
    setState(() {
      searchQuery = query;
      filteredStudents = students
          .where((student) => student
              .get<String>('name')!
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteStudent(ParseObject student) async {
    setState(() {
      isLoading = true;
    });

    final response = await student.delete();
    if (response.success) {
      fetchStudents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to delete student: ${response.error!.message}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void showEditStudentDialog(ParseObject student) {
    final nameController =
        TextEditingController(text: student.get<String>('name'));
    final dobController =
        TextEditingController(text: student.get<String>('dob'));
    final classController =
        TextEditingController(text: student.get<String>('class'));
    final oldClass = student.get<String>('class');
    final tradeController =
        TextEditingController(text: student.get<String>('trade'));

    String selectedTrade = 'None';

    final List<String> trades = [
      'None',
      'Grammar',
      'Commercial',
      'Industrial',
    ];

    print("old: $oldClass");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: 'Date of Birth'),
            ),
            const SizedBox(
              height: 20,
            ),
            DropdownButtonFormField<String>(
              value: selectedClass,
              items: classes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClass = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Class',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            DropdownButtonFormField<String>(
              value: selectedTrade,
              items: trades.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTrade = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Trade',
                border: OutlineInputBorder(),
              ),
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
              print("new: ${classController.text.trim()}");
              if (oldClass != classController.text.trim()) {
                final student1 =
                    ParseObject(classController.text.replaceAll(" ", ""))
                      ..set('name', nameController.text.trim())
                      ..set('dob', dobController.text.trim())
                      ..set('class', selectedClass)
                      ..set('trade', selectedTrade);

                final response = await student1.save();
                if (response.success) {
                  fetchStudents();
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Failed to edit student: ${response.error!.message}')),
                  );
                }
                deleteStudent(student);
              } else {
                student
                  ..set('name', nameController.text.trim())
                  ..set('dob', dobController.text.trim())
                  ..set('class', selectedClass)
                  ..set('trade', selectedTrade);

                final response = await student.save();
                if (response.success) {
                  fetchStudents();
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Failed to update student: ${response.error!.message}')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showAddStudentDialog() {
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    String selectedClass = 'Form 1';
    String selectedTrade = 'None';

    final List<String> classes = [
      'Form 1',
      'Form 2',
      'Form 3',
      'Form 4',
      'Form 5',
      'Lower Sixth',
      'Upper Sixth',
    ];

    final List<String> trades = [
      'None',
      'Grammar',
      'Commercial',
      'Industrial',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter full name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'DD/MM/YYYY',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedClass,
                items: classes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClass = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedTrade,
                items: trades.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTrade = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Trade',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final student = ParseObject(selectedClass.replaceAll(" ", ""))
                ..set('name', nameController.text.trim())
                ..set('dob', dobController.text.trim())
                ..set('class', selectedClass)
                ..set('trade', selectedTrade);

              final response = await student.save();
              if (response.success) {
                fetchStudents();
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to add student: ${response.error!.message}')),
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
        title: const Text('Manage Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddStudentDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: selectedClass,
              items: classes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClass = value;
                  fetchStudents();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (selectedClass != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: filterStudents,
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return Column(
                          children: [
                            Dismissible(
                              key: Key(student.objectId!),
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
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  showEditStudentDialog(student);
                                  return false;
                                } else if (direction ==
                                    DismissDirection.endToStart) {
                                  final bool? res = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm"),
                                        content: const Text(
                                            "Are you sure you want to delete this student?"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
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
                                    deleteStudent(student);
                                  }
                                  return res;
                                }
                                return false;
                              },
                              child: ListTile(
                                title: Text(student
                                        .get<String>('name')
                                        ?.toUpperCase() ??
                                    ''),
                                subtitle: Text(
                                    'DOB: ${student.get<String>('dob') ?? ''}'),
                                trailing:
                                    Text(student.get<String>('class') ?? ''),
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
        ],
      ),
    );
  }
}
