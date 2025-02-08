import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ViewEvaluationStatus extends StatefulWidget {
  const ViewEvaluationStatus({super.key});

  @override
  _ViewEvaluationStatusState createState() => _ViewEvaluationStatusState();
}

class _ViewEvaluationStatusState extends State<ViewEvaluationStatus> {
  String? selectedClass;
  String? selectedEvaluation;
  List<String> classes = [
    'Form 1',
    'Form 2',
    'Form 3',
    'Form 4',
    'Form 5',
    'Lowersixth',
    'Uppersixth'
  ]; // Updated classes
  List<String> evaluations = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6'
  ]; // Updated evaluations
  Map<String, double> subjectsPercentage = {};
  bool isLoading = false;

  Future<void> fetchSubjectsAndCalculatePercentage() async {
    if (selectedClass == null || selectedEvaluation == null) return;

    setState(() {
      isLoading = true;
    });

    final subjectQuery = QueryBuilder<ParseObject>(ParseObject('Subjects'))
      ..whereEqualTo('class', selectedClass);

    final studentQuery = QueryBuilder<ParseObject>(
        ParseObject(selectedClass!.replaceAll(" ", "")))
      ..whereEqualTo('class', selectedClass);

    final subjectResponse = await subjectQuery.query();
    final studentResponse = await studentQuery.query();

    if (subjectResponse.success &&
        subjectResponse.results != null &&
        studentResponse.success &&
        studentResponse.results != null) {
      final subjects = subjectResponse.results!.cast<ParseObject>();
      final students = studentResponse.results!.cast<ParseObject>();

      Map<String, double> tempSubjectsPercentage = {};

      for (var subject in subjects) {
        String subjectName = subject.get<String>('name') ?? '';
        int filledCount = 0;

        for (var student in students) {
          final marksArray =
              student.get<List<dynamic>>(subjectName.replaceAll(" ", "")) ?? [];
          if (marksArray.isNotEmpty &&
              marksArray[int.parse(selectedEvaluation!) - 1]
                  .toString()
                  .isNotEmpty) {
            filledCount++;
          }
        }

        double percentage = (filledCount / students.length) * 100;
        tempSubjectsPercentage[subjectName] = percentage;
      }

      setState(() {
        subjectsPercentage = tempSubjectsPercentage;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Evaluation Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('Select Class'),
                  value: selectedClass,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedClass = newValue;
                      fetchSubjectsAndCalculatePercentage();
                    });
                  },
                  items: classes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Select Evaluation',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('Select Evaluation'),
                  value: selectedEvaluation,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedEvaluation = newValue;
                      fetchSubjectsAndCalculatePercentage();
                    });
                  },
                  items:
                      evaluations.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            /*  DropdownButton<String>(
              hint: const Text('Select Evaluation'),
              value: selectedEvaluation,
              onChanged: (String? newValue) {
                setState(() {
                  selectedEvaluation = newValue;
                  fetchSubjectsAndCalculatePercentage();
                });
              },
              items: evaluations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ), */
            const SizedBox(
              height: 15,
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.separated(
                      itemCount: subjectsPercentage.length,
                      itemBuilder: (context, index) {
                        String subject =
                            subjectsPercentage.keys.elementAt(index);
                        double percentage = subjectsPercentage[subject] ?? 0.0;
                        return ListTile(
                          title: Text(subject),
                          trailing: Text('${percentage.toStringAsFixed(1)}%'),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        thickness: 1.5,
                      ),
                    ),
                  ),
            const Divider(thickness: 1.5)
          ],
        ),
      ),
    );
  }
}
