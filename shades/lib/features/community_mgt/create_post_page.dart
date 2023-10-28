import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommunityOperations(),
    );
  }
}

class CommunityOperations extends StatefulWidget {
  @override
  _CommunityOperationsState createState() => _CommunityOperationsState();
}

class _CommunityOperationsState extends State<CommunityOperations> {
  Set<String> likedPosts = Set<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Posts'),
        backgroundColor: Color(0xFF146C94),
        centerTitle: true,
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('community_collection')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            var communityData = snapshot.data?.docs ?? [];
            List<Widget> communityWidgets = [];

            for (var data in communityData) {
              var postId = data.id;
              var comName = data['com_name'];
              var title = data['title'];
              var description = data['description'];
              var hashtags = data['hashtags'];

              bool isLiked = likedPosts.contains(postId);

              communityWidgets.add(
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFF146C94),
                        width: 3.0,
                      ),
                      color: Color(0xFFF6F1F1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$comName',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          '$title',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$description',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$hashtags',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (isLiked) {
                                    likedPosts.remove(postId);
                                  } else {
                                    likedPosts.add(postId);
                                  }
                                });
                              },
                              child: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 30,
                                color: isLiked ? Colors.red : Colors.black,
                              ),
                            ),
                            SizedBox(width: 8),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Dummy Image Widget
                        Image.asset(
                          'assets/community/img1.jpg', // Path to img1.jpg
                          width: double
                              .infinity, // Set the width as per your requirement
                          height: 200, // Set the height as per your requirement
                          fit: BoxFit.cover, // BoxFit property for image fit
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: communityWidgets,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF146C94),
      ),
    );
  }
}

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _comNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  void _createPost() {
    String comName = _comNameController.text;
    String title = _titleController.text;
    String description = _descriptionController.text;
    String hashtags = _tagsController.text;

    if (comName.isNotEmpty &&
        title.isNotEmpty &&
        description.isNotEmpty &&
        hashtags.isNotEmpty) {
      FirebaseFirestore.instance.collection('community_collection').add({
        'com_name': comName,
        'title': title,
        'description': description,
        'hashtags': hashtags,
      }).then((value) {
        print('Post added: $value');
        Navigator.of(context).pop();
      }).catchError((error) => print('Failed to add post: $error'));
    } else {
      print('All fields are required.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Community Post'),
        backgroundColor: Color(0xFF146C94),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Community Name',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _comNameController,
                  decoration: InputDecoration(
                    labelText: 'Enter Community Name',
                    hintText: 'Community Name',
                    hintStyle: TextStyle(fontSize: 16),
                    fillColor: Color(0xFFF6F1F1), // Input field color
                    filled: true,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Post Title',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Enter Post Title',
                    hintText: 'Post Title',
                    hintStyle: TextStyle(fontSize: 16),
                    fillColor: Color(0xFFF6F1F1), // Input field color
                    filled: true,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Description',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: null,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Enter Description',
                    hintText: 'Description',
                    hintStyle: TextStyle(fontSize: 16),
                    fillColor: Color(0xFFF6F1F1), // Input field color
                    filled: true,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Hashtags',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Enter Hashtags',
                    hintText: 'Hashtags',
                    hintStyle: TextStyle(fontSize: 16),
                    fillColor: Color(0xFFF6F1F1), // Input field color
                    filled: true,
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _createPost,
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF19A7CE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Create',
                              style: TextStyle(
                                fontSize: 22,
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
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
