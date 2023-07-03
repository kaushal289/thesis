
import 'package:flutter/material.dart';
class DashboardScreen extends StatefulWidget {
  static const String route = "dashboardScreen";

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  // void show() {
  //   showSnackbar(context, 'Token : ${Constant.token}', Colors.yellow);
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event,size: 30),
            label: 'Your History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle,size: 30),
            label: 'Profile' ,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.map_rounded,size: 30),
          //   label: 'Our map' ,
          // ),
        ],
        selectedItemColor: Colors.white, 
        selectedLabelStyle: TextStyle(fontSize: 18),
        unselectedItemColor: Colors.black,
        unselectedLabelStyle: TextStyle(fontSize: 12),
        backgroundColor: Color.fromARGB(255, 0, 123, 255),
        onTap: (value) {
          setState(() {
            
          });
        },
      ),
    );
  }
}