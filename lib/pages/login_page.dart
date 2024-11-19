import 'package:flutter/material.dart';
import 'signup_page.dart';
import '../widgets/header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Header(title: 'QUIZ\nWHIZ'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
              child: Center(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // Container border radius
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center, // Center-align content
                    children: [
                      const Text(
                        'Log in to your account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(221, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center, // Center-align text
                      ),
                      const SizedBox(height: 20),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to HomePage on login
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 10, 100, 13),
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Adjusted border radius for button
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                            TextButton(
                              onPressed: () {
                                // Navigate to SignUpPage on "Sign Up now" click
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                                );
                              },
                              child: const Text(
                                "Sign Up now",
                                style: TextStyle(color: Colors.blue),
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
          ],
        ),
      ),
    );
  }
}
