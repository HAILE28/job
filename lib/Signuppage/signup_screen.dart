import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SELEDA/Services/global_methods.dart';
import 'package:SELEDA/Services/global_variabel.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../Persistent/painter.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  final TextEditingController _fullNameController =
      TextEditingController(text: '');

  final TextEditingController _emailTextController =
      TextEditingController(text: '');

  final TextEditingController _passTextController =
      TextEditingController(text: '');

  final TextEditingController _phoneNumberTextController =
      TextEditingController(text: '');
  final TextEditingController _postionTextController =
      TextEditingController(text: '');

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _postionCPFocusNode = FocusNode();

  final _SignUpFromKey = GlobalKey<FormState>();
  bool _obscureText = true;
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isloading = false;
  String? imageurl;

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _phoneNumberTextController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _postionCPFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    ;

    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();
    super.initState();
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Choose an option',
            style: TextStyle(
              color: Color.fromARGB(255, 36, 23, 58),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  _getFromCamera();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.camera_alt,
                        color: Color.fromARGB(255, 45, 130, 136),
                        size: 28.0,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'Take a photo',
                        style: TextStyle(
                          color: Color.fromARGB(255, 45, 130, 136),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.grey[300], thickness: 1.0),
              GestureDetector(
                onTap: () {
                  _getFromGllery();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.photo,
                        color: Color.fromARGB(255, 45, 130, 136),
                        size: 28.0,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'Choose from gallery',
                        style: TextStyle(
                          color: Color.fromARGB(255, 45, 130, 136),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // void _showImageDialog()
  // {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text('Please choose an option'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               InkWell(
  //                 onTap: () {
  //                   //create getFromCamera
  //                 },
  //                 child: Row(children: const [
  //                   Padding(
  //                     padding: EdgeInsets.all(4.0),
  //                     child: Icon(
  //                       Icons.camera,
  //                       color: Colors.purple,
  //                     ),
  //                   ),
  //                   Text(
  //                     'Camera',
  //                     style: TextStyle(color: Colors.purple),
  //                   )
  //                 ]),
  //               ),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               InkWell(
  //                 onTap: () {
  //                   //create getFromCamera
  //                 },
  //                 child: Row(children: const [
  //                   Padding(
  //                     padding: EdgeInsets.all(4.0),
  //                     child: Icon(
  //                       Icons.image,
  //                       color: Colors.purple,
  //                     ),
  //                   ),
  //                   Text(
  //                     'Gallery',
  //                     style: TextStyle(color: Colors.purple),
  //                   )
  //                 ]),
  //               )
  //             ],
  //           ),
  //         );
  //       });
  // }

  void _getFromCamera() async {
    XFile? PickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(PickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGllery() async {
    XFile? PickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(PickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(FieldPath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: FieldPath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null)
      setState(() {
        imageFile = File(croppedImage.path);
      });
  }

  void _submitFormOnSignup() async {
    final isvalid = _SignUpFromKey.currentState!.validate();
    if (isvalid) {
      if (imageFile == null) {
        GlobalMethod.showErrorDialog(error: 'Please an image', ctx: context);
        return;
      }
      setState(() {
        _isloading = true;
      });

      try {
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim());
        final User? user = _auth.currentUser;
        final _uid = user!.uid;
        final ref = FirebaseStorage.instance
            .ref()
            .child('userImage')
            .child(_uid + '.jpg');

        await ref.putFile(imageFile!);
        imageurl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(_uid).set({
          'id': _uid,
          'name': _fullNameController.text,
          'email': _emailTextController.text,
          'userImage': imageurl,
          'phoneNumber': _phoneNumberTextController.text,
          'location': _postionTextController.text,
          'createAt': Timestamp.now(),
          'usertype':''
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {
          _isloading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(children: [
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
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: ListView(
              children: [
                Form(
                    key: _SignUpFromKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showImageDialog();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: size.width * 0.28,
                              height: size.height * 0.14,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.cyanAccent,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: imageFile == null
                                    ? const Icon(
                                        Icons.camera_enhance_sharp,
                                        color: Colors.cyan,
                                        size: 30,
                                      )
                                    : Image.file(
                                        imageFile!,
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_emailFocusNode),
                          keyboardType: TextInputType.name,
                          controller: _fullNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'This field is misssing';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.orange),
                          decoration: const InputDecoration(
                              hintText: 'Full name / Company name',
                              hintStyle: TextStyle(color: Colors.green),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_passFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailTextController,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'The email shoude contain "@" ';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.orange),
                          decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.green),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,

                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_phoneNumberFocusNode),
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextController,
                          obscureText: !_obscureText, //change it dinamically
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return 'password should contain at least 7 charchter';
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.orange),
                          decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.orange,
                                ),
                              ),
                              hintText: 'Password',
                              hintStyle: const TextStyle(color: Colors.green),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_postionCPFocusNode),
                          keyboardType: TextInputType.phone,
                          controller: _phoneNumberTextController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'This field is missing';
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                              hintText: 'Phone Number',
                              hintStyle: TextStyle(color: Colors.green),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_postionCPFocusNode),
                          keyboardType: TextInputType.streetAddress,
                          controller: _postionTextController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'This field is missing';
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.orange),
                          decoration: const InputDecoration(
                              hintText: 'Company Adress /Location',
                              hintStyle: TextStyle(color: Colors.green),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red))),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        _isloading
                            ? Center(
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : MaterialButton(
                                onPressed: () {
                                  _submitFormOnSignup();
                                },
                                color: Colors.green[300],
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'SignUp',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ]),
                                ),
                              ),
                        const SizedBox(height: 40),
                        Center(
                          child: RichText(
                              text: TextSpan(children: [
                            const TextSpan(
                                text: 'Already have an account!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                            const TextSpan(
                              text: '           ',
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.canPop(context)
                                    ? Navigator.pop(context)
                                    : null,
                              text: 'Login',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          ])),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
