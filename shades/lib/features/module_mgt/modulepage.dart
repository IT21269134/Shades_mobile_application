import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ModuleDetailPage extends StatefulWidget {
  final String moduleName;
  final String subjectCode;
  final String description;
  final String ratings;

  ModuleDetailPage({
    required this.moduleName,
    required this.subjectCode,
    required this.description,
    required this.ratings,
  });

  @override
  _ModuleDetailPageState createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  bool isAddingReview = false;

  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? '';
    return userId;
  }

  Future<String> getCurrentUsername() async {
    final String userId = getCurrentUserId();
    if (userId.isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final String username = userDoc['username'];
      return username;
    }
    return '';
  }

  void showAdvertisementPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'assets/module/ads.jpg',
                      width: 400,
                      height: 400,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "Looking forward to studying together and exploring the depths of knowledge like the sea ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
              Positioned(
                right: 0.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 12.0,
                      backgroundColor: const Color.fromARGB(255, 124, 123, 123),
                      child: Icon(
                        Icons.cancel,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double ratingValue = double.tryParse(widget.ratings) ?? 0.0;
    final int filledStars = (ratingValue / 5 * 5).round();
    // ignore: unused_local_variable
    final int emptyStars = 5 - filledStars;

    final TextEditingController reviewController = TextEditingController();
    final TextEditingController ratingController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 0, 0, 0)),
        title: Row(
          children: [
            Image.asset(
              'assets/module/logo.png',
              width: 25,
            ),
            SizedBox(width: 10),
            Text(
              widget.moduleName,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              margin: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/module/gg.gif',
                      width: 500,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Module : ${widget.moduleName}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Subject Code: ${widget.subjectCode}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Description: ${widget.description}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Ratings: ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              WidgetSpan(
                                child: Image.asset('assets/module/chart.png'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 19),
                        Row(
                          children: [
                            for (int i = 0; i < filledStars; i++)
                              Image.asset('assets/module/star.png',
                                  width: 30, height: 30),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Average Ratings - $ratingValue',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Reviews:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('module_reviews')
                  .where('subjectCode', isEqualTo: widget.subjectCode)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No reviews available.');
                }
                return Column(
                  children: snapshot.data!.docs.map((reviewData) {
                    final reviewId = reviewData.id;
                    final userName = reviewData['userName'];
                    final rating = reviewData['rating'];
                    final comment = reviewData['reviews'];
                    final likes = reviewData['likes'] ?? 0;
                    final dislikes = reviewData['dislikes'] ?? 0;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Card(
                        elevation: 4,
                        color: Color.fromARGB(255, 238, 237, 237),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('Review by $userName'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/module/favourite.png',
                                        width: 15.0,
                                        height: 15.0,
                                      ),
                                      Text(' Rating: $rating'),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text('Reviews: $comment'),
                                  Row(
                                    children: [
                                      InkWell(
                                        child: Image.asset(
                                          'assets/module/heart.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                        onTap: () {
                                          FirebaseFirestore.instance
                                              .collection('module_reviews')
                                              .doc(reviewId)
                                              .update({
                                            'likes': likes + 1,
                                          });
                                        },
                                      ),
                                      Text(' Likes: $likes'),
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/module/broken-heart.png',
                                          width: 19,
                                          height: 16,
                                        ),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('module_reviews')
                                              .doc(reviewId)
                                              .update({
                                            'dislikes': dislikes + 1,
                                          });
                                        },
                                      ),
                                      Text('Dislikes: $dislikes'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () {
                setState(() {
                  isAddingReview = !isAddingReview;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(20, 108, 148, 1),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isAddingReview,
              child: Card(
                elevation: 4,
                color: Colors.white,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: reviewController,
                        decoration: InputDecoration(
                          labelText: 'Review',
                          prefixIcon: Icon(Icons.comment),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: ratingController,
                        decoration: InputDecoration(
                          labelText: 'Rating (1-5)',
                          prefixIcon: Icon(Icons.star),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final String review = reviewController.text;
                          final double rating =
                              double.tryParse(ratingController.text) ?? 0.0;
                          final String username = await getCurrentUsername();

                          if (review.isNotEmpty && rating >= 1 && rating <= 5) {
                            FirebaseFirestore.instance
                                .collection('module_reviews')
                                .add({
                              'moduleName': widget.moduleName,
                              'subjectCode': widget.subjectCode,
                              'userName': username,
                              'rating': rating,
                              'reviews': review,
                              'likes': 0,
                              'dislikes': 0,
                            });

                            reviewController.clear();
                            ratingController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Please enter a valid review and rating.'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 235, 235, 235),
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(20, 108, 148, 1),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAdvertisementPopup(context); // Show the advertisement popup
        },
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        child: Icon(Icons.card_giftcard),
      ),
    );
  }
}
