import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/screens/forgot_password.dart';
import 'package:lostandfound/screens/signup.dart';
import 'package:lostandfound/screens/user/navigationbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  var email = "";
  var password = "";
  var saveCredentials = false; // Boolean variable to track checkbox state
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> saveLoginCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('login_email', email);
    prefs.setString('login_password', password);
  }

  Future<String?> getSavedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_email');
  }

  Future<String?> getSavedPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_password');
  }

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (saveCredentials) {
        await saveLoginCredentials(email, password);
      } else {
        await clearLoginCredentials(); // Clear saved credentials
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserMain(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("No User Found for that Email");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      } else if (e.code == 'wrong-password') {
        print("Wrong Password Provided by User");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      }
    }
  }

  Future<void> clearLoginCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('login_email');
    prefs.remove('login_password');
  }

  @override
  void initState() {
    super.initState();
    // Retrieve saved email and password from SharedPreferences
    getSavedEmail().then((value) {
      setState(() {
        email = value ?? "";
        emailController.text = email;
      });
    });

    getSavedPassword().then((value) {
      setState(() {
        password = value ?? "";
        passwordController.text = password;
      });
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isPasswordVisible = false; // Track password visibility state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Login"),
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ListView(
            children: [
              Image(
                image: AssetImage('assets/images/logo.png'),
                height: 300,
                width: 300,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Email: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Email';
                    } else if (!value.contains('@')) {
                      return 'Please Enter Valid Email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  obscureText: !isPasswordVisible, // Toggle password visibility
                  decoration: InputDecoration(
                    labelText: 'Password: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Password';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPassword(),
                          ),
                        )
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 16.0, color: Colors.red),
                      ),
                    ),
                    SizedBox(width: 16),
                    Checkbox(
                      value: saveCredentials,
                      onChanged: (bool? value) {
                        setState(() {
                          saveCredentials = value ?? false;
                        });
                      },
                    ),
                    Text('Remember me'),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState!.validate()) {
                          userLogin();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 24, 119, 242), // Set button color
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 23.0),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an Account? "),
                    TextButton(
                      onPressed: () => {
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, a, b) => Signup(),
                            transitionDuration: Duration(seconds: 0),
                          ),
                          (route) => false,
                        )
                      },
                      child: Text(
                        'Signup',
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
