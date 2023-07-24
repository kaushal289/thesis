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
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('losts').get();

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
        final location = document['location'].toString().toLowerCase();
        final lostFound = document['lostfound'].toString().toLowerCase();
        final ownerStatus = document['ownerstatus'].toString().toLowerCase();
        final moreInformation = document['moreInformation'].toString().toLowerCase();

        return email.contains(query) ||
            company.contains(query) ||
            color.contains(query) ||
            model.contains(query) ||
            location.contains(query) ||
            lostFound.contains(query) ||
            ownerStatus.contains(query) ||
            moreInformation.contains(query);
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
            Text('Add lost or found here'),
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
            TextField(
              controller: searchController,
              onChanged: (value) {
                filterDocuments(value.toLowerCase());
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  var document = filteredDocuments[index];
                  var imageUrl = document['image'];

                  return ListTile(
                    leading: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image_not_supported);
                            },
                          )
                        : Icon(Icons.image_not_supported),
                    title: Text('Company: ${document['company']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Color: ${document['color']}'),
                        Text('Email: ${document['email']}'),
                        Text('Model: ${document['model']}'),
                        Text('Location: ${document['location']}'),
                        Text('Lost/Found: ${document['lostfound']}'),
                        Text('Owner Status: ${document['ownerstatus']}'),
                        Text('More Information: ${document['moreInformation']}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
