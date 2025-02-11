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
  String? selectedEvaluation;
  String? selectedSubject;
  String? selectedTrade;
  List<String> evaluations = ['1', '2', '3', '4', '5', '6'];
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;

    final query = QueryBuilder<ParseObject>(ParseObject('Subjects'))
      ..whereEqualTo('class', widget.className)
      ..whereEqualTo('teacher', currentUser?.username);

    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        subjects = response.results!
            .map((e) => {
                  'name': e.get<String>('name') ?? 'Unknown Subject',
                  'trade': e.get<String>('trade') ?? 'None'
                })
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
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedEvaluation,
              onChanged: (value) {
                setState(() {
                  selectedEvaluation = value!;
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
                  selectedTrade = subjects.firstWhere(
                      (subject) => subject['name'] == value)['trade'];
                });
              },
              items: subjects
                  .map((subject) => DropdownMenuItem<String>(
                        value: subject['name'],
                        child: Text(subject['name']!),
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
                            className: widget.className,
                            selectedSubject: selectedSubject!,
                            selectedEvaluation: selectedEvaluation!,
                            trade: selectedTrade!,
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
