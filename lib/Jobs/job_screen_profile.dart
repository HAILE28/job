import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SELEDA/Persistent/presistent.dart';
import 'package:SELEDA/Search/search_job.dart';
import 'package:SELEDA/Widgets/bottom_nav_bar.dart';
import 'package:SELEDA/Widgets/job_widget.dart';
import 'package:SELEDA/Widgets/job_widget_profile.dart';
import 'package:provider/provider.dart';

class Profile {
  final String name;
  final String email;
  final String location;

  Profile({
    required this.name,
    required this.email,
    required this.location,
  });
}

class ProfileProvider extends ChangeNotifier {
  Profile _profile = Profile(name: '', email: '', location: '');

  Profile get profile => _profile;

  void updateProfile(Profile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }
}

class JobScreenP extends StatefulWidget {
  @override
  State<JobScreenP> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreenP> {
  String? jobCategoryfilter;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _data = FirebaseFirestore.instance;

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: const Text(
            'Job Category',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          content: Container(
            width: size.width * 0.9,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Persistent.jobCategoryList.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      jobCategoryfilter = Persistent.jobCategoryList[index];
                    });
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    print(
                      'jobCategoryList[index], ${Persistent.jobCategoryList[index]}',
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_right_alt_outlined,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          Persistent.jobCategoryList[index],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: (() {
                setState(() {
                  jobCategoryfilter = null;
                });
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              }),
              child: const Text(
                'Cancel Filter',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Persistent persistentObject = Persistent();
    persistentObject.getMyData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ChangeNotifierProvider(
      create: (context) => ProfileProvider(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 234, 241, 248), // Light turquoise
              Color.fromARGB(255, 250, 252, 253), // Dark turquoise
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.2, 0.9],
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green, // Light turquoise
                    Colors.green // Dark turquoise
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.2, 0.9],
                ),
              ),
            ),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.filter_list_rounded,
                color: Colors.black,
              ),
              onPressed: () {
                _showTaskCategoriesDialog(size: size);
              },
            ),
            actions: [
              // IconButton(
              //   onPressed: () {
              //     Navigator.pushReplacement(
              //       context,
              //       MaterialPageRoute(builder: (c) => SearchScreen()),
              //     );
              //   },
              //   icon: const Icon(Icons.search_outlined, color: Colors.black),
              // )
            ],
          ),
          body: Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              final profile = profileProvider.profile;
              final name = profile.name;
              final email = profile.email;
              final location = profile.location;

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .where('jobCategory', isEqualTo: jobCategoryfilter)
                    .where('recuruitment', isEqualTo: true)
                    .orderBy('ceeratedAt ', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.active) {
                    if (snapshot.data?.docs.isNotEmpty == true) {
                      return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return JobWidgetP(
                            jobTitle: snapshot.data?.docs[index]['jobTitle'],
                            jobDescription: snapshot.data?.docs[index]
                                ['jobDEscription '],
                            jobId: snapshot.data?.docs[index]['jobId '],
                            uploadedBy: snapshot.data?.docs[index]['upLoadBy'],
                            userImage: snapshot.data?.docs[index]['userImage'],
                            name: snapshot.data?.docs[index]['name'],
                            recruitment: snapshot.data?.docs[index]
                                ['recuruitment'],
                            email: snapshot.data?.docs[index]['email '],
                            location: snapshot.data?.docs[index]['location '],
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('There are no jobs'),
                      );
                    }
                  }

                  return const Center(
                    child: Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
