import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_lost_page.dart';

void main() {
  runApp(MaterialApp(
    home: YourData(),
  ));
}

class YourData extends StatefulWidget {
  YourData({Key? key}) : super(key: key);

  @override
  _YourDataState createState() => _YourDataState();
}

class _YourDataState extends State<YourData> {
  late List<DocumentSnapshot> lostDocuments = []; // Initialize the list

  late String currentUserEmail;

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
          .where('email', isEqualTo: currentUserEmail)
          .get();

      setState(() {
        lostDocuments = querySnapshot.docs;
      });
    } catch (error) {
      print('Failed to fetch lost data: $error');
    }
  }

  Future<void> deleteLost(String lostId) async {
    try {
      await FirebaseFirestore.instance.collection('losts').doc(lostId).delete();
      print('Lost with ID $lostId deleted successfully');
      fetchLostData(); // Refresh the data after deletion
    } catch (error) {
      print('Failed to delete lost: $error');
    }
  }

  Future<void> navigateToEditPage(DocumentSnapshot lostDocument) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLostPage(lostDocument: lostDocument),
      ),
    );
    fetchLostData(); // Refresh the data after navigating back from EditLostPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              'Your Added Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (lostDocuments.isNotEmpty) // Check if the list is not empty
              Expanded(
                child: ListView.builder(
                  itemCount: lostDocuments.length,
                  itemBuilder: (context, index) {
                    final lost = lostDocuments[index];
                    final lostId = lost.id;
                    final email = lost['email']?.toString() ?? 'N/A';
                    final company = lost['company']?.toString() ?? 'N/A';
                    final color = lost['color']?.toString() ?? 'N/A';
                    final model = lost['model']?.toString() ?? 'N/A';
                    final ownerStatus = lost['ownerstatus']?.toString() ?? 'N/A';
                    final imageUrl = lost['image']?.toString() ?? '';

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
                        leading: imageUrl.isNotEmpty
                            ? Image.network(imageUrl, height: 50, width: 50)
                            : Icon(Icons.image, size: 50),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                navigateToEditPage(lost);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteLost(lostId);
                              },
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (lostDocuments.isEmpty) // Check if the list is empty
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
