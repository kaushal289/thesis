import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/screens/login.dart';
import 'package:lostandfound/screens/user/edit_profile.dart';
import 'package:lostandfound/screens/user/dashboard.dart';
import 'package:lostandfound/screens/user/yourdata.dart';

class UserMain extends StatefulWidget {
  UserMain({Key? key}) : super(key: key);

  @override
  _UserMainState createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    Dashboard(),
    YourData(),
    ChangePassword(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    // Show confirmation dialog before logging out
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                  (route) => false,
                );
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lost and Found"),
        leading: Padding(
          padding: EdgeInsets.all(8.0), // Adjust padding as needed
          child: Image.asset('assets/images/logo.png'), // Replace 'assets/logo.png' with your logo asset path
        ),
        actions: [
          ElevatedButton(
            onPressed: _logout,
            child: Text(
              'Logout',
              style: TextStyle(
                color: const Color.fromARGB(255, 255, 121, 111),
                fontSize: 18,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent, // Set background color to transparent
              elevation: 0, // Remove shadow
            ),
          ),
        ],
        backgroundColor: Color.fromARGB(255, 24, 119, 242),
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.file_copy),
              label: 'My Data',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(255, 105, 255, 110),
          unselectedItemColor: Colors.white, // Set icon color to white
          onTap: _onItemTapped,
          backgroundColor: Color.fromARGB(255, 24, 119, 242), // Background color for the BottomNavigationBar
        ),
      ),
    );
  }
}
