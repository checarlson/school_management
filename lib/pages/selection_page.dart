import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:school_management/pages/evaluation_entry.dart';

class CombinedSelectionScreen extends StatefulWidget {
  final String className;

  const CombinedSelectionScreen({required this.className, super.key});

  @override
  _CombinedSelectionScreenState createState() =>
      _CombinedSelectionScreenState();
}

class _CombinedSelectionScreenState extends State<CombinedSelectionScreen> {
  String? selectedClass;
  String? selectedEvaluation;
  String? selectedSubject;
  List<String> classes = [
    'Form 1',
    'Form 2',
    'Form 3',
    'Form 4',
    'Form 5',
    'Lower Sixth',
    'Upper Sixth'
  ];
  List<String> evaluations = [' 1 ', ' 2 ', ' 3 ', ' 4 ', ' 5 ', ' 6 '];
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;

    final query = QueryBuilder<ParseObject>(ParseObject('Subjects'))
      ..whereEqualTo('class', widget.className.toString())
      ..whereEqualTo('teacher', currentUser?.username);

    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        subjects = response.results!
            .map((e) => e.get<String>('name') ?? 'Unknown Subject')
            .cast<String>()
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Evaluation & Subject')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /* DropdownButtonFormField<String>(
              value: selectedClass,
              onChanged: (value) {
                setState(() {
                  selectedClass = value!;
                });
              },
              items: classes
                  .map((className) => DropdownMenuItem<String>(
                        value: className,
                        child: Text(className),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: "Select Class",
                border: OutlineInputBorder(),
              ),
            ), */
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedEvaluation,
              onChanged: (value) {
                setState(() {
                  selectedEvaluation = value!;
                  fetchSubjects();
                });
              },
              items: evaluations
                  .map((eval) => DropdownMenuItem<String>(
                        value: eval,
                        child: Text(eval),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: "Select Evaluation",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedSubject,
              onChanged: (value) {
                setState(() {
                  selectedSubject = value!;
                });
              },
              onTap: selectedClass != null ? fetchSubjects : null,
              items: subjects
                  .map((subject) => DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: "Select Subject",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedEvaluation != null && selectedSubject != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EvaluationEntryScreen(
                            className:
                                widget.className, // Correct parameter name
                            selectedSubject: selectedSubject!,
                            selectedEvaluation: selectedEvaluation!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
