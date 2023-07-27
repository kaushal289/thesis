import 'package:flutter/material.dart';
import 'package:lostandfound/screens/login.dart';
import 'package:lostandfound/screens/onboardscreens/screentwo.dart';
import 'package:lostandfound/screens/onboardscreens/slaindingclippers.dart';

const double appPadding = 16.0;
const Color black = Colors.black;
const Color white = Colors.white;
const Color yellow = Colors.yellow;
const Color primaryBlue = Color.fromARGB(255, 24, 119, 242);
const Color highlightGreen = Color.fromARGB(255, 255, 179, 0);

class OnboardingScreenOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image(
                width: size.width,
                height: size.height * 0.7,
                fit: BoxFit.cover,
                image: AssetImage('assets/images/one.png'),
              ),
              ClipPath(
                clipper: SlandingClipper(),
                child: Container(
                  height: size.height * 0.3,
                  color: primaryBlue,
                ),
              )
            ],
          ),
          Positioned(
            top: size.height * 0.7,
            child: Container(
              width: size.width,
              padding: EdgeInsets.all(appPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Lost/Found',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: highlightGreen,
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text(
                    'This is an app where you can register your lost item. If it is found, a notification is sent to you online in you mobile app',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: appPadding / 4),
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    border: Border.all(color: black, width: 2),
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 0, 255, 8),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: appPadding / 4),
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    border: Border.all(color: black, width: 2),
                    shape: BoxShape.circle,
                    color: white,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: appPadding / 4),
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    shape: BoxShape.circle,
                    color: white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: appPadding * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to the login page when "Skip" is clicked
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Login(),
                        ),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: appPadding),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OnboardingScreenTwo(),
                        ),
                      );
                    },
                    backgroundColor: white,
                    child: Icon(
                      Icons.navigate_next_rounded,
                      color: black,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
