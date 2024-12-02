import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase/firestore_services.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmedPasswordController = TextEditingController();

  //Get username and email in database
  Future<Map<String, String>> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in.');
    }

    return await firestoreService.getUserDetails(user.uid);
  }

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
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              try {
                await FirebaseAuth.instance.signOut();
                // Navigate to the login screen or a similar route
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                // Show an error dialog if signOut fails
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text('Failed to log out: $e'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the error dialog
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}

  // Function to show the Account Settings pop-up with extra features
   void _editAccountDetailsDialog(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    _showDialog(context, 'Error', 'No user is logged in.');
    return;
  }

  // Ensure the user document is initialized
  try {
    await firestoreService.initializeUser(user.uid, user.email ?? "guest@example.com");
  } catch (e) {
    _showDialog(context, 'Error', 'Failed to initialize user: $e');
    return;
  }

  usernameController.text = user.displayName ?? "guest";

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Account Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Username',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'New Username',
                hintText: 'Enter your new username',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String newUsername = usernameController.text.trim();
              if (newUsername.isNotEmpty) {
                try {
                  await firestoreService.updateUsername(user.uid, newUsername);
                  await user.updateDisplayName(newUsername);

                  Navigator.pop(context);
                  _showDialog(context, 'Success', 'Username updated successfully.');
                } catch (e) {
                  Navigator.pop(context);
                  _showDialog(context, 'Error', 'Failed to update username: $e');
                }
              } else {
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
      body: FutureBuilder<Map<String, String>>(
        future: _fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No user details available.'));
          }

          final userDetails = snapshot.data!;
          final username = userDetails['username']!;
          final email = userDetails['email']!;

          return Stack(
            children: [
              Container(
                color: Colors.grey[200],
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 34, 123, 148),
                                    width: 3,
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
                              Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ListTile(
                          leading: const Icon(Icons.account_circle, color: Color.fromARGB(255, 34, 123, 148)),
                          title: const Text('Account Details'),
                          onTap: () => _editAccountDetailsDialog(context),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.notifications, color: Color.fromARGB(255, 34, 123, 148)),
                          title: const Text('Notification Settings'),
                          onTap: () => _showNotificationsDialog(context),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.info, color: Color.fromARGB(255, 34, 123, 148)),
                          title: const Text('About'),
                          onTap: () => _showAboutDialog(context),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Logout'),
                          onTap: () => _handleLogout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
