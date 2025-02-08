import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class GenerateMasterSheetScreen extends StatefulWidget {
  const GenerateMasterSheetScreen({super.key});

  @override
  _GenerateMasterSheetScreenState createState() =>
      _GenerateMasterSheetScreenState();
}

class _GenerateMasterSheetScreenState extends State<GenerateMasterSheetScreen> {
  String? selectedClass;
  String? selectedTerm;
  List<ParseObject> students = [];
  List<ParseObject> subjects = [];
  bool isLoading = false;

  final List<String> classes = [
    'Form 1',
    'Form 2',
    'Form 3',
    'Form 4',
    'Form 5',
    'Lower Sixth',
    'Upper Sixth',
  ];

  final List<String> terms = [
    'Term 1',
    'Term 2',
    'Term 3',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchStudentsAndSubjects() async {
    if (selectedClass == null) return;

    setState(() {
      isLoading = true;
    });

    final studentQuery = QueryBuilder<ParseObject>(
        ParseObject(selectedClass!.replaceAll(" ", "")))
      ..orderByAscending('name');

    final subjectQuery = QueryBuilder<ParseObject>(ParseObject('Subjects'))
      ..whereEqualTo('class', selectedClass);

    final studentResponse = await studentQuery.query();
    final subjectResponse = await subjectQuery.query();

    if (studentResponse.success && studentResponse.results != null) {
      setState(() {
        students = studentResponse.results!.cast<ParseObject>();
      });
    }

    if (subjectResponse.success && subjectResponse.results != null) {
      setState(() {
        subjects = subjectResponse.results!.cast<ParseObject>();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> generateMasterSheet() async {
    final pdf = pw.Document();
    final termEvaluations = getTermEvaluations(selectedTerm!);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Master Sheet', style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Class: ${selectedClass ?? ''}'),
              pw.Text('Term: ${selectedTerm ?? ''}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Name',
                  ...subjects
                      .map((subject) => subject.get<String>('name') ?? '')
                      .toList(),
                  'Overall Average',
                  'Rank'
                ],
                data: students.map((student) {
                  final averages = subjects.map((subject) {
                    final subjectName = subject.get<String>('name') ?? '';
                    final marksArray = student.get<List<dynamic>>(
                            subjectName.replaceAll(" ", "")) ??
                        List.filled(6, '');
                    final eval1 = marksArray[termEvaluations[0] - 1] ?? '';
                    final eval2 = marksArray[termEvaluations[1] - 1] ?? '';
                    final average = ((double.tryParse(eval1.toString()) ?? 0) +
                            (double.tryParse(eval2.toString()) ?? 0)) /
                        2;
                    return average.toStringAsFixed(2);
                  }).toList();

                  final overallAverage =
                      calculateOverallAverage(student, termEvaluations);
                  final rank = calculateRank(student, termEvaluations);

                  return [
                    student.get<String>('name')?.toUpperCase() ?? '',
                    ...averages,
                    overallAverage.toStringAsFixed(2),
                    rank.toString()
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  List<int> getTermEvaluations(String term) {
    switch (term) {
      case 'Term 1':
        return [1, 2];
      case 'Term 2':
        return [3, 4];
      case 'Term 3':
        return [5, 6];
      default:
        return [1, 2];
    }
  }

  double calculateOverallAverage(
      ParseObject student, List<int> termEvaluations) {
    double total = 0;
    int count = 0;

    for (var subject in subjects) {
      final subjectName = subject.get<String>('name') ?? '';
      final marksArray =
          student.get<List<dynamic>>(subjectName.replaceAll(" ", "")) ??
              List.filled(6, '');
      final eval1 = marksArray[termEvaluations[0] - 1] ?? '';
      final eval2 = marksArray[termEvaluations[1] - 1] ?? '';
      final average = ((double.tryParse(eval1.toString()) ?? 0) +
              (double.tryParse(eval2.toString()) ?? 0)) /
          2;
      total += average;
      count++;
    }

    return count > 0 ? total / count : 0;
  }

  int calculateRank(ParseObject student, List<int> termEvaluations) {
    final studentAverages = students.map((student) {
      return {
        'name': student.get<String>('name'),
        'average': calculateOverallAverage(student, termEvaluations),
      };
    }).toList();

    studentAverages.sort((a, b) =>
        (b['average'] as double? ?? 0).compareTo(a['average'] as double? ?? 0));

    final studentName = student.get<String>('name');
    for (int i = 0; i < studentAverages.length; i++) {
      if (studentAverages[i]['name'] == studentName) {
        return i + 1;
      }
    }
    return studentAverages.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Master Sheet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  selectedClass = value;
                  fetchStudentsAndSubjects();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedTerm,
              items: terms.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTerm = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Term',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: generateMasterSheet,
                    child: const Text('Generate Master Sheet'),
                  ),
          ],
        ),
      ),
    );
  }
}
