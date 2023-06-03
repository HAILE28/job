import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:SELEDA/Jobs/job_screen_profile.dart';
import 'package:SELEDA/Persistent/setting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Search/edit_profile.dart';

import '../Widgets/bottom_nav_bar.dart';
import '../usere_state.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;
  ProfileScreen({required this.userID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? name;
  String email = '';
  String phonNumber = '';
  String imageUrl = '';
  String joindAt = '';
  String location = '';

  bool _isLoading = false;
  bool _isSameUser = false;

  void getUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          phonNumber = userDoc.get('phoneNumber');
          imageUrl = userDoc.get('userImage');
          location = userDoc.get('location');

          Timestamp joindAtTimeStamp = userDoc.get('createAt');
          var joinedDate = joindAtTimeStamp.toDate();
          joindAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
        final User? user = _auth.currentUser;
        final _uid = user?.uid;

        print('_uid: $_uid');
        print('widget.userID: ${widget.userID}');

        setState(() {
          _isSameUser = _uid == widget.userID;
        });
        _isLoading = false;
      }
    } catch (error) {
      print('Error fetching user data: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  void cheek() {
    print(_isSameUser);
  }

  Widget UserInfo({required IconData icon, required String content}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.orange,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _contactBy(
      {required Color color, required Function fct, required IconData icon}) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
        ),
        onPressed: () {
          fct();
        },
      ),
    );
  }

  void _openWhatsUpChat() async {
    var url = 'http://wa.me/$phonNumber?text=HelloWorld';
    launchUrlString(url);
  }

  void _mailTo() async {
    final Uri params = Uri(
      scheme: 'mailTo',
      path: email,
      query:
          'subject = Write subject here , pleasebody=Hello,please Write details here',
    );
    final url = params.toString();
    launchUrlString(url);
  }

  void _callPhoneNumber() async {
    var url = 'tel://$phonNumber';
    launchUrlString(url);
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 232, 237, 239), // Light turquoise
            Color.fromARGB(255, 232, 237, 239), // Dark turquoise
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationbarForApp(
          indexNum: 3,
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: Center(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Stack(
                        children: [
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.all(30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 150,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      name == null ? 'Name here' : name!,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      'Account Information',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 22.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: UserInfo(
                                      icon: Icons.email,
                                      content: email,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: UserInfo(
                                      icon: Icons.phone,
                                      content: phonNumber,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: UserInfo(
                                      icon: Icons.location_pin,
                                      content: location,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    height: 35,
                                  ),
                                  _isSameUser
                                      ? Container()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            _contactBy(
                                              color: Colors.green,
                                              fct: () {
                                                _openWhatsUpChat();
                                              },
                                              icon: FontAwesome.whatsapp,
                                            ),
                                            _contactBy(
                                              color: Colors.blue,
                                              fct: () {
                                                _callPhoneNumber();
                                              },
                                              icon: Icons.phone,
                                            ),
                                            _contactBy(
                                              color: Colors.red,
                                              fct: () {
                                                _mailTo();
                                              },
                                              icon: Icons.mail_outline,
                                            ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  // const Divider(
                                  //   thickness: 1,
                                  //   color: Colors.black,
                                  // ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  !_isSameUser
                                      ? Container(
                                          color: Colors.brown,
                                        )
                                      : Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 30),
                                            child: MaterialButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          JobScreenP(),
                                                    ));
                                              },
                                              color: Colors.green,
                                              elevation: 8,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Text(
                                                      'My jobs',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Icon(
                                                      Icons.logout,
                                                      color: Colors.white,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: size.width * 0.40,
                                height: size.width * 0.40,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      imageUrl.isEmpty
                                          ? 'https://www.thermaxglobal.com/wp-content/uploads/2020/05/image-not-found.jpg'
                                          : imageUrl,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _isSameUser
                              ? Positioned(
                                  top: 130,
                                  left: 20,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      _editProfile();
                                    },
                                  ),
                                )
                              : Container(),
                          _isSameUser
                              ? Positioned(
                                  top: 130,
                                  right: 20,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.settings,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => SettingScreen()),
                                      );
                                    },
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
