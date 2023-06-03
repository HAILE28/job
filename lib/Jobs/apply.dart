import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationFormScreen extends StatefulWidget {
  final String jobid;

  ApplicationFormScreen({required this.jobid});

  @override
  _ApplicationFormScreenState createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _locationController;
  String? _userId; // Added variable to store the user ID
  String? jobTitle = '';
  String? emailcompany = '';
  String loon = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _locationController = TextEditingController();
    _getCurrentUserData(); // Get the current user's data
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _getCurrentUserData() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final User? user = _auth.currentUser;
      if (user != null) {
        final String userId = user.uid;
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc == null) {
          return;
        } else {
          setState(() {
            _userId = userId; // Store the user ID
            _nameController.text = userDoc.get('name');
            _emailController.text = userDoc.get('email');
            _phoneNumberController.text = userDoc.get('phoneNumber');
            _locationController.text = userDoc.get('location');
          });
        }
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<Map<String, dynamic>?> getJobTitleAndEmail(String jobId) async {
    try {
      final DocumentSnapshot jobSnapshot =
          await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();

      if (jobSnapshot.exists) {
        final String title = jobSnapshot.get('jobTitle');
        final String email = jobSnapshot.get('email');
        loon = title;
        return {
          'title': title,
          'email': email,
        };
      }
    } catch (error) {
      print('Error fetching job data: $error');
    }

    return null;
  }

  Future<void> _submitApplication() async {
    try {
      // Get the values from the text controllers
      final String name = _nameController.text;
      final String email = _emailController.text;
      final String phoneNumber = _phoneNumberController.text;
      final String location = _locationController.text;

      // Validate the form fields
      if (name.isEmpty ||
          email.isEmpty ||
          phoneNumber.isEmpty ||
          location.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Please fill all the required fields and attach a CV file.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Construct the email parameters
      final Uri params = Uri(
        scheme: 'mailto',
        path: email!,
        query:
            'subject=Applying for $loon&body=Name: $name\nEmail: $email\nPhone Number: $phoneNumber\nLocation: $location\n\nHello, please find attached my resume (CV) for the job application.',
      );

      // Generate the email URL
      final url = params.toString();

      // Open the user's email client to send the application email
      await launchUrl(url as Uri);

      // Perform any additional application submission logic here

      // Show a success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Application submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error submitting application: $error');
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        // _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Set the app bar color to green
        title: Text('Application Form'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitApplication,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
