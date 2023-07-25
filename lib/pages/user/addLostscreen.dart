import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lostandfound/pages/user/dashboard.dart';
import 'package:lostandfound/pages/user/user_main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;


class AddLostPage extends StatefulWidget {
  AddLostPage({Key? key}) : super(key: key);

  @override
  _AddLostPageState createState() => _AddLostPageState();
}

class _AddLostPageState extends State<AddLostPage> {
  final _formKey = GlobalKey<FormState>();

  var email = "";
  var company = "Samsung"; // Initial value for the dropdown
  var color = "";
  var model = "";
  var ownerstatus = "Not found"; // Default value for owner status
  var lostFoundOption = 'Lost';
  var moreInformation = ""; // To store more information about the item
  var location = ""; // To store location information

  String imageUrl = '';
  bool imageRequired = false; // Set imageRequired based on selected "Lost/Found" option

  List<String> lostFoundOptions = ['Lost', 'Found'];

  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final colorController = TextEditingController();
  final modelController = TextEditingController();
  final moreInformationController = TextEditingController();
  final locationController = TextEditingController();

  File? selectedImage;

  @override
  void initState() {
    super.initState();

    final emails = FirebaseAuth.instance.currentUser!.email;
    emailController.text = '$emails';
  }

  @override
  void dispose() {
    colorController.dispose();
    modelController.dispose();
    moreInformationController.dispose();
    locationController.dispose();
    super.dispose();
  }

  clearText() {
    colorController.clear();
    modelController.clear();
    moreInformationController.clear();
    locationController.clear();
    selectedImage = null; // Clear selected image when resetting the form
    imageUrl = '';
    setState(() {
      ownerstatus = 'Not found'; // Reset owner status to default value
    });
  }

  CollectionReference losts = FirebaseFirestore.instance.collection('losts');

  Future<void> addLost() async {
    try {
      String fcmToken = await getFCMToken();

    await losts.add({
      'email': email,
      'company': company,
      'color': color,
      'model': model,
      'ownerstatus': ownerstatus,
      'lostfound': lostFoundOption,
      'moreInformation': moreInformation,
      'location': location,
      'image': imageUrl,
      'fcmToken': fcmToken, // Save the FCM token in Firestore
    });

      // After adding the lost item to Firestore, check if it's found and send the notification
      if (lostFoundOption == 'Found') {
        QuerySnapshot querySnapshot = await losts
            .where('lostfound', isEqualTo: 'Lost')
            .where('color', isEqualTo: color)
            .where('model', isEqualTo: model)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((doc) async {
            print("this is working");
            String fcmToken = doc['fcmToken'];
         // Replace 'fcmToken' with the actual field name in your Firestore document that stores the FCM token for each user
            String lostItemMessage = 'The lost item you were looking for has been found!';
             // You can customize the message here if needed
            await sendPushNotification(fcmToken, lostItemMessage);
          });
        }
      }

      // Show a success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully Registered!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the Dashboard after a delay of 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserMain(),
          ),
        );
      });
    } catch (error) {
      print('Failed to Add Lost: $error');
    }
  }

  Future<void> uploadImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Lostimages');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await referenceImageToUpload.putFile(File(file.path));
      imageUrl = await referenceImageToUpload.getDownloadURL();
      setState(() {
        selectedImage = File(file.path);
      });
    } catch (error) {
      print('Failed to upload image: $error');
    }
  }

Future<String> getFCMToken() async {
  return await FirebaseMessaging.instance.getToken() ?? '';
}




Future<void> sendPushNotification(String fcmToken, String message) async {
    try {
      if (fcmToken == null || fcmToken.isEmpty) {
        print('FCM token is null or empty. Cannot send push notification.');
        return;
      }
      var messageData = {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'title': 'Item Found!',
        'body': message,
      };
      print(fcmToken);
      print(messageData);
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAhftfClQ:APA91bHAuhuGL1-eHsO_f0iu51oKKNLwwm6ucCBu6rMXLhmc5Nb-c3ntGyBpq3VLM6PaCwYyJGssUxEfh4c2FGsRqkwXHXnM9qkHS81zgvwc2fH5O6jAdd1lHVHODPXQ4TXJgz_5Xs5G', // Replace 'YOUR_SERVER_KEY' with your actual FCM server key
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': message,
              'title': 'Item Found!',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to': fcmToken,
          },
        ),
      );
      print('Push notification sent!');
    } catch (e) {
      print('Failed to send push notification: $e');
    }
  }





  String? validateOwnerStatus(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select owner status';
    }
    return null;
  }

  String? validateLostFound(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select lost or found';
    }
    return null;
  }

  String? validateImage(String? value) {
    if (imageRequired && selectedImage == null) {
      return 'Please select an image';
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

  @override
  Widget build(BuildContext context) {
    bool isFoundOptionSelected = lostFoundOption == 'Found';
    bool isImageSelected = selectedImage != null;

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
              if (isImageSelected)
                Column(
                  children: [
                    Image.file(
                      selectedImage!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                  ],
                )
              else
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await uploadImage();
                            },
                            iconSize: 100, // Adjust the size of the icon
                            icon: Icon(Icons.camera_alt),
                          ),
                          Text(
                            'Select Image',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isFoundOptionSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please select an image',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                  ],
                ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  enabled: false,
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
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Company: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
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
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
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
                  decoration: InputDecoration(
                    labelText: 'Model: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: modelController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter model';
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
                    labelText: 'Location: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: locationController,
                  validator: validateLocation,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Lost/Found: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  value: lostFoundOption,
                  onChanged: (newValue) {
                    setState(() {
                      lostFoundOption = newValue!;
                      // Set imageRequired based on selected "Lost/Found" option
                      imageRequired = lostFoundOption == 'Found';
                      // Reset image selection when changing the "Lost/Found" option
                      selectedImage = null;
                      imageUrl = '';
                    });
                  },
                  items: lostFoundOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: validateLostFound,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  maxLines: 5, // Set maxLines to make it a big text field
                  decoration: InputDecoration(
                    labelText: 'More Information: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: moreInformationController,
                  validator: validateMoreInformation,
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: isImageSelected || !isFoundOptionSelected
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  email = emailController.text;
                                  color = colorController.text;
                                  model = modelController.text;
                                  moreInformation = moreInformationController.text;
                                  location = locationController.text;
                                  addLost();
                                  clearText();
                                });
                              }
                            }
                          : null,
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
