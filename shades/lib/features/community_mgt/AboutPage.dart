import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: const Color(0xFF146C94),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '"Shades" is a cutting-edge mobile application meticulously designed to empower university students in their academic journey. Rooted in the belief that knowledge-sharing and peer support are essential for success, Shades provides a dynamic platform that seamlessly connects students to a world of academic resources, mentorship, and vibrant academic communities.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'With Modules Listings enriched by senior student reviews, curated Resources, a dynamic Discussion Forum, and dedicated Communities for student bodies, Shades is your all-in-one academic companion. Join us in revolutionizing university life by fostering knowledge exchange, nurturing academic excellence, and transforming the way students learn and grow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome to the future of university education; welcome to "Shades."',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
