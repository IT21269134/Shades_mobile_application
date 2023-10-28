import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initDelay();
  }

  Future<void> _initDelay() async {
    // Adding an artificial delay of 2 seconds
    await Future.delayed(Duration(seconds: 4));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget.child!),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/module/splash.gif', // Replace 'your_gif_image_path.gif' with the actual path
                  // You can customize the width and height if needed
                  width: 200,
                  height: 200,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Welcome to Shades",
              style: TextStyle(
                // color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 24, // Increase font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
