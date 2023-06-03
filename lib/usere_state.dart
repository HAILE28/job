import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:SELEDA/Jobs/jobs_screen.dart';
import 'package:SELEDA/Jobs/upload_job.dart';
import 'package:SELEDA/LoginPage/login_screen.dart';
import 'package:SELEDA/Search/profile_company.dart';
import 'package:SELEDA/home_page_0ne.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:SELEDA/Jobs/jobs_screen.dart';
import 'package:SELEDA/LoginPage/login_screen.dart';
import 'package:SELEDA/Search/profile_company.dart';
import 'package:SELEDA/home_page_0ne.dart';

class UserState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
       

        if (userSnapshot.data == null) {
          print('user is not logged in yet');
          return Login();
        } else if (userSnapshot.hasData) {
          print('user is already logged in');

          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;

          final String uid = user!.uid;
          return JobScreen();
        } else if (userSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('An error has occurred. Please try again later.'),
            ),
          );
        } else if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: Text('Something must be wrong.'),
          ),
        );
      },
    );
  }
}
