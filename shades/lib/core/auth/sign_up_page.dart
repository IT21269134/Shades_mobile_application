import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shades/core/auth/firebase_auth_services.dart';
import 'package:shades/core/auth/login_page.dart';
import 'package:shades/core/auth/form_container_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shades"),
        backgroundColor: Color(0xFF146C94),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _usernameController,
                hintText: "Username - (visible to others)",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email - (use your university email)",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color(0xFF146C94),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 10),
                              Text(
                                "Creating user..",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF146C94),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (!_isEmailValid(email) || !_isEmailAndPasswordFilled(email, password)) {
      _showErrorSnackBar("Invalid email address or empty fields");
      return;
    }

    if (!email.endsWith('@my.sliit.lk')) {
      _showErrorSnackBar("Please use your university Email !");
      return;
    }

    if (await _isEmailTaken(email)) {
      _showErrorSnackBar("Email is already in use");
      return;
    }

    if (await _isUsernameTaken(username)) {
      _showErrorSnackBar("Username is already taken");
      return;
    }

    if (!_isPasswordValid(password)) {
      _showErrorSnackBar("Password must be more than 6 characters");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      await _addUserToFirestore(user.uid, username, email);

      print("User is successfully created");
      Navigator.pushNamed(context, "/home");
    } else {
      print("Some error happened");
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email);
  }

  bool _isEmailAndPasswordFilled(String email, String password) {
    return email.isNotEmpty && password.isNotEmpty;
  }

  bool _isPasswordValid(String password) {
    return password.length >= 6;
  }

  Future<bool> _isEmailTaken(String email) async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print("Error checking email existence: $e");
      return false;
    }
  }

  Future<bool> _isUsernameTaken(String username) async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print("Error checking username existence: $e");
      return false;
    }
  }

  Future<void> _addUserToFirestore(
      String userId, String username, String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': username,
        'email': email,
        'role': 'student',
      });
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
