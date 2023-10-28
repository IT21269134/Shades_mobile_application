import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'query_report.dart';

class ModuleDetailPage extends StatefulWidget {
  final String queryName;
  final String queryCode;
  final String description;
  final String tags;

  ModuleDetailPage({
    required this.queryName,
    required this.queryCode,
    required this.description,
    required this.tags,
  });

  @override
  _ModuleDetailPageState createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage>
    with TickerProviderStateMixin {
  late TextEditingController answerController;
  late List<Map<String, dynamic>> answers;
  bool showAddAnswerSection = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late String userRole;
  late Map<String, int> reportedIssuesCount;

  @override
  void initState() {
    super.initState();
    answerController = TextEditingController();
    answers = [];
    reportedIssuesCount = {};
    _getAndSortAnswers();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    userRole = '';
    _getUserRole();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getUserRole() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? '';
    final DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists && userSnapshot.data() != null) {
      final Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      userRole = userData['role'] ?? '';
    } else {
      userRole = '';
    }
  }

  Future<void> _getReportedIssuesCount() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('query_answer_reports')
        .get();

    reportedIssuesCount.clear();

    snapshot.docs.forEach((doc) {
      final answerId = doc['answerId'];
      reportedIssuesCount[answerId] = (reportedIssuesCount[answerId] ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Query Detail',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF146C94),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/query/test55.gif',
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 120,
                  left: 2,
                  right: 2,
                  child: Card(
                    elevation: 8,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.queryName}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'posted on: ${widget.queryCode}\n',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              Text(
                                '${widget.description}\n\n',
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                '[# ${widget.tags}]',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: !showAddAnswerSection,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showAddAnswerSection = true;
                      });
                      _animationController.forward();
                    },
                    child: Text(
                      'Reply',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF146C94)),
                      minimumSize: MaterialStateProperty.all(Size(120, 40)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: Color(0xFF146C94)), // Border color
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: showAddAnswerSection,
              child: FadeTransition(
                opacity: _animation,
                child: Card(
                  elevation: 4,
                  color: Colors.white,
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: answerController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Answer',
                            prefixIcon: Icon(Icons.comment),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: () {
                            final String answer = answerController.text;

                            if (answer.isNotEmpty) {
                              _submitAnswer(answer);
                              answerController.clear();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a valid answer.'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Submit Answer',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xFF146C94)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Answers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildAnswers(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswers() {
    if (answers.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 50),
            Text(
              'No answers',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<void>(
      future: _getReportedIssuesCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: answers.map((answerData) {
              final answerId = answerData['answerId'];
              final userID = answerData['userID'];
              final displayUserID =
                  userID.length > 6 ? userID.substring(0, 6) : userID;
              final answer = answerData['answer'];
              final likes = answerData['likes'] ?? 0;
              final dislikes = answerData['dislikes'] ?? 0;
              final hasIssues = reportedIssuesCount.containsKey(answerId) &&
                  reportedIssuesCount[answerId]! > 2;

              return Card(
                key: ValueKey<String>(answerId),
                elevation: 4,
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black, width: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        '$answer',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(
                                    userID) // Assuming userID is accessible in this context
                                .get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                              if (userSnapshot.hasData &&
                                  userSnapshot.data != null) {
                                final Map<String, dynamic> userData =
                                    userSnapshot.data!.data()
                                        as Map<String, dynamic>;
                                final String username =
                                    userData['username'] ?? '';
                                return Text(
                                  "@ $username", // Add '@' in front of the username
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
                          SizedBox(height: 20),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _updateLikes(answerId);
                                },
                                child: Image.asset(
                                  'assets/query/like.png',
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                              Text(
                                '  $likes       ',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF146C94)),
                              ),
                              IconButton(
                                icon: Icon(Icons.flag_circle_rounded,
                                    size: 32,
                                    color: Color.fromARGB(255, 255, 122, 122)),
                                onPressed: () {
                                  _reportAnswer(answerId);
                                },
                              ),
                              Text(
                                'Report',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF146C94)),
                              ),
                            ],
                          ),
                          if (hasIssues)
                            Column(
                              children: [
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.red),
                                    Text(
                                      '  This answer has some issues ',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                        ],
                      ),
                      trailing: _buildDeleteButton(userID, answerId),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget? _buildDeleteButton(String answerUserID, String answerId) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String currentUserId = user?.uid ?? '';
    final bool canDelete =
        answerUserID == currentUserId || userRole == 'leader';

    return canDelete
        ? IconButton(
            icon:
                Icon(Icons.delete_forever_rounded, color: Colors.red, size: 30),
            onPressed: () => _deleteAnswer(answerId),
          )
        : null;
  }

  void _deleteAnswer(String answerId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Answer'),
          content: Text('Are you sure you want to delete this answer?'),
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
                await FirebaseFirestore.instance
                    .collection('query_answers')
                    .doc(answerId)
                    .delete();
                Navigator.of(context).pop();
                _getAndSortAnswers(); // Refresh the answers after deletion
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

  Future<void> _getAndSortAnswers() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('query_answers')
        .where('queryCode', isEqualTo: widget.queryCode)
        .get();

    setState(() {
      answers = snapshot.docs.map((doc) {
        return {
          'answerId': doc.id,
          'userID': doc['userID'],
          'answer': doc['answer'],
          'likes': doc['likes'] ?? 0,
          'dislikes': doc['dislikes'] ?? 0,
        };
      }).toList();

      answers.sort((a, b) => (b['likes'] as int).compareTo(a['likes'] as int));
    });
  }

  void _updateLikes(String answerId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? 'Anonymous';

    final likesSnapshot = await FirebaseFirestore.instance
        .collection('query_answer_likes')
        .where('answerId', isEqualTo: answerId)
        .where('userID', isEqualTo: currentUserId)
        .get();

    if (likesSnapshot.docs.isNotEmpty) {
      // Remove the entry from query_answer_likes
      await likesSnapshot.docs.first.reference.delete();

      // Decrease 'likes' count in query_answers
      await FirebaseFirestore.instance
          .collection('query_answers')
          .doc(answerId)
          .update({'likes': FieldValue.increment(-1)});
    } else {
      // Add entry to query_answer_likes
      await FirebaseFirestore.instance.collection('query_answer_likes').add({
        'answerId': answerId,
        'userID': currentUserId,
      });

      // Increase 'likes' count in query_answers
      await FirebaseFirestore.instance
          .collection('query_answers')
          .doc(answerId)
          .update({'likes': FieldValue.increment(1)});
    }

    _getAndSortAnswers();
  }

  void _reportAnswer(String answerId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QueryReportPage(answerId: answerId),
      ),
    );

    // Refresh data after returning from QueryReportPage
    _getAndSortAnswers();
  }

  void _submitAnswer(String answer) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid ?? 'Anonymous';

    await FirebaseFirestore.instance.collection('query_answers').add({
      'queryName': widget.queryName,
      'queryCode': widget.queryCode,
      'userID': userId,
      'answer': answer,
      'likes': 0,
      'dislikes': 0,
    });

    _getAndSortAnswers();
  }
}
