import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class GenerateReportCardScreen extends StatefulWidget {
  const GenerateReportCardScreen({super.key});

  @override
  _GenerateReportCardScreenState createState() =>
      _GenerateReportCardScreenState();
}

class _GenerateReportCardScreenState extends State<GenerateReportCardScreen> {
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
        ParseObject(selectedClass!.replaceAll(" ", "")));

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

  Future<void> generateReportCard(ParseObject student) async {
    final pdf = pw.Document();
    final termEvaluations = getTermEvaluations(selectedTerm!);

    final studentAverages = students.map((student) {
      return {
        'name': student.get<String>('name'),
        'average': calculateOverallAverage(student, termEvaluations),
      };
    }).toList();

    studentAverages.sort((a, b) =>
        (b['average'] as double? ?? 0).compareTo(a['average'] as double? ?? 0));

    final studentRank = studentAverages
            .indexWhere((s) => s['name'] == student.get<String>('name')) +
        1;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Report Card', style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Name: ${student.get<String>('name') ?? ''}'),
              pw.Text('Class: ${selectedClass ?? ''}'),
              pw.Text('Term: ${selectedTerm ?? ''}'),
              pw.Text('Rank: $studentRank'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Subject', 'Evaluation 1', 'Evaluation 2', 'Average'],
                data: subjects.map((subject) {
                  final subjectName = subject.get<String>('name') ?? '';
                  final marksArray = student.get<List<dynamic>>(
                          subjectName.replaceAll(" ", "")) ??
                      List.filled(6, '');
                  final eval1 = marksArray[termEvaluations[0] - 1] ?? '';
                  final eval2 = marksArray[termEvaluations[1] - 1] ?? '';
                  final average = ((double.tryParse(eval1.toString()) ?? 0) +
                          (double.tryParse(eval2.toString()) ?? 0)) /
                      2;
                  return [
                    subjectName,
                    eval1.toString(),
                    eval2.toString(),
                    average.toStringAsFixed(2)
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Overall Average: ${calculateOverallAverage(student, termEvaluations).toStringAsFixed(2)}',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report Card'),
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
                : Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Card(
                          child: ListTile(
                            title: Text(student.get<String>('name') ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              onPressed: () => generateReportCard(student),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
