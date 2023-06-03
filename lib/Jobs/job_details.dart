import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:SELEDA/Jobs/jobs_screen.dart';
import 'package:SELEDA/Services/global_methods.dart';
import 'package:SELEDA/Services/global_variabel.dart';
import 'package:SELEDA/Widgets/comments_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import 'apply.dart';
import 'apply_.dart';

class JobDetailScreen extends StatefulWidget {
  final String uploadedBy;
  final String jobId;
  JobDetailScreen({
    required this.uploadedBy,
    required this.jobId,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentControler = TextEditingController();

  bool _isCommenting = false;
  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? recruitment;
  Timestamp? PostedDateTimeStamp;
  Timestamp? deadLineDateTimeStamp;
  String? postedDate;
  String? deadLineData;
  String? locationCompany = '';
  String? emailcompany = '';
  int applicants = 0;
  bool isDeadLineAveleble = false;
  bool showComment = false;

  void getJobData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();
    if (userDoc == null) {
      return;
    } else {
      setState(() {
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .get();
    if (jobDatabase == null) {
      return;
    } else {
      setState(() {
        jobTitle = jobDatabase.get('jobTitle');
        jobDescription = jobDatabase.get('jobDEscription ');
        recruitment = jobDatabase.get('recuruitment');
        emailcompany = jobDatabase.get('email ');
        locationCompany = jobDatabase.get('location ');
        applicants = jobDatabase.get('applicant');
        PostedDateTimeStamp = jobDatabase.get('ceeratedAt ');
        deadLineDateTimeStamp = jobDatabase.get('DeadLineDateTimeStamp ');
        deadLineData = jobDatabase.get('deadLineDAte');
        var postDate = PostedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
      });
      var date = deadLineDateTimeStamp!.toDate();
      isDeadLineAveleble = date.isAfter(DateTime.now());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getJobData();
  }

  Widget dividerWidget() {
    return Column(
      children: const [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  applyForJob() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailcompany,
      query:
          'subject=Applying for $jobTitle&body=Hello, please attach Resume CV file',
    );
    final url = emailLaunchUri.toString();
    launchUrlString(url);
    addNewApplicant();
  }

  // void applyForJob() async {
  //   final Uri params = Uri(
  //     scheme: 'mailto',
  //     path: emailcompany,
  //     query:
  //         'subject=Applying for $jobTitle&body=Hello, please attach Resume CV file',
  //   );
  //   final url = params.toString();

  //   try {
  //     await launch(url);
  //     addNewApplicant();
  //   } catch (error) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Error'),
  //           content: Text('Failed to launch email client.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  void addNewApplicant() async {
    var docRef =
        FirebaseFirestore.instance.collection('jobs').doc(widget.jobId);

    docRef.update({'applicant': applicants + 1});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 102, 187, 106),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 102, 187, 106), // Light turquoise
                  Color.fromARGB(255, 85, 210, 91), // Dark turquoise
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobScreen(),
                  ));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            jobTitle == null ? '' : jobTitle!,
                            maxLines: 3,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.grey,
                                  ),
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      userImageUrl == null
                                          ? 'https://icon-library.com/images/default-profile-icon/default-profile-icon-24.jpg'
                                          : userImageUrl!,
                                    ),
                                    fit: BoxFit.fill,
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName == null ? '' : authorName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    locationCompany!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    emailcompany!,
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              applicants.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Applicants',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Icon(
                              Icons.how_to_reg_sharp,
                              color: Colors.amber,
                            )
                          ],
                        ),
                        FirebaseAuth.instance.currentUser!.uid !=
                                widget.uploadedBy
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  dividerWidget(),
                                  const Text(
                                    'Re00cruitment',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          User? user = _auth.currentUser;
                                          final _uid = user!.uid;
                                          if (_uid == widget.uploadedBy) {
                                            try {
                                              FirebaseFirestore.instance
                                                  .collection('jobs')
                                                  .doc(widget.jobId)
                                                  .update(
                                                      {'recuruitment': true});
                                            } catch (error) {
                                              GlobalMethod.showErrorDialog(
                                                error:
                                                    'Action can not be performed',
                                                ctx: context,
                                              );
                                            }
                                          } else {
                                            GlobalMethod.showErrorDialog(
                                                error:
                                                    'You can not perform this action',
                                                ctx: context);
                                          }
                                          getJobData();
                                        },
                                        child: const Text(
                                          'ON',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Opacity(
                                        opacity: recruitment == true ? 1 : 0,
                                        child: const Icon(
                                          Icons.check_box,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          User? user = _auth.currentUser;
                                          final _uid = user!.uid;
                                          if (_uid == widget.uploadedBy) {
                                            try {
                                              FirebaseFirestore.instance
                                                  .collection('jobs')
                                                  .doc(widget.jobId)
                                                  .update(
                                                      {'recuruitment': false});
                                            } catch (error) {
                                              GlobalMethod.showErrorDialog(
                                                error:
                                                    'Action can not be performed',
                                                ctx: context,
                                              );
                                            }
                                          } else {
                                            GlobalMethod.showErrorDialog(
                                                error:
                                                    'You can not peerform this action',
                                                ctx: context);
                                          }
                                          getJobData();
                                        },
                                        child: const Text(
                                          'OFF',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Opacity(
                                        opacity: recruitment == false ? 1 : 0,
                                        child: const Icon(
                                          Icons.check_box,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                        dividerWidget(),
                        const Text(
                          'job Description',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          jobDescription == null ? '' : jobDescription!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            isDeadLineAveleble
                                ? 'Activly Recruting send Cv / Resume:'
                                : 'Dead line passed away',
                            style: TextStyle(
                              color: isDeadLineAveleble
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Center(
                          child: MaterialButton(
                            onPressed: () {
                           Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => ApplicationForm(
      uploadedBy: widget.uploadedBy,
      jobId: widget.jobId,
    ),
  ),
);

                            },
                            color: Colors.blueAccent,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Apply Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'uploded on',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              postedDate == null ? ' unknown' : postedDate!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Job Expire on',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              deadLineData == null ? ' unknown' : deadLineData!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        dividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: _isCommenting
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                        flex: 3,
                                        child: TextField(
                                          controller: _commentControler,
                                          style: const TextStyle(
                                            color: Colors.lightBlue,
                                          ),
                                          maxLength: 200,
                                          keyboardType: TextInputType.text,
                                          maxLines: 6,
                                          decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                color: Colors.white,
                                              )),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                color: Colors.pinkAccent,
                                              ))),
                                        )),
                                    Flexible(
                                        child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: MaterialButton(
                                            onPressed: () async {
                                              if (_commentControler
                                                      .text.length <
                                                  7) {
                                                GlobalMethod.showErrorDialog(
                                                  error:
                                                      'Comment Cant be less than 7 Characters',
                                                  ctx: context,
                                                );
                                              } else {
                                                final _generatedId =
                                                    const Uuid().v4();
                                                await FirebaseFirestore.instance
                                                    .collection('jobs')
                                                    .doc(widget.jobId)
                                                    .update({
                                                  'jobComments':
                                                      FieldValue.arrayUnion([
                                                    {
                                                      'userId': FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid,
                                                      'commentID': _generatedId,
                                                      'name': name,
                                                      'userImageUrl': userImage,
                                                      'commentBody':
                                                          _commentControler
                                                              .text,
                                                      'time': Timestamp.now(),
                                                    }
                                                  ])
                                                });
                                                await Fluttertoast.showToast(
                                                  msg:
                                                      'Your comment has been added',
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  backgroundColor: Colors.grey,
                                                  fontSize: 18.0,
                                                );
                                                _commentControler.clear();
                                              }
                                              setState(() {
                                                showComment = true;
                                              });
                                            },
                                            color: Colors.blueAccent,
                                            elevation: 8,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'post',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _isCommenting = !_isCommenting;
                                                showComment = false;
                                              });
                                            },
                                            child: const Text('Cancel')),
                                      ],
                                    ))
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isCommenting = !_isCommenting;
                                            showComment = false;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.add_comment,
                                          color: Colors.blueAccent,
                                          size: 40,
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showComment = true;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.arrow_drop_down_circle,
                                          color: Colors.blueAccent,
                                          size: 40,
                                        )),
                                  ],
                                ),
                        ),
                        showComment == false
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.all(16.0),
                                child: FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('jobs')
                                      .doc(widget.jobId)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      if (snapshot.data == null) {
                                        const Center(
                                          child:
                                              Text('No comment for this job'),
                                        );
                                      }
                                    }
                                    return ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return commentWidget(
                                              commentId:
                                                  snapshot.data!['jobComments']
                                                      [index]['commentID'],
                                              commenterId:
                                                  snapshot.data!['jobComments']
                                                      [index]['userId'],
                                              commenterName:
                                                  snapshot.data!['jobComments']
                                                      [index]['name'],
                                              commentBody:
                                                  snapshot.data!['jobComments']
                                                      [index]['commentBody'],
                                              commentImageUrl:
                                                  snapshot.data!['jobComments']
                                                      [index]['userImageUrl']);
                                        },
                                        separatorBuilder: (context, index) {
                                          return const Divider(
                                            thickness: 1,
                                            color: Colors.grey,
                                          );
                                        },
                                        itemCount: snapshot
                                            .data!['jobComments'].length);
                                  },
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
