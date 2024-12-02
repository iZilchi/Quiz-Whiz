import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title; // Dynamic title
  final bool isHomePage; // Determines if it's the homepage
  final List<Widget>? actions; // Optional action buttons/icons

  const Header({
    Key? key,
    required this.title,
    this.isHomePage = false,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180, // Increased height for a more prominent header
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 10, 100, 13), // Primary green
            Color.fromARGB(255, 8, 81, 11), // Darker shade for gradient effect
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5), // Subtle shadow for depth
          ),
        ],
      ),
      child: Stack(
        children: [
          // Title Centered in the Header
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 4,
                      offset: Offset(1, 1), // Subtle text shadow for clarity
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
