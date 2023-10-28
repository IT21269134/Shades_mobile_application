import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCommunityPost extends StatefulWidget {
  final String postId;

  UpdateCommunityPost({required this.postId});

  @override
  _UpdateCommunityPostState createState() => _UpdateCommunityPostState();
}

class _UpdateCommunityPostState extends State<UpdateCommunityPost> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _hashtagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  void _fetchPostData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('community_collection')
        .doc(widget.postId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _titleController.text = data['title'];
        _descriptionController.text = data['description'];
        _hashtagsController.text = data['hashtags'];
      });
    }
  }

  void _updatePost() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('community_collection')
          .doc(widget.postId)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'hashtags': _hashtagsController.text,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Community Post'),
        backgroundColor: Color(0xFF146C94), // Top nav bar color
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            elevation: 8.0,
            shadowColor: Color(0xFF146C94), // Shadow color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title', // Label Title for Title Field
                        labelStyle: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        fillColor: Color(0xFFF6F1F1), // User input field color
                        filled: true,
                      ),
                      style: TextStyle(fontSize: 20),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: 120, // Adjusted height according to the form
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText:
                              'Description', // Label Title for Description Field
                          labelStyle: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),

                          fillColor:
                              Color(0xFFF6F1F1), // User input field color
                          filled: true,
                        ),
                        style: TextStyle(fontSize: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _hashtagsController,
                      decoration: InputDecoration(
                        labelText:
                            'Hash Tags', // Label Title for Hash Tags Field
                        labelStyle: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        fillColor: Color(0xFFF6F1F1), // User input field color
                        filled: true,
                      ),
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Container(
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _updatePost,
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF19A7CE),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                              ),
                              child: Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFFAFD3E2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
