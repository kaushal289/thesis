import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddLostPage extends StatefulWidget {
  AddLostPage({Key? key}) : super(key: key);

  @override
  _AddLostPageState createState() => _AddLostPageState();
}

class _AddLostPageState extends State<AddLostPage> {
  final _formKey = GlobalKey<FormState>();

  var email = "";
  var company = "";
  var color = "";
  var model = "";
  var ownerstatus = "";
  String imageUrl = '';


  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final colorController = TextEditingController();
  final modelController = TextEditingController();
  final ownerstatusController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set the initial text for the emailController
    final emails = FirebaseAuth.instance.currentUser!.email;
    emailController.text = '$emails';
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    companyController.dispose();
    colorController.dispose();
    modelController.dispose();
    ownerstatusController.dispose();
    super.dispose();
  }

  clearText() {
    emailController.clear();
    companyController.clear();
    colorController.clear();
    modelController.clear();
    ownerstatusController.clear();
  }

  // Adding Lost
  CollectionReference losts = FirebaseFirestore.instance.collection('losts');

  Future<void> addLost() async {
    try {
      await losts.add({
        'email': email,
        'company': company,
        'color': color,
        'model': model,
        'ownerstatus': ownerstatus,
        
      });
      print('Lost Added');
    } catch (error) {
      print('Failed to Add Lost: $error');
      // Handle the error here, such as showing a dialog or displaying an error message.
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Lost"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ListView(
            children: [
              IconButton(
                onPressed: () async {
                  // Step 1: Pick/Capture an image (image_picker)
                  ImagePicker imagePicker = ImagePicker();
                  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
                  print('${file?.path}');

                  if (file == null) return;

                  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

                  // Step 2: Upload to Firebase storage
                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference referenceDirImages = referenceRoot.child('Lostimages');
                  Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

                  try {
                    await referenceImageToUpload.putFile(File(file.path));
                    imageUrl = await referenceImageToUpload.getDownloadURL();
                  } catch (error) {
                    // Handle error
                  }
                },
                icon: Icon(Icons.camera_alt),
              ),
              // Added code snippet ends here
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  decoration: const InputDecoration(
                    labelText: 'Email: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Company: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: companyController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter company';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Color: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: colorController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter color';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Model: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: modelController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter  model';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Owner Status: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: ownerstatusController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter owner status';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            email = emailController.text;
                            company = companyController.text;
                            color = colorController.text;
                            model = modelController.text;
                            ownerstatus = ownerstatusController.text;
                            addLost();
                            clearText();
                          });
                        }
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => {clearText()},
                      child: Text(
                        'Reset',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
