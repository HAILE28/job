import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Persistent/presistent.dart';

class EditJob extends StatefulWidget {
  final String jobId;

  EditJob({required this.jobId});

  @override
  State<EditJob> createState() => _EditJobState();
}

class _EditJobState extends State<EditJob> {
  final TextEditingController _jobCategoryController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _jobDeadLineController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  DateTime? picked;
  Timestamp? deadLineDateTimeStamp;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchJobData();
  }

  @override
  void dispose() {
    super.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _jobDeadLineController.dispose();
  }

  void _fetchJobData() {
    FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _jobCategoryController.text = data['jobCategory'];
          _jobTitleController.text = data['jobTitle'];
          _jobDescriptionController.text = data['jobDEscription '];
          _jobDeadLineController.text = data['deadLineDAte'];
          deadLineDateTimeStamp = data['DeadLineDateTimeStamp'];
        });
      }
    }).catchError((error) {
      print('Error fetching job data: $error');
    });
  }

  Widget _textTitles({required String label}) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.blue[900],
        ),
      ),
    );
  }

  Widget _textFormField(
      {required String valueKey,
      required TextEditingController controller,
      required bool enabled,
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
          enabled: enabled,
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

  // Widget _textFormField(
  //     {required String valueKey,
  //     required TextEditingController controller,
  //     required bool enablled,
  //     required Function fct,
  //     required int maxLength}) {
  //   return Padding(
  //     padding: const EdgeInsets.all(5.0),
  //     child: InkWell(
  //       onTap: () {
  //         fct();
  //       },
  //       child: TextFormField(
  //         validator: (value) {
  //           if (value!.isEmpty) {
  //             return 'value is misssing';
  //           }
  //           return null;
  //         },
  //         controller: controller,
  //         enabled: enablled,
  //         key: ValueKey(valueKey),
  //         style: const TextStyle(
  //           color: Colors.black,
  //         ),
  //         maxLines: valueKey == 'JobDescription' ? 6 : 1,
  //         maxLength: maxLength,
  //         keyboardType: TextInputType.text,
  //         decoration: const InputDecoration(
  //             filled: true,
  //             fillColor: Colors.white,
  //             enabledBorder: UnderlineInputBorder(
  //               borderSide: BorderSide(color: Colors.black),
  //             ),
  //             focusedBorder: UnderlineInputBorder(
  //                 borderSide: BorderSide(color: Colors.black)),
  //             errorBorder: UnderlineInputBorder(
  //                 borderSide: BorderSide(color: Colors.red))),
  //       ),
  //     ),
  //   );
  // }

  void _pickDateDialog() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        picked = date;
        _jobDeadLineController.text = date.toString();
        deadLineDateTimeStamp = Timestamp.fromDate(date);
      });
    }
  }

  void _updateJob() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      if (_jobDeadLineController.text.isEmpty ||
          _jobCategoryController.text.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Please fill in all fields',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .update({
          'jobTitle': _jobTitleController.text,
          'jobDEscription': _jobDescriptionController.text,
          'deadLineDAte': _jobDeadLineController.text,
          'DeadLineDateTimeStamp': deadLineDateTimeStamp,
          'jobCategory': _jobCategoryController.text,
        });

        Fluttertoast.showToast(
          msg: 'The job has been updated',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );

        Navigator.pop(
            context); // Return to the previous screen after successful update
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: 'An error occurred. Please try again later.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        print('Error updating job: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Job'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _textTitles(label: 'Job Category'),
                      _textFormField(
                        valueKey: 'jobCategory',
                        controller: _jobCategoryController,
                        enabled: false,
                        fct: () {
                          _showTaskCategoriesDialog(size: size);
                        },
                        maxLength: 50,
                      ),
                      _textTitles(label: 'Job Title'),
                      _textFormField(
                        valueKey: 'jobTitle',
                        controller: _jobTitleController,
                        enabled: true,
                        fct: () {},
                        maxLength: 50,
                      ),
                      _textTitles(label: 'Job Description'),
                      _textFormField(
                        valueKey: 'jobDescription',
                        controller: _jobDescriptionController,
                        enabled: true,
                        fct: () {},
                        maxLength: 500,
                      ),
                      _textTitles(label: 'Deadline'),
                      GestureDetector(
                        onTap: () {
                          _pickDateDialog();
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            key: ValueKey('jobDeadline'),
                            controller: _jobDeadLineController,
                            enabled: true,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateJob,
                        child: Text('Update Job'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
