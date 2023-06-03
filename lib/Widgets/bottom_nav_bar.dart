import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SELEDA/Jobs/jobs_screen.dart';
import 'package:SELEDA/Jobs/upload_job.dart';
import 'package:SELEDA/Search/profile_company.dart';
import 'package:SELEDA/Search/search_companies.dart';
import 'package:SELEDA/usere_state.dart';

class BottomNavigationbarForApp extends StatelessWidget {
  int indexNum = 0;
  BottomNavigationbarForApp({required this.indexNum});

  void _logout(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: Row(children: const [
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
            ]),
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
                  )),
              TextButton(
                  onPressed: () {
                    _auth.signOut();
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: ((_) => UserState())));
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 115, 243, 190), // Light turquoise
            Color.fromARGB(255, 165, 221, 249), // Dark turquoise
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.2, 0.9],
        ),
      ),
      child: CurvedNavigationBar(
        backgroundColor: Color.fromARGB(255, 220, 235, 241),
        buttonBackgroundColor: Colors.green,
        height: 50,
        index: indexNum,
        items: const [
          Icon(
            Icons.list,
            size: 19,
            color: Colors.black,
          ),
          Icon(
            Icons.search,
            size: 19,
            color: Colors.black,
          ),
          Icon(
            Icons.add,
            size: 19,
            color: Colors.black,
          ),
          Icon(
            Icons.person_pin,
            size: 19,
            color: Colors.black,
          ),
          Icon(
            Icons.logout,
            size: 19,
            color: Colors.black,
          )
        ],
        animationDuration: Duration(milliseconds: 300),
        animationCurve: Curves.bounceInOut,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => JobScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => AllWorkersScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => UploadJobNow()));
          } else if (index == 3) {
            final FirebaseAuth _auth = FirebaseAuth.instance;
            final User? user = _auth.currentUser;

            final String uid = user!.uid;

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                          userID: uid,
                        )));
          } else if (index == 4) {
            _logout(context);
          }
        },
      ),
    );
  }
}
