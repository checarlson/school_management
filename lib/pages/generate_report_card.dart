import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

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
    'Lowersixth',
    'Uppersixth'
  ]; // Updated classes

  final List<String> terms = ['1', '2', '3']; // Updated terms

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

  Future<Uint8List> loadImage() async {
    final ByteData data = await rootBundle.load('assets/logo.PNG');
    return data.buffer.asUint8List();
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

    String getTerm(String term) {
      switch (term) {
        case '1':
          return 'First Term';
        case '2':
          return 'Second Term';
        case '3':
          return 'Third Term';
        default:
          return 'First Term';
      }
    }

    String getRemark(double average) {
      if (average >= 18) {
        return 'Excellent';
      } else if (average >= 15) {
        return 'V.Good';
      } else if (average >= 12) {
        return 'Good';
      } else if (average >= 10) {
        return 'Average';
      } else if (average >= 8) {
        return 'Weak';
      } else if (average >= 5) {
        return 'V.Weak';
      } else {
        return 'V.Poor';
      }
    }

    studentAverages.sort((a, b) =>
        (b['average'] as double? ?? 0).compareTo(a['average'] as double? ?? 0));

    final studentRank = studentAverages
            .indexWhere((s) => s['name'] == student.get<String>('name')) +
        1;

    Uint8List imageBytes = await loadImage(); // Load image before building PDF

    // Calculate totalAvg and noSub for the current student
    double totalAvg = 0;
    int noSub = 0;
    for (var subject in subjects) {
      final subjectName = subject.get<String>('name') ?? '';
      final marksArray =
          student.get<List<dynamic>>(subjectName.replaceAll(" ", "")) ??
              List.filled(6, '');
      final eval1 = marksArray[termEvaluations[0] - 1] ?? '';
      final eval2 = marksArray[termEvaluations[1] - 1] ?? '';

      if (eval1.toString().isEmpty && eval2.toString().isEmpty) {
        continue;
      }

      final average = ((double.tryParse(eval1.toString()) ?? 0) +
              (double.tryParse(eval2.toString()) ?? 0)) /
          2;
      totalAvg += average;
      noSub++;
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: double.infinity,
                child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('Paix - Travail - Patrie',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('**********'),
                            pw.Text('Ministere Des Enseignements',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('Secondaire',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('**********'),
                            pw.Text('Delegation - Regionale de L`Ouest',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('**********'),
                            pw.Text('Delegation Departmentale du NDE',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('**********'),
                            pw.Text('Legendary Dice College Bangangte',
                                style: const pw.TextStyle(fontSize: 10)),
                          ]),
                      pw.SizedBox(width: 20),
                      pw.Image(pw.MemoryImage(imageBytes),
                          width: 100, height: 100), // Fixed
                      pw.SizedBox(width: 20),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('Peace - Work - FatherLand',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('**********'),
                            pw.Text('Ministry of Secondary Education',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('**********'),
                            pw.Text('Regional Delegation of West',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('**********'),
                            pw.Text('Divisional Delegation for NDE',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('**********'),
                            pw.Text('Legendary Dice College Bangangte',
                                style: const pw.TextStyle(fontSize: 10)),
                          ]),
                    ]),
              ),
              pw.Center(
                  child: pw.Column(children: [
                pw.SizedBox(height: 5),
                pw.Text(('Legendary Dice College Bangangte').toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue)),
                pw.SizedBox(height: 5),
                pw.Text(
                    ('${getTerm(selectedTerm.toString())} Report Card')
                        .toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('School Year: 2024/2025',
                    style: const pw.TextStyle(fontSize: 14)),
              ])),
              // pw.Text('Report Card', style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 15),

              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'NAME: ${student.get<String>('name')?.toUpperCase() ?? ''}',
                              style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              ('Date of Birth: ${student.get<String>('dob') ?? ''}')
                                  .toUpperCase(),
                              style: const pw.TextStyle(fontSize: 12)),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                              'CLASS: ${(selectedClass ?? '').toUpperCase()}',
                              style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                        ]),
                  ]),

              pw.Text('Term: ${selectedTerm ?? ''}'),
              pw.Text('Rank: $studentRank'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Subject',
                  'Eva 1',
                  'Eva 2',
                  'AVG',
                  'Coef',
                  'Min',
                  'Max',
                  'Remark'
                ],
                headerStyle:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
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
                  final coef = subject.get<String>('coef') ?? '';
                  final minAverage = calculateMinAverage(subjectName);
                  final maxAverage = calculateMaxAverage(subjectName);

                  if (eval1.toString().isEmpty && eval2.toString().isEmpty) {
                    return [
                      subjectName,
                      '',
                      '',
                      '',
                      '', //coef.toString(),
                      '',
                      '',
                      '',
                    ];
                  }

                  return [
                    subjectName,
                    eval1.toString(),
                    eval2.toString(),
                    average.toStringAsFixed(2),
                    coef.toString(),
                    minAverage.toStringAsFixed(2),
                    maxAverage.toStringAsFixed(2),
                    getRemark(average),
                  ];
                }).toList(),
                cellAlignment: pw.Alignment.center, // Align all cells to center
                cellAlignments: {
                  0: pw.Alignment.centerLeft
                }, // Align Subject column to left
              ),
              //second table
              pw.Table.fromTextArray(
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                headers: [
                  ' ',
                ],
                data: [
                  [],
                ],
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerLeft,
                  5: pw.Alignment.centerLeft,
                },
              ),
              // pw.SizedBox(height: 10),

              // Adds space between tables
              pw.Column(children: [
                pw.Table.fromTextArray(
                  data: [
                    [
                      'Total AVG: $totalAvg',
                      'No. Subject: $noSub',
                      '1st Term Avg: ${calculateOverallAverage(student, termEvaluations).toStringAsFixed(2)} / 20',
                      'Rank: $studentRank',
                      'Remark: ${getRemark(calculateOverallAverage(student, termEvaluations))}',
                    ],
                  ],
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerLeft,
                    3: pw.Alignment.centerLeft,
                    4: pw.Alignment.centerLeft,
                    5: pw.Alignment.centerLeft,
                  },
                ),
                pw.Table.fromTextArray(
                  data: [
                    [
                      'Class Avg: 7.5 / 20',
                      '1st SQ AVG: 9.45',
                      '2nd SQ AVG: 7.98',
                      '1st Avg: 12.4',
                      'Last Avg: 4.3'
                    ],
                  ],
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerLeft,
                    3: pw.Alignment.centerLeft,
                    4: pw.Alignment.centerLeft,
                    5: pw.Alignment.centerLeft,
                  },
                ),
                pw.Table.fromTextArray(
                  data: [
                    ['No. ABSENCE: 0']
                  ],
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerLeft,
                    3: pw.Alignment.centerLeft,
                    4: pw.Alignment.centerLeft,
                    5: pw.Alignment.centerLeft,
                  },
                ),
              ]),

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
      case '1':
        return [1, 2];
      case '2':
        return [3, 4];
      case '3':
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

      if (eval1.toString().isEmpty && eval2.toString().isEmpty) {
        continue;
      }

      final average = ((double.tryParse(eval1.toString()) ?? 0) +
              (double.tryParse(eval2.toString()) ?? 0)) /
          2;
      total += average;
      count++;
    }

    return count > 0 ? total / count : 0;
  }

  double calculateMinAverage(String subjectName) {
    double minAverage = double.infinity;

    for (var student in students) {
      final marksArray =
          student.get<List<dynamic>>(subjectName.replaceAll(" ", "")) ??
              List.filled(6, '');
      final eval1 = marksArray[0] ?? '';
      final eval2 = marksArray[1] ?? '';

      if (eval1.toString().isEmpty && eval2.toString().isEmpty) {
        continue;
      }

      final average = ((double.tryParse(eval1.toString()) ?? 0) +
              (double.tryParse(eval2.toString()) ?? 0)) /
          2;
      if (average < minAverage) {
        minAverage = average;
      }
    }

    return minAverage == double.infinity ? 0 : minAverage;
  }

  double calculateMaxAverage(String subjectName) {
    double maxAverage = double.negativeInfinity;

    for (var student in students) {
      final marksArray =
          student.get<List<dynamic>>(subjectName.replaceAll(" ", "")) ??
              List.filled(6, '');
      final eval1 = marksArray[0] ?? '';
      final eval2 = marksArray[1] ?? '';

      if (eval1.toString().isEmpty && eval2.toString().isEmpty) {
        continue;
      }

      final average = ((double.tryParse(eval1.toString()) ?? 0) +
              (double.tryParse(eval2.toString()) ?? 0)) /
          2;
      if (average > maxAverage) {
        maxAverage = average;
      }
    }

    return maxAverage == double.negativeInfinity ? 0 : maxAverage;
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
                    child: ListView.separated(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                                student.get<String>('name')?.toUpperCase() ??
                                    ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              onPressed: () => generateReportCard(student),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        thickness: 1.5,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
