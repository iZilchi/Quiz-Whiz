import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 99,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // Remove the image decoration
        ),
        child: const Center(
          child: Text(
            'Subject Name',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
      ),
    );
  }
}
