import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final bool isHomePage;

  const Header({required this.title, this.isHomePage = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 10, 100, 13),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 20),
      child: Center(  // Center the title in the header
        child: Text(
          title,
          style: TextStyle(
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
