import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class frontJob extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Add your container properties here
      child: Scaffold(
        appBar: AppBar(
          title: Text('Job Screen'),
          backgroundColor: Colors.green[400],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final jobList = snapshot.data!.docs;
              if (jobList.isNotEmpty) {
                return ListView.builder(
                  itemCount: jobList.length,
                  itemBuilder: (context, index) {
                    final jobData =
                        jobList[index].data() as Map<String, dynamic>;
                    final jobTitle = jobData['jobTitle'] ?? 'No Title';
                    final jobDescription =
                        jobData['jobDEscription '] ?? 'No Description';
                    return JobWidget(
                      jobTitle: jobTitle,
                      jobDescription: jobDescription,
                      // Add other job details if needed
                    );
                  },
                );
              } else {
                return Center(child: Text('No jobs available'));
              }
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class JobWidget extends StatelessWidget {
  final String jobTitle;
  final String jobDescription;

  const JobWidget({
    required this.jobTitle,
    required this.jobDescription,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(jobTitle),
      subtitle: Text(jobDescription),
      // Add any other job details or UI components
    );
  }
}
