import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:SELEDA/Services/global_methods.dart';
import 'package:uuid/uuid.dart';

import '../Persistent/presistent.dart';
import '../Services/global_variabel.dart';
import '../Widgets/bottom_nav_bar.dart';

class UploadJobNow extends StatefulWidget {
  @override
  State<UploadJobNow> createState() => _UploadJobNowState();
}

class _UploadJobNowState extends State<UploadJobNow> {
  final TextEditingController _jobCategoryController =
      TextEditingController(text: 'select job category');

  final TextEditingController _jobTitleController =
      TextEditingController(text: 'select job Title');

  final TextEditingController _jobDescriptionController =
      TextEditingController(text: 'select job Description');

  final TextEditingController _jobDeadLineController =
      TextEditingController(text: ' choose job DeadLine Date');

  final _formKey = GlobalKey<FormState>();

  DateTime? picked;
  Timestamp? deadLineDateTimeStamp;

  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _jobDeadLineController.dispose();
  }

  Widget _textTitles({required String label}) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.green,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _textFormFild(
      {required String valueKey,
      required TextEditingController controller,
      required bool enablled,
      required Function fct,
      required int maxLength}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'value is misssing';
            }
            return null;
          },
          controller: controller,
          enabled: enablled,
          key: ValueKey(valueKey),
          style: const TextStyle(
            color: Colors.black,
          ),
          maxLines: valueKey == 'JobDescription' ? 6 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red))),
        ),
      ),
    );
  }

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
                        _jobCategoryController.text =
                            Persistent.jobCategoryList[index];
                      });
                      Navigator.pop(context);
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
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ))
            ],
          );
        });
  }

  void _pickDateDialog() async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _jobDeadLineController.text =
            ' ${picked!.year} - ${picked!.month} - ${picked!.day}';

        deadLineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
            picked!.microsecondsSinceEpoch);
      });
    }
  }

  void _UploadeTask() async {
    final jobId = const Uuid().v4();

    User? user = FirebaseAuth.instance.currentUser;
    final _uid =
        user?.uid; // Use null-aware operator to safely access uid property
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      if (_jobDeadLineController.text == ' choose job DeadLine Date' ||
          _jobCategoryController.text == 'select job category') {
        GlobalMethod.showErrorDialog(
            error: 'please pick everything', ctx: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).set({
          'jobId ': jobId,
          'upLoadBy': _uid,
          'email ': user?.email,
          'jobTitle': _jobTitleController.text,
          'jobDEscription ': _jobDescriptionController.text,
          'deadLineDAte': _jobDeadLineController.text,
          'DeadLineDateTimeStamp ': deadLineDateTimeStamp,
          'jobCategory': _jobCategoryController.text,
          'jobComments': [],
          'recuruitment': true,
          'ceeratedAt ': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location ': location,
          'applicant': 0,
        });
        await Fluttertoast.showToast(
          msg: 'The task has been uplodede',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        _jobTitleController.clear();
        _jobDescriptionController.clear();
        setState(() {
          _jobCategoryController.text = "Select job category";
          _jobDeadLineController.text = 'Select job deadline date ';
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('is not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 76, 210, 109), // Light turquoise
            Color.fromARGB(255, 250, 252, 253), // Dark turquoise
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationbarForApp(
          indexNum: 2,
        ),
        // backgroundColor: Colors.transparent,
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white, // Light turquoise
                  Colors.white, // Dark turquoise
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
              ),
            ),
            child: Card(
              color: Color.fromARGB(171, 253, 255, 255),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Please fill all fields',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _textTitles(
                                label: "Job catagory:",
                              ),
                              _textFormFild(
                                valueKey: 'JobCategory',
                                controller: _jobCategoryController,
                                enablled: false,
                                fct: () {
                                  _showTaskCategoriesDialog(size: size);
                                },
                                maxLength: 100,
                              ),
                              _textTitles(label: 'Job title'),
                              _textFormFild(
                                valueKey: 'JobTitle',
                                controller: _jobTitleController,
                                enablled: true,
                                fct: () {},
                                maxLength: 100,
                              ),
                              _textTitles(label: 'Job Description'),
                              _textFormFild(
                                valueKey: 'JobDescription',
                                controller: _jobDescriptionController,
                                enablled: true,
                                fct: () {},
                                maxLength: 200,
                              ),
                              _textTitles(label: 'Job DeadLine Date'),
                              _textFormFild(
                                valueKey: 'JobDeadLineDate',
                                controller: _jobDeadLineController,
                                enablled: false,
                                fct: () {
                                  _pickDateDialog();
                                },
                                maxLength: 100,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : MaterialButton(
                                  onPressed: () {
                                    _UploadeTask();
                                  },
                                  color: Colors.green[300],
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'Post Now',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Icon(
                                          Icons.upload_file,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
