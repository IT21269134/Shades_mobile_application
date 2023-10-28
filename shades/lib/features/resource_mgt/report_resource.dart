import 'package:flutter/material.dart';
import 'package:shades/features/resource_mgt/resource.dart';
import 'package:shades/features/resource_mgt/report_success.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference resourceReports =
    FirebaseFirestore.instance.collection('resourceReports');

class ResourceReportForm extends StatefulWidget {
  const ResourceReportForm({super.key});

  @override
  _ResourceReportFormState createState() => _ResourceReportFormState();
}

class _ResourceReportFormState extends State<ResourceReportForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _resourceTitle = '';
  String _reason = '';
  String _selectedLevel = 'Low';

  final List<String> _levels = ['Low', 'Medium', 'Severe'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(20, 108, 148, 1.000),
        // title: const Text('Report Resource'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Report Resource ',
                    style: TextStyle(
                      color: Color.fromRGBO(20, 108, 148, 1.000),
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Resource Title',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    hintText: 'Title',
                  ),
                  onSaved: (value) {
                    _resourceTitle = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Mention the reason',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Reason',
                  ),
                  maxLines: 4,
                  onSaved: (value) {
                    _reason = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a reason';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Level',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0)),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select Level',
                  ),
                  value: _selectedLevel,
                  items: _levels.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value ?? 'Low';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a level';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(25, 167, 206, 1),
                        minimumSize: const Size(120, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      // onPressed: () {
                      //   if (_formKey.currentState!.validate()) {
                      //     _formKey.currentState!.save();
                      // You can save the data or perform any action here.
                      // For example, print the data.
                      // print('Resource Title: $_resourceTitle');
                      // print('Reason: $_reason');
                      // print('Selected Level: $_selectedLevel');
                      //   }
                      // },
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          try {
                            // Save the data to Firebase
                            resourceReports.add({
                              'resourceTitle': _resourceTitle,
                              'reason': _reason,
                              'level': _selectedLevel,
                            });
                            _showSuccessPopup();
                          } catch (e) {
                            // Handle errors here (e.g., show an error message)
                            print('Error: $e');
                          }
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(175, 211, 226, 1),
                          minimumSize: const Size(120, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () {
                          // Add cancel logic here.
                          Navigator.pop(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Scaffold(
                                body: Resourceoperations(),
                              ),
                            ),
                          ); // This line will navigate back to the previous screen.
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                'Report Submitted',
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
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      // Reset the form
      _formKey.currentState?.reset();
      // You can also reset the selectedLevel to the initial value if needed.
      setState(() {
        _selectedLevel = 'Low';
      });
      // Navigate to the ResourceOperations page
      Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Resourceoperations(),
          ),
        ),
      );
    });
  }
}
