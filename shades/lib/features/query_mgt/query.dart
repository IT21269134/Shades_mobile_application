import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'querypage.dart';

class QueryOperations extends StatefulWidget {
  const QueryOperations({Key? key});

  @override
  State<QueryOperations> createState() => MyWidgetState();
}

class MyWidgetState extends State<QueryOperations> {
  late TextEditingController _queryNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  late TextEditingController _searchController;

  final CollectionReference _queries =
      FirebaseFirestore.instance.collection('query');

  @override
  void initState() {
    super.initState();
    _queryNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
    _searchController = TextEditingController();
  }

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
                  "Insert Query Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _queryNameController,
                decoration: InputDecoration(
                  labelText: "Query Name",
                  border: OutlineInputBorder(),
                  filled: true,
                  prefixIcon: Icon(Icons.search),
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
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: "Tags",
                  border: OutlineInputBorder(),
                  filled: true,
                  prefixIcon: Icon(Icons.local_offer),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final String queryName = _queryNameController.text;
                      final String description = _descriptionController.text;
                      final String tags = _tagsController.text;

                      final DateTime dateTimeNow = DateTime.now();
                      final String timeStamp =
                          "${dateTimeNow.year}-${_formatNumber(dateTimeNow.month)}-${_formatNumber(dateTimeNow.day)} ${_formatNumber(dateTimeNow.hour)}:${_formatNumber(dateTimeNow.minute)}:${_formatNumber(dateTimeNow.second)}";

                      final User? user = FirebaseAuth.instance.currentUser;
                      final String userId = user?.uid ?? '';

                      await _queries.add({
                        'queryName': queryName,
                        'queryCode': timeStamp,
                        'description': description,
                        'tags': tags,
                        'userID': userId,
                      });

                      _queryNameController.clear();
                      _descriptionController.clear();
                      _tagsController.clear();

                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF146C94),
                    ),
                    child: Text("Create", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _queryNameController.text = documentSnapshot['queryName'].toString();
      _descriptionController.text = documentSnapshot['description'].toString();
      _tagsController.text = documentSnapshot['tags'].toString();
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
                  "Update Query Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _queryNameController,
                decoration: InputDecoration(
                  labelText: "Query Name",
                  border: OutlineInputBorder(),
                  filled: true,
                  prefixIcon: Icon(Icons.search),
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
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: "Tags",
                  border: OutlineInputBorder(),
                  filled: true,
                  prefixIcon: Icon(Icons.local_offer),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final String queryName = _queryNameController.text;
                      final String description = _descriptionController.text;
                      final String tags = _tagsController.text;

                      await _queries.doc(documentSnapshot!.id).update({
                        'queryName': queryName,
                        'description': description,
                        'tags': tags,
                      });

                      _queryNameController.clear();
                      _descriptionController.clear();
                      _tagsController.clear();

                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF146C94),
                    ),
                    child: Text("Update", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
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
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.warning,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                'Confirm Deletion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Are you sure you want to delete this query?',
                style: TextStyle(
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
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _queries.doc(documentSnapshot!.id).delete();
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

  String _formatNumber(int number) {
    return number < 10 ? '0$number' : '$number';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: ListTile(
                leading: Image.asset(
                  'assets/module/logo.png',
                  width: 30,
                  height: 30,
                ),
                title: Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: ' Search Query...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _queries.snapshots().map((querySnapshot) {
                return querySnapshot.docs.where((doc) {
                  final queryName = doc['queryName'].toString().toLowerCase();
                  final searchQuery = _searchController.text.toLowerCase();
                  return queryName.contains(searchQuery);
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

                      final User? user = FirebaseAuth.instance.currentUser;
                      final String currentUserId = user?.uid ?? '';

                      return FutureBuilder(
                        future: getUserRole(currentUserId),
                        builder: (context, AsyncSnapshot<String> roleSnapshot) {
                          if (roleSnapshot.connectionState ==
                              ConnectionState.done) {
                            final String userRole = roleSnapshot.data ?? '';

                            final bool canEditDelete =
                                documentSnapshot['userID'] == currentUserId ||
                                    userRole == 'leader';

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
                                  side:
                                      BorderSide(width: 3, color: Colors.black),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  leading: Image.asset(
                                    'assets/query/query2.png',
                                    width: 60,
                                    height: 60,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        documentSnapshot['queryName']
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                      ),
                                      FutureBuilder(
                                        future: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(documentSnapshot['userID'])
                                            .get(),
                                        builder: (context,
                                            AsyncSnapshot<DocumentSnapshot>
                                                userSnapshot) {
                                          if (userSnapshot.hasData &&
                                              userSnapshot.data != null) {
                                            final Map<String, dynamic>
                                                userData =
                                                userSnapshot.data!.data()
                                                    as Map<String, dynamic>;
                                            final String username =
                                                userData['username'] ?? '';
                                            return Text(
                                              "@ $username",
                                              style: TextStyle(
                                                color: Color(0xFF146C94),
                                                fontSize: 14,
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                      SizedBox(height: 30),
                                      Text(
                                        "${documentSnapshot['tags'].toString()}",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 122, 143, 247),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "- posted on : ${_formatDate(documentSnapshot['queryCode'].toString())} -",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              201, 107, 107, 107),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: canEditDelete
                                      ? PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert,
                                              size: 30,
                                              color: Color(0xFF146C94)),
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: 'edit',
                                              child: ListTile(
                                                title: Text('Edit',
                                                    style: TextStyle(
                                                        fontSize: 20)),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'delete',
                                              child: ListTile(
                                                title: Text('Delete',
                                                    style: TextStyle(
                                                        fontSize: 20)),
                                              ),
                                            ),
                                          ],
                                          onSelected: (String value) {
                                            if (value == 'edit') {
                                              _update(documentSnapshot);
                                            } else if (value == 'delete') {
                                              _delete(documentSnapshot);
                                            }
                                          },
                                        )
                                      : null,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ModuleDetailPage(
                                          queryName:
                                              documentSnapshot['queryName']
                                                  .toString(),
                                          queryCode:
                                              documentSnapshot['queryCode']
                                                  .toString(),
                                          description:
                                              documentSnapshot['description']
                                                  .toString(),
                                          tags: documentSnapshot['tags']
                                              .toString(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        child: Image.asset('assets/module/quest.png'),
      ),
    );
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.year}-${_formatNumber(parsedDate.month)}-${_formatNumber(parsedDate.day)} ${_formatNumber(parsedDate.hour)}:${_formatNumber(parsedDate.minute)}:${_formatNumber(parsedDate.second)}";
  }
}
