import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wrap the SingleChildScrollView in a Container to set the background color
          Container(
            color: Colors.grey[200], // Set the background color here
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),

                    // Profile Picture and User Info Section
                    const Center(
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
                            'Jude Tadeja',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'judetadeja17@gmail.com',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Account Settings Section
                    ListTile(
                      leading: const Icon(Icons.account_circle, color: Colors.green),
                      title: const Text('Account Settings'),
                      onTap: () {
                        // Navigate to Account Settings
                      },
                    ),
                    const Divider(),

                    // Preferences Section (e.g., Notifications, Dark Mode)
                    ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.green),
                      title: const Text('Notifications'),
                      onTap: () {
                        // Navigate to Notifications settings
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.dark_mode, color: Colors.green),
                      title: const Text('Dark Mode'),
                      onTap: () {
                        // Toggle Dark Mode
                      },
                    ),
                    const Divider(),

                    // About Section
                    ListTile(
                      leading: const Icon(Icons.info, color: Colors.green),
                      title: const Text('About'),
                      onTap: () {
                        // Navigate to About page
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Logout button positioned at the top right
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.logout, size: 30),
              onPressed: () => _showLogoutDialog(context),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel button
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
