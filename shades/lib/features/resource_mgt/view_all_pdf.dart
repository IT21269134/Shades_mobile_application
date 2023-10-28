import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shades/features/resource_mgt/download_success.dart';
import 'package:shades/features/resource_mgt/resource.dart';

class ViewPdfForm extends StatefulWidget {
  final String? fileName;

  const ViewPdfForm({Key? key, this.fileName}) : super(key: key);

  @override
  State<ViewPdfForm> createState() => _ViewPdfFormState();
}

class _ViewPdfFormState extends State<ViewPdfForm> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> pdfList = [];
  bool downloading = false;
  bool showFirstPdf = false;

  void getAllPdf() async {
    final allPdfs = await _firebaseFirestore.collection("resources_pdfs").get();
    pdfList = allPdfs.docs.map((e) => e.data()).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getAllPdf();
    showFirstPdfDelayed();
  }

  void showFirstPdfDelayed() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      showFirstPdf = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(20, 108, 148, 1.000),
        title: const Text('View Resource PDF'),
      ),
      body: Column(
        children: [
          if (widget.fileName != null && pdfList.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Your PDF is Ready...',
                style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(20, 108, 148, 1.000),
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            if (showFirstPdf) ...[
              Center(
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  height: 200,
                  width: 300,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: Color.fromARGB(151, 186, 187, 189),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(
                              pdfurl: pdfList[getIndexForFileName()]['url'],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: buildCardContents(getIndexForFileName()),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 80),
              const CircularProgressIndicator(),
              const SizedBox(height: 80),
            ],
            const Text('---------------- Similar PDFs ----------------',
                style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(20, 108, 148, 1.000),
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            buildGrid(),
          ],
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Start download animation when the button is clicked
      //     downloadAndOpenPdf(pdfList[getIndexForFileName()]['url'],
      //         pdfList[getIndexForFileName()]['fileName']);
      //   },
      //   backgroundColor: const Color.fromRGBO(20, 108, 148, 1.000),
      //   child: const Icon(Icons.cloud_download_sharp, size: 35),
      // ),
    );
  }

  Widget buildGrid() {
    List<Widget> gridCards = [];
    for (int index = 0; index < pdfList.length; index++) {
      if (widget.fileName == null ||
          pdfList[index]['fileName'] != widget.fileName) {
        gridCards.add(
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(
                    pdfurl: pdfList[index]['url'],
                  ),
                ),
              );
            },
            child: SizedBox(
              height: 200,
              width: 300,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Color.fromARGB(151, 186, 187, 189),
                    width: 1,
                  ),
                ),
                child: buildCardContents(index),
              ),
            ),
          ),
        );
      }
    }
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        children: gridCards,
      ),
    );
  }

  int getIndexForFileName() {
    for (int i = 0; i < pdfList.length; i++) {
      if (pdfList[i]['fileName'] == widget.fileName) {
        return i;
      }
    }
    return 0;
  }

  Widget buildCardContents(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset(
          "assets/resource/PDF.jpg",
          height: 70,
          width: 100,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 5),
          child: Center(
            child: Text(
              pdfList[index]['fileName'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.cloud_download_sharp,
              color: Color.fromARGB(255, 54, 154, 99), size: 40),
          onPressed: () {
            // Start download animation when the button is clicked
            downloadAndOpenPdf(
                pdfList[index]['url'], pdfList[index]['fileName']);
          },
        ),
      ],
    );
  }

  void downloadAndOpenPdf(String pdfUrl, String fileName) async {
    try {
      setState(() {
        downloading = true;
      });

      // Replace with loading popup
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            backgroundColor: Color.fromARGB(157, 31, 34, 35),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 6,
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                ),
                SizedBox(height: 16),
                Text(
                  'Downloading...',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      );

      var response = await http.get(Uri.parse(pdfUrl));

      if (response.statusCode == 200) {
        var time = DateTime.now().millisecondsSinceEpoch;
        var path = '/storage/emulated/0/Download/$fileName-$time.pdf';
        var file = File(path);
        await file.writeAsBytes(response.bodyBytes);
        print('File downloaded to: $path');

        // Replace with success popup
        await Future.delayed(
            const Duration(seconds: 1)); // Simulating download time
        Navigator.of(context).pop(); // Close loading popup
        _showSuccessPopup();
      } else {
        print(
            'Failed to download the file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        downloading = false;
      });
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Color.fromARGB(157, 31, 34, 35),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Color.fromARGB(255, 12, 223, 19),
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'File downloaded',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
    // Close success popup after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String pdfurl;
  const PdfViewerScreen({Key? key, required this.pdfurl}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PDFDocument? document;

  void initialisePdf() async {
    document = await PDFDocument.fromURL(widget.pdfurl);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialisePdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: document != null
          ? PDFViewer(
              document: document!,
            )
          : const Center(
              child: CircularProgressIndicator(
                strokeWidth: 6,
                backgroundColor: Colors.grey,
              ),
            ),
    );
  }
}
