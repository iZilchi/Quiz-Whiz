// screens/subject_screen.dart
import 'package:flutter/material.dart';

class SubjectScreen extends StatelessWidget {
  final List<String> subjects = [
    'Math', 'Science', 'History', 'Geography', 'Literature', 'Biology', 'Physics', 'Chemistry'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter options (e.g., category or difficulty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: Text('Category'),
                  onChanged: (value) {
                    // Handle category filter change
                  },
                  items: <String>['All', 'Science', 'Math', 'Literature']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add subject functionality or filter
                  },
                  child: Text('Add Subject'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Display subjects in a grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2 / 1,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle subject card tap to view/edit the subject
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.green[100],
                      child: Center(
                        child: ListTile(
                          leading: Icon(Icons.book, size: 30),
                          title: Text(
                            subjects[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
