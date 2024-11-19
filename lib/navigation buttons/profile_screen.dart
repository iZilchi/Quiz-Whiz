import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Function to handle the logout action
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacementNamed(context, '/login'); // Example navigation
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Function to show the Account Settings pop-up with extra features
  void _showAccountSettingsDialog(BuildContext context) {
    TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Account Settings'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Change Username Section
                const Text(
                  'Change Username',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'New Username',
                    hintText: 'Enter your new username',
                  ),
                ),
                const SizedBox(height: 20),

                // Change Email Section
                const Text(
                  'Change Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'New Email',
                    hintText: 'Enter your new email',
                  ),
                ),
                const SizedBox(height: 20),

                // Change Password Section
                const Text(
                  'Change Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Picture Section
                const Text(
                  'Change Profile Picture',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Change Picture'),
                  onPressed: () {
                    // Logic for changing the profile picture
                  },
                ),
                const SizedBox(height: 20),

                // Language Preferences Section
                const Text(
                  'Language Preferences',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'English',
                      child: Text('English'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Spanish',
                      child: Text('Spanish'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'French',
                      child: Text('French'),
                    ),
                  ],
                  onChanged: (value) {
                    // Logic to change language preferences
                  },
                  hint: const Text('Select Language'),
                ),
                const SizedBox(height: 20),

                // Delete Account Section
                const Text(
                  'Delete Account',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                TextButton(
                  onPressed: () {
                    _showDialog(context, 'Account Deleted', 'Your account has been successfully deleted.');
                  },
                  child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newUsername = usernameController.text;
                if (newUsername.isNotEmpty) {
                  Navigator.pop(context); // Close the dialog
                  _showDialog(context, 'Username Updated', 'Your username has been updated to: $newUsername');
                } else {
                  Navigator.pop(context);
                  _showDialog(context, 'Error', 'Please enter a valid username.');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show a generic pop-up dialog
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to show the Notifications pop-up
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Notification Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Notification preferences
              bool emailNotifications = true;
              bool pushNotifications = false;
              bool smsNotifications = false;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    activeColor: Colors.green,
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive updates via email.'),
                    value: emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        emailNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    activeColor: Colors.green,
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Get real-time alerts on your device.'),
                    value: pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        pushNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    activeColor: Colors.green,
                    title: const Text('SMS Notifications'),
                    subtitle: const Text('Receive updates via SMS.'),
                    value: smsNotifications,
                    onChanged: (value) {
                      setState(() {
                        smsNotifications = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to show the About dialog with description
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'About the App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This app provides users with a platform to take various quizzes on different topics, '
            'track their progress, and improve their knowledge in a fun and interactive way. With features '
            'like adjustable difficulty levels, real-time score tracking, and a variety of categories, users '
            'can enjoy a personalized quiz experience designed to help them learn and grow.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            const ListTile(
              leading: Icon(Icons.info, color: Colors.green),
              title: Text('App Version: 1.0.0'),
            ),
            const ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text('Developed by: Landicho, Alessandra Marie, Padua, Chris Justine, Pagcaliuangan, Kent Melard and Tadeja, Jude'),
            ),
            const ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text('Contact: quizwhiz@gmail.com'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with Scrollable Content
          Container(
            color: Colors.grey[200], // Set the background color
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),

                    // Profile Picture and User Info Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green, // Border color
                                width: 3, // Border width
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                'https://www.example.com/user-profile-image.jpg',
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Jude Tadeja',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
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
                      onTap: () => _showAccountSettingsDialog(context), // Show the Account Settings pop-up
                    ),
                    const Divider(),

                    // Notifications Section
                    ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.green),
                      title: const Text('Notification Settings'),
                      onTap: () => _showNotificationsDialog(context), // Show the Notifications pop-up
                    ),
                    const Divider(),

                    // About Section
                    ListTile(
                      leading: const Icon(Icons.info, color: Colors.green),
                      title: const Text('About'),
                      onTap: () => _showAboutDialog(context), // Show the About pop-up
                    ),
                    const Divider(),

                    // Logout Section
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout'),
                      onTap: () => _handleLogout(context), // Show the Logout confirmation dialog
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
