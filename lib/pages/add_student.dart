import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  bool isLoading = false;
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

  void addStudent() {
    final name = nameController.text.trim();
    final dob = dobController.text.trim();

    if (name.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Save student to the backend here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student added successfully')),
    );

    // Clear the form after submission
    nameController.clear();
    dobController.clear();
    setState(() {
      selectedClass = 'Form 1';
      selectedTrade = 'None';
    });
  }

  Future<void> addStudent1() async {
    setState(() {
      isLoading = true;
    });

    final String name = nameController.text.trim();
    final String dob = dobController.text.trim();

    if (name.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final ParseObject student = ParseObject(selectedClass.replaceAll(' ', ''))
      ..set('name', name.toUpperCase())
      ..set('dob', dob)
      ..set('class', selectedClass)
      ..set('trade', selectedTrade);

    final ParseResponse response = await student.save();
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
      Navigator.pop(context); // Return to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to add student: ${response.error!.message}')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter student full name',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Class',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Date of Birth',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dobController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'DD-MM-YYYY',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              const Text(
                'Trade',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: ElevatedButton(
                        onPressed: addStudent1,
                        child: const Text('Add Student'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
