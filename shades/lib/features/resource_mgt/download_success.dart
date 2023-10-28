import 'package:flutter/material.dart';
import 'package:shades/features/resource_mgt/view_all_pdf.dart';

class DownloadSuccess extends StatelessWidget {
  const DownloadSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Download Resources'),
          backgroundColor: const Color.fromRGBO(20, 108, 148, 1.000),
        ),
        body: Center(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 60, bottom: 60, left: 20, right: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: const Color.fromARGB(255, 30, 180, 53),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text("Download Successful",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 15, 156, 20))),
                  ),
                  const SizedBox(height: 10),
                  Image.asset('assets/resource/tick2.jpg',
                      height: 300, width: 300),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 77, 163, 200),
                      minimumSize: const Size(120, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const Scaffold(body: ViewPdfForm()),
                        ),
                      );
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
