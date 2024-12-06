// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String subjectName; // Dynamic subject name
  final VoidCallback? onTap; // Tap handler for interactivity

  const SubjectCard({
    super.key,
    required this.subjectName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Allows the card to be tappable
      child: Card(
        elevation: 10, // Slightly increased elevation for better prominence
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Adds consistent padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // More pronounced rounded corners
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300), // Smooth hover or tap effect
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade300,
                Colors.indigo.shade500,
              ], // Gradient for a modern and vibrant look
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(4, 4), // Subtle shadow for depth
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add a slight animation effect when tapped/hovered
              Hero(
                tag: subjectName, // Ensures smooth transition if used in navigation
                child: const Icon(
                  Icons.book_rounded, // Modern rounded icon for context
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12), // Increased spacing for better layout
              Text(
                subjectName, // Dynamic subject name
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18, // Slightly larger font size for better readability
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // White text for contrast
                  letterSpacing: 1.2, // Improves text legibility
                ),
              ),
              const SizedBox(height: 8), // Additional spacing
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Tap to explore', // Additional interactivity hint
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
