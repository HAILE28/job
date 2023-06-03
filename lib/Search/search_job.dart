import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:SELEDA/Jobs/jobs_screen.dart';
import 'package:SELEDA/Widgets/job_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:SELEDA/Widgets/job_widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery.toLowerCase();
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchQueryController,
          onChanged: updateSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search for jobs',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _clearSearchQuery,
            icon: Icon(Icons.clear),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('jobTitle', isGreaterThanOrEqualTo: searchQuery)
            .where('recuruitment', isEqualTo: true)
            .orderBy('jobTitle')
            .orderBy('ceeratedAt ', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final jobList = snapshot.data!.docs;

            if (jobList.isNotEmpty) {
              return ListView.builder(
                itemCount: jobList.length,
                itemBuilder: (BuildContext context, int index) {
                  final jobData = jobList[index].data() as Map<String, dynamic>;

                  return JobWidget(
                    jobTitle: jobData['jobTitle'],
                    jobDescribtion: jobData['jobDEscription '],
                    jobId: jobData['jobId '],
                    uploadedBy: jobData['upLoadBy'],
                    userImage: jobData['userImage'],
                    name: jobData['name'],
                    recruitment: jobData['recuruitment'],
                    email: jobData['email '],
                    location: jobData['location '],
                  );
                },
              );
            } else {
              return Center(
                child: Text('No jobs found'),
              );
            }
          }

          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
