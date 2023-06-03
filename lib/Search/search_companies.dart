import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:SELEDA/Widgets/all_companies_widgets.dart';
import 'package:SELEDA/Widgets/bottom_nav_bar.dart';

class AllWorkersScreen extends StatefulWidget {
  @override
  State<AllWorkersScreen> createState() => _AllWorkersScreenState();
}

class _AllWorkersScreenState extends State<AllWorkersScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = '';

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for companies...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildAction() {
    return <Widget>[
      IconButton(
        onPressed: (() {
          _clearSearchQuery();
        }),
        icon: Icon(Icons.clear),
      )
    ];
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);
    });
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
        bottomNavigationBar: BottomNavigationbarForApp(
          indexNum: 1,
        ),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green, // Light turquoise
                  Colors.green, // Dark turquoise
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          title: _buildSearchField(),
          actions: _buildAction(),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('name', isGreaterThanOrEqualTo: searchQuery)
              .where('name', isLessThan: searchQuery + 'z')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AllWorkersWidget(
                      userID: snapshot.data!.docs[index]['id'],
                      userName: snapshot.data!.docs[index]['name'],
                      userEmail: snapshot.data!.docs[index]['email'],
                      phoneNumber: snapshot.data!.docs[index]['phoneNumber'],
                      userImageUrl: snapshot.data!.docs[index]['userImage'],
                    );
                  },
                );
              } else {
                return Center(
                  child: Text('There are no users'),
                );
              }
            }
            return Center(
              child: Text('Something went wrong'),
            );
          },
        ),
      ),
    );
  }
}
