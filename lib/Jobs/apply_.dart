import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApplicationForm extends StatefulWidget {
  final String uploadedBy;
  final String jobId;

  const ApplicationForm({
    required this.uploadedBy,
    required this.jobId,
  });

  @override
  _ApplicationFormState createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _resumeController = TextEditingController();

  void submitApplication() {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final applicantId = currentUser?.uid ?? '';
      final applicantName = _nameController.text.trim();
      final applicantEmail = _emailController.text.trim();
      final resumeUrl = _resumeController.text.trim();

      FirebaseFirestore.instance.collection('applicants').add({
        'jobId': widget.jobId,
        'uploadedBy': widget.uploadedBy,
        'applicantId': applicantId,
        'applicantName': applicantName,
        'applicantEmail': applicantEmail,
        'resumeUrl': resumeUrl,
        'applicationDate': Timestamp.now(),
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application submitted successfully')),
        );
        _nameController.clear();
        _emailController.clear();
        _resumeController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit application')),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for Job'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // You can add additional email validation logic if required
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _resumeController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Resume/CV URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your resume/CV URL';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitApplication,
                child: Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
