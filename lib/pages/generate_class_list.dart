import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:html' as html;
import 'package:printing/printing.dart';

class GenerateClassListScreen extends StatefulWidget {
  const GenerateClassListScreen({super.key});

  @override
  _GenerateClassListScreenState createState() =>
      _GenerateClassListScreenState();
}

class _GenerateClassListScreenState extends State<GenerateClassListScreen> {
  String? selectedClass;
  List<ParseObject> students = [];
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchStudents() async {
    if (selectedClass == null) return;

    setState(() {
      isLoading = true;
    });

    final studentQuery = QueryBuilder<ParseObject>(
        ParseObject(selectedClass!.replaceAll(" ", "")))
      ..orderByAscending('name');

    final studentResponse = await studentQuery.query();

    if (studentResponse.success && studentResponse.results != null) {
      setState(() {
        students = studentResponse.results!.cast<ParseObject>();
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

  Future<void> downloadPdfWeb(Uint8List pdfBytes, String fileName) async {
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = '$fileName.pdf';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
  }

  Future<void> generateClassList() async {
    final pdf = pw.Document();

    Uint8List imageBytes = await loadImage();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
        build: (pw.Context context) => [
          pw.Column(
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
                          width: 100, height: 100),
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
              pw.SizedBox(height: 20),
              pw.Center(
                  child: pw.Column(children: [
                pw.SizedBox(height: 5),
                pw.Text(('Legendary Dice College Bangangte').toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue)),
                pw.SizedBox(height: 5),
                pw.Text('Class List'.toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('School Year: 2024/2025',
                    style: const pw.TextStyle(fontSize: 14)),
              ])),
              pw.SizedBox(height: 20),
              pw.Text('Class: ${selectedClass ?? ''}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'No.',
                  'Name',
                  'Eva. 1',
                  'Eva. 2',
                  'Eva. 3',
                  'Eva. 4',
                  'Eva. 5',
                  'Eva. 6'
                ],
                headerStyle:
                    pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                data: students.map((student) {
                  return [
                    students.indexOf(student).toString(),
                    student.get<String>('name')?.toUpperCase() ?? '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    ''
                  ];
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );

    final Uint8List pdfBytes = await pdf.save();

    if (kIsWeb) {
      await downloadPdfWeb(pdfBytes, '${selectedClass}_Class_List');
    } else {
      await Printing.layoutPdf(
        name: '${selectedClass}_Class_List.pdf',
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Class List'),
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
                  fetchStudents();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: generateClassList,
                    child: const Text('Generate Class List'),
                  ),
          ],
        ),
      ),
    );
  }
}
