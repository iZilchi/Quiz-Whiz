// screens/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logout button at the top
              Positioned(
                top: 40,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.logout, size: 30),
                  onPressed: () => _showLogoutDialog(context),
                ),
              ),
              SizedBox(height: 50),

              // Profile Picture and User Info Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://www.example.com/user-profile-image.jpg',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'john.doe@example.com',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Account Settings Section
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.green),
                title: Text('Account Settings'),
                onTap: () {
                  // Navigate to Account Settings
                },
              ),
              Divider(),

              // Preferences Section (e.g., Notifications, Dark Mode)
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.green),
                title: Text('Notifications'),
                onTap: () {
                  // Navigate to Notifications settings
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.dark_mode, color: Colors.green),
                title: Text('Dark Mode'),
                onTap: () {
                  // Toggle Dark Mode
                },
              ),
              Divider(),

              // About Section
              ListTile(
                leading: Icon(Icons.info, color: Colors.green),
                title: Text('About'),
                onTap: () {
                  // Navigate to About page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel button
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
