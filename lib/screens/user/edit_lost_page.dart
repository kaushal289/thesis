import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lostandfound/screens/user/yourdata.dart';

class EditLostPage extends StatefulWidget {
  final DocumentSnapshot lostDocument;

  EditLostPage({required this.lostDocument});

  @override
  _EditLostPageState createState() => _EditLostPageState();
}

class _EditLostPageState extends State<EditLostPage> {
  final _formKey = GlobalKey<FormState>();

  late String email;
  late String company;
  late String color;
  late String model;
  late String ownerStatus;
  late String lostFoundOption;
  late String moreInformation;
  late String location;
  File? selectedImage;

  @override
  void initState() {
    super.initState();

    email = widget.lostDocument['email'];
    company = widget.lostDocument['company'];
    color = widget.lostDocument['color'];
    model = widget.lostDocument['model'];
    ownerStatus = widget.lostDocument['ownerstatus'];
    lostFoundOption = widget.lostDocument['lostfound'];
    moreInformation = widget.lostDocument['moreInformation'];
    location = widget.lostDocument['location'];
  }

  Future<void> updateLost() async {
    try {
      await widget.lostDocument.reference.update({
        'email': email,
        'company': company,
        'color': color,
        'model': model,
        'ownerstatus': ownerStatus,
        'lostfound': lostFoundOption,
        'moreInformation': moreInformation,
        'location': location,
      });
      print('Lost Updated');

      // Show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully Updated!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the YourData screen after a delay of 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => YourData(),
          ),
        );
      });
    } catch (error) {
      print('Failed to Update Lost: $error');
      // Show SnackBar for failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update Lost: $error'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = getImageUrl();

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Lost"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ListView(
            children: [
              // Show the selected image or "Select Image" if URL is empty
              if (selectedImage == null && imageUrl.isEmpty)
                Container(
                  alignment: Alignment.center,
                  height: 200,
                  child: Text('Select Image',
                      style: TextStyle(fontSize: 20, color: Colors.grey)),
                )
              else
                Container(
                  alignment: Alignment.center,
                  height: 200,
                  child: (selectedImage != null)
                      ? Image.file(selectedImage!)
                      : Image.network(imageUrl),
                ),
              SizedBox(height: 10),
              // Image selection button
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 10),

              // Email Field
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(
                    labelText: 'Email: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
              ),

              // Company Dropdown
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: DropdownButtonFormField<String>(
                  value: company,
                  onChanged: (newValue) {
                    setState(() {
                      company = newValue!;
                    });
                  },
                  items: [
                    'Samsung',
                    'Apple',
                    'Huawei',
                    'Xiaomi',
                    'Oppo',
                    'Vivo',
                    'OnePlus',
                    'Colors',
                    'Lenovo',
                    'Nokia',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a company';
                    }
                    return null;
                  },
                ),
              ),

              // Color Field
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  initialValue: color,
                  decoration: InputDecoration(
                    labelText: 'Color: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  onChanged: (value) {
                    setState(() {
                      color = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter color';
                    }
                    return null;
                  },
                ),
              ),

              // Model Field
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  initialValue: model,
                  decoration: InputDecoration(
                    labelText: 'Model: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  onChanged: (value) {
                    setState(() {
                      model = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter model';
                    }
                    return null;
                  },
                ),
              ),

              // Owner Status Dropdown
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: DropdownButtonFormField<String>(
                  value: ownerStatus,
                  onChanged: (newValue) {
                    setState(() {
                      ownerStatus = newValue!;
                    });
                  },
                  items: ['Found', 'Not found'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select owner status';
                    }
                    return null;
                  },
                ),
              ),

              // Location Field
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  initialValue: location,
                  decoration: InputDecoration(
                    labelText: 'Location: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  onChanged: (value) {
                    setState(() {
                      location = value;
                    });
                  },
                  validator: validateLocation,
                ),
              ),

              // Lost/Found Dropdown
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: DropdownButtonFormField<String>(
                  value: lostFoundOption,
                  onChanged: (newValue) {
                    setState(() {
                      lostFoundOption = newValue!;
                    });
                  },
                  items: ['Lost', 'Found'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: validateLostFound,
                ),
              ),

              // More Information Field
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  initialValue: moreInformation,
                  maxLines: 5, // Set maxLines to make it a big text field
                  decoration: InputDecoration(
                    labelText: 'More Information: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  onChanged: (value) {
                    setState(() {
                      moreInformation = value;
                    });
                  },
                  validator: validateMoreInformation,
                ),
              ),

              // Add a button to update the lost item
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateLost();
                  }
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getImageUrl() {
    final imageUrl = widget.lostDocument['image']?.toString();
    return imageUrl ?? '';
  }

  // Validation functions for the form fields
  String? validateLostFound(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select lost or found';
    }
    return null;
  }

  String? validateMoreInformation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter more information about the item';
    }
    return null;
  }

  String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter location information';
    }
    return null;
  }
}

