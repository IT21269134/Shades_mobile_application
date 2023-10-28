import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shades/features/query_mgt/querypage.dart';

class MyQuestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Questions'),
        backgroundColor: const Color(0xFF146C94),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('query')
            .where('userID', isEqualTo: getCurrentUserId())
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final queryDocuments = streamSnapshot.data?.docs;

          return ListView.builder(
            itemCount: queryDocuments?.length ?? 0,
            itemBuilder: (context, index) {
              final DocumentSnapshot documentSnapshot = queryDocuments![index];

              return Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(width: 3, color: Colors.black),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Row(
                          children: [
                            Image.asset(
                              'assets/query/query3.png',
                              width: 60,
                              height: 60,
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                documentSnapshot['queryName'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "- posted on : ${_formatDate(documentSnapshot['queryCode'].toString())} -",
                              style: TextStyle(
                                color: Color.fromARGB(201, 107, 107, 107),
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Tags: ${documentSnapshot['tags'].toString()}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 46, 126, 255),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ModuleDetailPage(
                                queryName:
                                    documentSnapshot['queryName'].toString(),
                                queryCode:
                                    documentSnapshot['queryCode'].toString(),
                                description:
                                    documentSnapshot['description'].toString(),
                                tags: documentSnapshot['tags'].toString(),
                              ),
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _updateQuestion(context, documentSnapshot);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _confirmDelete(context, documentSnapshot);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? '';
    return userId;
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.year}-${_formatNumber(parsedDate.month)}-${_formatNumber(parsedDate.day)} ${_formatNumber(parsedDate.hour)}:${_formatNumber(parsedDate.minute)}:${_formatNumber(parsedDate.second)}";
  }

  String _formatNumber(int number) {
    return number < 10 ? '0$number' : '$number';
  }

  void _updateQuestion(
      BuildContext context, DocumentSnapshot documentSnapshot) {
    TextEditingController updatedQueryNameController =
        TextEditingController(text: documentSnapshot['queryName'].toString());
    TextEditingController updatedDescriptionController =
        TextEditingController(text: documentSnapshot['description'].toString());
    TextEditingController updatedTagsController =
        TextEditingController(text: documentSnapshot['tags'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Question"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: updatedQueryNameController,
                maxLines: null, // Allows multiple lines
                decoration:
                    InputDecoration(labelText: "Enter Updated Query Name"),
              ),
              TextField(
                controller: updatedDescriptionController,
                maxLines: null,
                decoration:
                    InputDecoration(labelText: "Enter Updated Description"),
              ),
              TextField(
                controller: updatedTagsController,
                maxLines: null,
                decoration: InputDecoration(labelText: "Enter Updated Tags"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _performUpdate(
                  documentSnapshot,
                  updatedQueryNameController.text,
                  updatedDescriptionController.text,
                  updatedTagsController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _performUpdate(
    DocumentSnapshot documentSnapshot,
    String updatedQueryName,
    String updatedDescription,
    String updatedTags,
  ) {
    FirebaseFirestore.instance
        .collection('query')
        .doc(documentSnapshot.id)
        .update({
      'queryName': updatedQueryName,
      'description': updatedDescription,
      'tags': updatedTags,
    });
  }

  void _confirmDelete(BuildContext context, DocumentSnapshot documentSnapshot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this question?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteQuestion(documentSnapshot);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteQuestion(DocumentSnapshot documentSnapshot) {
    FirebaseFirestore.instance
        .collection('query')
        .doc(documentSnapshot.id)
        .delete();
  }
}
