import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:SELEDA/Services/global_variabel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../Persistent/painter.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _locationController;
  File? _image;
  String? _imageUrl; // Added variable to store the image URL

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _locationController = TextEditingController();
    // Retrieve the current user's data and set it in the text controllers
    getUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();

    super.dispose();
  }

  void getUserData() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final User? user = _auth.currentUser;
      final String userId = user!.uid;

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc == null) {
        return;
      } else {
        setState(() {
          _nameController.text = userDoc.get('name');
          _emailController.text = userDoc.get('email');
          _phoneNumberController.text = userDoc.get('phoneNumber');
          _locationController.text = userDoc.get('location');
          _imageUrl = userDoc.get('userImage'); // Set the image URL
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> _updateProfile() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final User? user = _auth.currentUser;
      final String userId = user!.uid;

      String imageUrl = _imageUrl ?? '';

      if (_image != null) {
        // Upload the new profile picture to Firebase Storage
        imageUrl = await _uploadImage(_image!);
      }

      // Update the user's profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
        'userImage': imageUrl,
        'location': _locationController.text,
      });

      // Show a success dialog or navigate back to the profile screen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Profile updated successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(
                    context,
                  ); // Pop twice to go back to the profile screen
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error updating profile: $error');
      // Show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while updating the profile.'),
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
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      final String fileName = userId + DateTime.now().toString();

      // Upload the image file to Firebase Storage
      final Reference reference = storage.ref().child('user_images/$fileName');
      final UploadTask uploadTask = reference.putFile(image);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: Text('Edit Profile'),
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              color: Colors.white,
            ),
          ),
          Opacity(
            opacity: 0.5,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 170,
                color: Colors.green[400],
              ),
            ),
          ),
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 150,
              color: Colors.green[400],
            ),
          ),
          Opacity(
            opacity: 0.5,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                color: Colors.green[400],
                child: ClipPath(
                  clipper: WaveClipperBottom(),
                  child: Container(
                    height: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Image preview
              Container(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 75,
                            backgroundImage: FileImage(_image!),
                          )
                        : _imageUrl != null
                            ? CircleAvatar(
                                radius: 75,
                                backgroundImage: NetworkImage(_imageUrl!),
                              ) // Display the image if it exists
                            : CircleAvatar(
                                radius: 75,
                                child: Icon(Icons.person),
                              ), // Placeholder if no image is selected or available
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.photo_library),
                                    title: Text('Choose from Gallery'),
                                    onTap: () {
                                      _pickImage(ImageSource.gallery);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.photo_camera),
                                    title: Text('Take a Photo'),
                                    onTap: () {
                                      _pickImage(ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
              // Name field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              // Email field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              // Phone number field
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              // Save button
              MaterialButton(
                onPressed: _updateProfile,
                color: Colors.green[400],
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class WaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final double waveHeight = 40;
//     final Path path = Path()
//       ..lineTo(0, size.height - waveHeight)
//       ..quadraticBezierTo(
//           size.width / 4, size.height, size.width / 2, size.height)
//       ..quadraticBezierTo(size.width - size.width / 4, size.height, size.width,
//           size.height - waveHeight)
//       ..lineTo(size.width, 0)
//       ..close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }
