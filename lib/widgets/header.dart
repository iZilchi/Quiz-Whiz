import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final bool isHomePage;

  const Header({super.key, required this.title, this.isHomePage = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 10, 100, 13),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(  // Center the title in the header
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
