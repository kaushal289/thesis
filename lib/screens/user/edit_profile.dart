import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lostandfound/screens/login.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  var newPassword = "";
  final newPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final contactController = TextEditingController();
  final locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch user information from Firestore on widget initialization
    fetchUserData();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    contactController.dispose();
    locationController.dispose();
    super.dispose();
  }

  final currentUser = FirebaseAuth.instance.currentUser;

  changePassword() async {
    try {
      await currentUser!.updatePassword(newPassword);
      FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            'Your Password has been Changed. Login again!',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } catch (e) {
      // Handle password change error
    }
  }

  final uid = FirebaseAuth.instance.currentUser!.uid;

  User? user = FirebaseAuth.instance.currentUser;

  // Function to fetch user information from Firebase Firestore
  fetchUserData() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      setState(() {
        firstNameController.text = userDoc['firstName'] ?? '';
        lastNameController.text = userDoc['lastName'] ?? '';
        contactController.text = userDoc['contact'] ?? '';
        locationController.text = userDoc['location'] ?? '';
      });
    } catch (e) {
      // Handle error while fetching user information
    }
  }

  // Custom validation for new password field
  String? validateNewPassword(String? value) {
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'Password should be at least 6 characters long';
    }
    return null;
  }

  // Function to update user information in Firebase Firestore
  updateUserInformation() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'contact': contactController.text,
        'location': locationController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'User information updated successfully!',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Failed to update user information. Please try again.',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Edit Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                autofocus: false,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password: ',
                  hintText: 'Enter New Password (optional)',
                  labelStyle: TextStyle(fontSize: 20.0),
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
                controller: newPasswordController,
                // New password field is not required, so we use the custom validation function.
                validator: validateNewPassword,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'First Name: ',
                  hintText: 'Enter First Name',
                  labelStyle: TextStyle(fontSize: 20.0),
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
                controller: firstNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter First Name';
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
                  labelText: 'Last Name: ',
                  hintText: 'Enter Last Name',
                  labelStyle: TextStyle(fontSize: 20.0),
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
                controller: lastNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Last Name';
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
                  labelText: 'Contact: ',
                  hintText: 'Enter Contact',
                  labelStyle: TextStyle(fontSize: 20.0),
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
                controller: contactController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Contact';
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
                  hintText: 'Enter Location',
                  labelStyle: TextStyle(fontSize: 20.0),
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
                controller: locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Location';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    newPassword = newPasswordController.text;
                  });
                  updateUserInformation();
                  if (newPassword.isNotEmpty) {
                    changePassword();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 24, 119, 242), // Set the same color here for consistency
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
              child: Text(
                'Update Information',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
