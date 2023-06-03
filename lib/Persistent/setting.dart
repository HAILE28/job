import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../usere_state.dart';

class SettingScreen extends StatelessWidget {
  void _logout(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'sign out',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              )
            ],
          ),
          content: const Text(
            'Do you want to log out?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                _auth.signOut();
                Navigator.canPop(context) ? Navigator.pop(context) : null;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: ((_) => UserState())),
                );
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        SizedBox(width: 8.0),
        Text(
          '$title $subtitle',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor:
            Colors.green, // Set the app bar background color to green
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Support section
          ListTile(
            title: Text('Support'),
            subtitle: Text('Contact Us'),
            leading: Icon(Icons.mail),
            onTap: () {
              // Navigate to Contact Us screen
            },
          ),

          // Privacy Policy
          ListTile(
            title: Text('Privacy Policy'),
            leading: Icon(Icons.description),
            onTap: () {
              // Navigate to Privacy Policy screen
            },
          ),

          // Terms and Conditions
          ListTile(
            title: Text('Terms and Conditions'),
            leading: Icon(Icons.gavel),
            onTap: () {
              // Navigate to Terms and Conditions screen
            },
          ),

          Divider(),

          // App Info section
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.green,
            child: ListTile(
              title: Text(
                'App Info',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoRow(Icons.build, 'Build Name:', 'App Name'),
                  buildInfoRow(Icons.info, 'Version:', '1.0.0'),
                  buildInfoRow(Icons.code, 'Build Number:', '1'),
                ],
              ),
              leading: Icon(
                Icons.info,
                color: Colors.white,
              ),
              onTap: () {
                // Navigate to App Info screen
              },
            ),
          ),

          // About Us
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.orange,
            child: ListTile(
              title: Text(
                'About Us',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoRow(Icons.business, 'Owned By:', ' Company'),
                  buildInfoRow(Icons.person, 'Developed By:', 'haile , giza , mulat..'),
                ],
              ),
              leading: Icon(
                Icons.info,
                color: Colors.white,
              ),
              onTap: () {
                // Navigate to About Us screen
              },
            ),
          ),

          Divider(),

          // Sign Out
          ListTile(
            title: Text('Sign Out'),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              // Perform sign out action
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
