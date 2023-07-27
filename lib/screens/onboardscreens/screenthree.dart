import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lostandfound/screens/login.dart';
import 'package:lostandfound/screens/onboardscreens/screenone.dart';
import 'package:lostandfound/screens/onboardscreens/slaindingclippers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Check for Errors
        if (snapshot.hasError) {
          print("Something Went Wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return MaterialApp(
          title: 'Flutter Firebase EMail Password Auth',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
          ),
          debugShowCheckedModeBanner: false,
          home: FutureBuilder(
            future: _checkOnboardingStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); // Replace this with a loading screen if needed
              }

              final hasShownOnboarding = snapshot.data as bool;
              return hasShownOnboarding ? Login() : OnboardingScreenThree();
            },
          ),
        );
      },
    );
  }

  // Check if the onboarding screen has been shown before
  Future<bool> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasShownOnboarding') ?? false;
  }
}

// Inside OnboardingScreenThree class
class OnboardingScreenThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image(
                  width: size.width,
                  height: size.height * 0.7,
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/three.png'),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: ClipPath(
                    clipper: SlandingClipper(),
                    child: Container(
                      height: size.height * 0.3,
                      color: Color.fromARGB(255, 24, 119, 242) // Replace with your desired color
                    ),
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
                      'How do you get notified',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 183, 0), // Replace with your desired color
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(
                      'If a similar item is found as your registered lost. Then this app automatically sends a notification to you.',
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
                        border: Border.all(color: Colors.black, width: 2),
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 255, 255, 255)), // Replace with your desired color
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: appPadding / 4),
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 255, 255, 255)), // Replace with your desired color
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: appPadding / 4),
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 0, 255, 8)), // Replace with your desired color
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
                    child: TextButton( // Replace FlatButton with TextButton
                      onPressed: () async {
                        // Set the 'hasShownOnboarding' flag to true
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('hasShownOnboarding', true);

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
                      onPressed: () async {
                        // Set the 'hasShownOnboarding' flag to true
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('hasShownOnboarding', true);

                        // Navigate to the login page when "Done" is clicked
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Login(),
                          ),
                        );
                      },
                      backgroundColor: Colors.white, // Replace with your desired color
                      child: Icon(
                        Icons.done_rounded,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
