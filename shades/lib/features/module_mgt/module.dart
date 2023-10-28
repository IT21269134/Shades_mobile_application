// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'modulepage.dart';

class Moduleoperations extends StatefulWidget {
  const Moduleoperations({Key? key});

  @override
  State<Moduleoperations> createState() => MywidgetState();
}

class MywidgetState extends State<Moduleoperations> {
  final TextEditingController _moduleNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ratingsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference _modules =
      FirebaseFirestore.instance.collection('modules');

  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;

    final String userId = user?.uid ?? '';
    return userId;
  }

  Future<String> getUserRole(String userId) async {
    final DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists && userSnapshot.data() != null) {
      final Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      return userData['role'] ?? '';
    } else {
      return '';
    }
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    double selectedRating = 0;

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Insert Module Details",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _moduleNameController,
                decoration: InputDecoration(
                  labelText: "Module Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _subjectCodeController,
                decoration: InputDecoration(
                  labelText: "Subject Code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Ratings:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RatingBar.builder(
                initialRating: selectedRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 30.0,
                itemBuilder: (context, _) => Image.asset(
                  'assets/module/star.png',
                  width: 30.0,
                  height: 30.0,
                ),
                onRatingUpdate: (rating) {
                  selectedRating = rating;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final String moduleName = _moduleNameController.text;
                  final String subjectCode = _subjectCodeController.text;
                  final String description = _descriptionController.text;
                  final String ratings = selectedRating.toString();

                  await _modules.add({
                    'moduleName': moduleName,
                    'subjectCode': subjectCode,
                    'description': description,
                    'Ratings': ratings,
                  });

                  _moduleNameController.clear();
                  _subjectCodeController.clear();
                  _descriptionController.clear();

                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 0, 0, 0),
                  minimumSize: Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  "Create",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    double selectedRating = 0;
    if (documentSnapshot != null) {
      _moduleNameController.text = documentSnapshot['moduleName'].toString();
      _subjectCodeController.text = documentSnapshot['subjectCode'].toString();
      _descriptionController.text = documentSnapshot['description'].toString();
      selectedRating = double.parse(documentSnapshot['Ratings'].toString());
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 10,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Update Module Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _moduleNameController,
                decoration: InputDecoration(
                  labelText: "Module Name",
                  border: OutlineInputBorder(),
                  filled: true,
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _subjectCodeController,
                decoration: InputDecoration(
                  labelText: "Subject Code",
                  border: OutlineInputBorder(),
                  filled: true,
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  filled: true,
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              SizedBox(height: 12),
              Text("Ratings:"),
              RatingBar.builder(
                initialRating: selectedRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 30.0,
                itemBuilder: (context, _) => Image.asset(
                  'assets/module/star.png',
                  width: 30.0,
                  height: 30.0,
                  color: Color.fromARGB(255, 248, 162, 3),
                ),
                onRatingUpdate: (rating) {
                  selectedRating = rating;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String moduleName = _moduleNameController.text;
                  final String subjectCode = _subjectCodeController.text;
                  final String description = _descriptionController.text;
                  final String ratings = selectedRating.toString();

                  if (documentSnapshot != null) {
                    // Update an existing document
                    await _modules.doc(documentSnapshot.id).update({
                      'moduleName': moduleName,
                      'subjectCode': subjectCode,
                      'description': description,
                      'Ratings': ratings,
                    });
                  } else {
                    // Create a new document
                    await _modules.add({
                      'moduleName': moduleName,
                      'subjectCode': subjectCode,
                      'description': description,
                      'Ratings': ratings,
                    });
                  }

                  _moduleNameController.clear();
                  _subjectCodeController.clear();
                  _descriptionController.clear();

                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 0, 0, 0),
                  minimumSize: Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  documentSnapshot != null ? "Update" : "Create",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete([DocumentSnapshot? documentSnapshot]) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/module/shrug.png',
                width: 140,
                height: 140,
              ),
              SizedBox(height: 10),
              Text(
                'Are you sure you want to delete this module?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color.fromARGB(
                      255, 0, 0, 0), // You can customize the color here
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    const Color.fromARGB(255, 243, 82, 70), // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () async {
                await _modules.doc(documentSnapshot!.id).delete();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Color.fromARGB(255, 235, 238, 240),
        leading: Image.asset('assets/module/logo.png', width: 15, height: 15),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.search,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Modules',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.clear_all,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _modules.snapshots().map((querySnapshot) {
          return querySnapshot.docs.where((doc) {
            final moduleName = doc['moduleName'].toString().toLowerCase();
            final searchQuery = _searchController.text.toLowerCase();
            return moduleName.contains(searchQuery);
          }).toList();
        }),
        builder: (context,
            AsyncSnapshot<List<QueryDocumentSnapshot>> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data![index];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ModuleDetailPage(
                          moduleName: documentSnapshot['moduleName'].toString(),
                          subjectCode:
                              documentSnapshot['subjectCode'].toString(),
                          description:
                              documentSnapshot['description'].toString(),
                          ratings: documentSnapshot['Ratings'].toString(),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Image.asset(
                              'assets/module/read.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                documentSnapshot['moduleName'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "Ratings : ",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  RatingBar.builder(
                                    initialRating: 3,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemSize: 15,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Image.asset(
                                      'assets/module/star.png',
                                      width: 15,
                                      height: 14,
                                    ),
                                    onRatingUpdate: (rating) {},
                                  )
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Subject Code: ${documentSnapshot['subjectCode'].toString()}",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                documentSnapshot['description'],
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: getUserRole(getCurrentUserId()),
                          builder:
                              (context, AsyncSnapshot<String> roleSnapshot) {
                            if (roleSnapshot.connectionState ==
                                ConnectionState.done) {
                              final String userRole = roleSnapshot.data ?? '';

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (userRole == 'leader')
                                    IconButton(
                                      icon: Icon(Icons.remove_circle),
                                      onPressed: () =>
                                          _delete(documentSnapshot),
                                    ),
                                  if (userRole == 'leader')
                                    IconButton(
                                      icon: Icon(Icons.change_circle),
                                      onPressed: () =>
                                          _update(documentSnapshot),
                                    ),
                                ],
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FutureBuilder(
        future: getUserRole(getCurrentUserId()),
        builder: (context, AsyncSnapshot<String> roleSnapshot) {
          if (roleSnapshot.connectionState == ConnectionState.done) {
            final String userRole = roleSnapshot.data ?? '';

            if (userRole == 'leader') {
              return FloatingActionButton(
                onPressed: () => _create(),
                backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                child: Image.asset('assets/module/plus.png'),
              );
            }
          }
          return Container();
        },
      ),
    );
  }
}
