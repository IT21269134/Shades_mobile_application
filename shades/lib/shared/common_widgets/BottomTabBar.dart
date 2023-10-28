import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Add this import
import 'package:shades/features/community_mgt/community.dart';
import 'package:shades/features/community_mgt/user_profile.dart'; // Import the user profile page
import 'package:shades/features/module_mgt/module.dart';
import 'package:shades/features/query_mgt/query.dart';
import 'package:shades/features/resource_mgt/resource.dart';
import 'package:shades/features/community_mgt/user_profile.dart';

class BottomTabBar extends StatefulWidget {
  const BottomTabBar({Key? key}) : super(key: key);

  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    QueryOperations(),
    const Moduleoperations(),
    const Resourceoperations(),
    CommunityOperations(),
  ];
  final List<String> _tabTitles = [
    'Query',
    'Module',
    'Resource',
    'Community',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF146C94),
        elevation: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    AssetImage('assets/community/profile images/pp.png'),
              ),
            ),
            SizedBox(width: 10),
            Text(
              _tabTitles[_currentIndex],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, "/login");
            },
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        color: Color(0xFF146C94), // Background color of unselected items
        buttonBackgroundColor:
            Color(0xFF146C94), // Background color of selected item
        items: <Widget>[
          Icon(Icons.question_answer, size: 30, color: Colors.white),
          Icon(Icons.apps, size: 30, color: Colors.white),
          Icon(Icons.library_books, size: 30, color: Colors.white),
          Icon(Icons.group, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
