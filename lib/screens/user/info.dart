import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  final DocumentSnapshot document;

  InfoScreen({required this.document});

  @override
  Widget build(BuildContext context) {
    var imageUrl = document['image'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 24, 119, 242),
        title: Center(child: Text('More Details')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageUrl != null
                  ? Align(
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: 1, // Set the scale value to adjust the image size (1.0 means original size).
                        child: Image.network(
                          imageUrl,
                          height: 300,
                          // Set the desired height of the image.
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              height: 300,
                              child: Transform.scale(
                                scale: 3.0, // Set the scale value to adjust the icon size.
                                child: Icon(Icons.image_not_supported, color: Colors.black),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Icon(Icons.image_not_supported),
              SizedBox(height: 16),
              buildInfoItem('Company:', document['company']),
              buildInfoItem('Color:', document['color']),
              buildInfoItem('Email:', document['email']),
              buildInfoItem('Model:', document['model']),
              buildInfoItem('Location:', document['location']),
              buildInfoItem('Lost/Found:', document['lostfound']),
              buildInfoItem('Owner Status:', document['ownerstatus']),
              buildInfoItem('More Information:', document['moreInformation']),
              if (document['contactNumber'] != null) // Conditionally show contactNumber
                buildInfoItem('Contact Number:', document['contactNumber']),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoItem(String label, String value) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8), // Add some space between label and value
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

