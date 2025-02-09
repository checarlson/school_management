import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class EvaluationEntryScreen extends StatefulWidget {
  final String selectedSubject;
  final String className;
  final String selectedEvaluation;

  const EvaluationEntryScreen({
    required this.className,
    required this.selectedSubject,
    required this.selectedEvaluation,
    super.key,
  });

  @override
  _EvaluationEntryScreenState createState() => _EvaluationEntryScreenState();
}

class _EvaluationEntryScreenState extends State<EvaluationEntryScreen> {
  List<ParseObject> students = [];
  List<Map<String, String>> studentMarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final query = QueryBuilder<ParseObject>(
        ParseObject(widget.className.replaceAll(" ", "")))
      ..includeObject([widget.selectedSubject.replaceAll(" ", "")])
      ..orderByAscending('name'); // Include the selected subject column

    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        students = response.results!.cast<ParseObject>();
        studentMarks = students.map((e) {
          final marksArray = e.get<List<dynamic>>(
                  widget.selectedSubject.replaceAll(" ", "")) ??
              List.filled(6, '');
          final evaluationIndex =
              int.parse(widget.selectedEvaluation.trim()) - 1;
          final marks = marksArray[evaluationIndex] ?? '';
          return {'id': e.objectId!, 'marks': marks.toString()};
        }).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluation for ${widget.className}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter ${widget.selectedSubject} Evaluation ${widget.selectedEvaluation} for ${widget.className}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  students.isEmpty
                      ? const Center(
                          child: Text('No students found for this class'))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            student
                                                    .get<String>('name')
                                                    ?.toUpperCase() ??
                                                'Unknown Student',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: TextEditingController(
                                              text: studentMarks[index]
                                                  ['marks'],
                                            ),
                                            onChanged: (value) {
                                              studentMarks[index]['marks'] =
                                                  value;
                                            },
                                            decoration: const InputDecoration(
                                              labelText: 'Marks',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal:
                                                          10.0), // Adjust padding
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 1.5,
                                  ), // Add horizontal divider
                                ],
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      for (var studentMark in studentMarks) {
                        final query = QueryBuilder<ParseObject>(
                            ParseObject(widget.className.replaceAll(" ", "")))
                          ..whereEqualTo('objectId', studentMark['id']);

                        final response = await query.query();
                        if (response.success && response.results != null) {
                          final student =
                              response.results!.first as ParseObject;
                          final marksArray = student.get<List<dynamic>>(
                                  widget.selectedSubject.replaceAll(" ", "")) ??
                              List.filled(6, '');
                          final evaluationIndex =
                              int.parse(widget.selectedEvaluation.trim()) - 1;
                          marksArray[evaluationIndex] = studentMark['marks'];
                          student.set(
                              widget.selectedSubject.replaceAll(" ", ""),
                              marksArray);
                          await student.save();
                        }
                      }

                      setState(() {
                        isLoading = false;
                      });

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Evaluation saved successfully.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Save Evaluation'),
                  ),
                ],
              ),
      ),
    );
  }
}
