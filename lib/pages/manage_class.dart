import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ManageClassScreen extends StatefulWidget {
  const ManageClassScreen({super.key});

  @override
  _ManageClassScreenState createState() => _ManageClassScreenState();
}

class _ManageClassScreenState extends State<ManageClassScreen> {
  List<ParseObject> subjects = [];
  List<ParseObject> filteredSubjects = [];
  List<String> teachers = [];
  bool isLoading = false;
  String searchQuery = '';
  String? selectedClass;
  String? selectedTeacher1;
  final List<String> classes = [
    'Form 1',
    'Form 2',
    'Form 3',
    'Form 4',
    'Form 5',
    'Lower Sixth',
    'Upper Sixth',
  ];

  List<String> teachers1 = [];

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  /// Fetches the list of teachers from the server
  Future<void> fetchTeachers() async {
    final ParseCloudFunction function = ParseCloudFunction('getAllTeachers');
    final ParseResponse result = await function.execute();

    if (result.success && result.result != null) {
      setState(() {
        teachers1 = (result.result as List)
            .map((e) => e['username'] ?? 'Unknown Teacher')
            .cast<String>()
            .toList();
      });
      print("Teachers List: $teachers1");
    } else {
      print("Failed to fetch teachers.");
    }
  }

  /// Fetches the list of subjects for the selected class
  Future<void> fetchSubjects() async {
    if (selectedClass == null) return;

    setState(() {
      isLoading = true;
    });

    final query = QueryBuilder<ParseObject>(ParseObject('Subjects'))
      ..whereEqualTo('class', selectedClass);

    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        subjects = response.results!.cast<ParseObject>();
        filteredSubjects = subjects;
        isLoading = false;
      });
    }
  }

  /// Filters the list of subjects based on the search query
  void filterSubjects(String query) {
    setState(() {
      searchQuery = query;
      filteredSubjects = subjects
          .where((subject) =>
              subject
                  .get<String>('name')!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              subject
                  .get<String>('trade')!
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Deletes the specified subject
  Future<void> deleteSubject(ParseObject subject) async {
    setState(() {
      isLoading = true;
    });

    final response = await subject.delete();
    if (response.success) {
      fetchSubjects();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to delete subject: ${response.error!.message}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Shows a dialog to edit the specified subject
  void showEditSubjectDialog(ParseObject subject) {
    final nameController =
        TextEditingController(text: subject.get<String>('name'));
    final coefController =
        TextEditingController(text: subject.get<String>('coef'));
    selectedTeacher1 = subject.get<String>('teacher');
    String? selectedTrade = subject.get<String>('trade');

    final List<String> trades = [
      'None',
      'Grammar',
      'Commercial',
      'Industrial',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter subject name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: coefController,
              decoration: const InputDecoration(
                labelText: 'Coefficient',
                hintText: 'Enter coefficient',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            DropdownButtonFormField<String>(
              value: selectedTeacher1,
              onChanged: (value) {
                setState(() {
                  selectedTeacher1 = value!;
                });
              },
              items: teachers1
                  .map((teacher) => DropdownMenuItem<String>(
                        value: teacher,
                        child: Text(teacher),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: "Teacher",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            DropdownButtonFormField<String>(
              value: selectedTrade,
              onChanged: (value) {
                setState(() {
                  selectedTrade = value!;
                });
              },
              items: trades.map((trade) {
                return DropdownMenuItem<String>(
                  value: trade,
                  child: Text(trade),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: "Trade",
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
              subject
                ..set('name', nameController.text.trim())
                ..set('coef', coefController.text.trim())
                ..set('teacher', selectedTeacher1)
                ..set('trade', selectedTrade);

              final response = await subject.save();
              if (response.success) {
                fetchSubjects();
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to update subject: ${response.error!.message}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog to add a new subject
  void showAddSubjectDialog() {
    final nameController = TextEditingController();
    final coefController = TextEditingController();
    String? selectedTrade = 'None';

    final List<String> trades = [
      'None',
      'Grammar',
      'Commercial',
      'Industrial',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Subject'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter subject name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: coefController,
                decoration: const InputDecoration(
                  labelText: 'Coefficient',
                  hintText: 'Enter coefficient',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedTeacher1,
                onChanged: (value) {
                  setState(() {
                    selectedTeacher1 = value!;
                  });
                },
                items: teachers1.map((teacher) {
                  return DropdownMenuItem<String>(
                    value: teacher,
                    child: Text(teacher),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "Teacher",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedTrade,
                onChanged: (value) {
                  setState(() {
                    selectedTrade = value!;
                  });
                },
                items: trades.map((trade) {
                  return DropdownMenuItem<String>(
                    value: trade,
                    child: Text(trade),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "Trade",
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
              final subject = ParseObject('Subjects')
                ..set('name', nameController.text.trim())
                ..set('coef', coefController.text.trim())
                ..set('class', selectedClass)
                ..set('teacher', selectedTeacher1)
                ..set('trade', selectedTrade);

              final response = await subject.save();
              if (response.success) {
                fetchSubjects();
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to add subject: ${response.error!.message}')),
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
        title: const Text('Manage Class'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddSubjectDialog,
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
                  fetchSubjects();
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
                onChanged: filterSubjects,
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = filteredSubjects[index];
                        return Column(
                          children: [
                            Dismissible(
                              key: Key(subject.objectId!),
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
                                  showEditSubjectDialog(subject);
                                  return false;
                                } else if (direction ==
                                    DismissDirection.endToStart) {
                                  final bool? res = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm"),
                                        content: const Text(
                                            "Are you sure you want to delete this subject?"),
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
                                    deleteSubject(subject);
                                  }
                                  return res;
                                }
                                return false;
                              },
                              child: ListTile(
                                title: Text(subject
                                        .get<String>('name')
                                        ?.toUpperCase() ??
                                    ''),
                                subtitle: Text(
                                    'Coefficient: ${subject.get<String>('coef') ?? ''}'),
                                trailing: Column(
                                  children: [
                                    Text(subject.get<String>('teacher') ?? ''),
                                    Text(subject.get<String>('trade') ?? ''),
                                  ],
                                ),
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
