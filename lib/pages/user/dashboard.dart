import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lostandfound/pages/user/addLostscreen.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late List<DocumentSnapshot> lostDocuments = []; // Initialize the list
  late List<DocumentSnapshot> filteredDocuments = []; // Initialize the filtered list
  late String currentUserEmail;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
    fetchLostData();
  }

  Future<void> fetchLostData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('losts')
          .get();

      setState(() {
        lostDocuments = querySnapshot.docs;
        filteredDocuments = lostDocuments;
      });
    } catch (error) {
      print('Failed to fetch lost data: $error');
    }
  }

  void filterDocuments(String query) {
    setState(() {
      filteredDocuments = lostDocuments.where((document) {
        final email = document['email'].toString().toLowerCase();
        final company = document['company'].toString().toLowerCase();
        final color = document['color'].toString().toLowerCase();
        final model = document['model'].toString().toLowerCase();
        return email.contains(query) ||
            company.contains(query) ||
            color.contains(query) ||
            model.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Flutter FireStore CRUD'),
            ElevatedButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddLostPage(),
                  ),
                )
              },
              child: Text('Add', style: TextStyle(fontSize: 20.0)),
              style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
            )
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              'Lost Items',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  filterDocuments(value.toLowerCase());
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (filteredDocuments.isNotEmpty) // Check if the filtered list is not empty
              Expanded(
                child: ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final lost = filteredDocuments[index];
                    final lostId = lost.id;
                    final email = lost['email'];
                    final company = lost['company'];
                    final color = lost['color'];
                    final model = lost['model'];
                    final ownerStatus = lost['ownerstatus'];

                    return Card(
                      child: ListTile(
                        title: Text('Email: $email'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Company: $company'),
                            Text('Color: $color'),
                            Text('Model: $model'),
                            Text('Owner Status: $ownerStatus'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (filteredDocuments.isEmpty) // Check if the filtered list is empty
              Text(
                'No lost data found',
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
