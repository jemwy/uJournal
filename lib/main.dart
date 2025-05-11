import 'package:finpro_cs4750/new_registration.dart';
import 'package:flutter/material.dart';
import 'package:finpro_cs4750/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'uJournal',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const LoginPage(title: 'uJournal Demo Login Page'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/login_page.png"), // Replace with your image path
            fit: BoxFit.cover, // Ensures the image covers the whole screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: Text(
                    'uJournal',
                  style: GoogleFonts.merriweather(
                      color: Colors.black,
                      fontSize: 60,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.white60,
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    controller: usernameController,
                    obscureText: false,
                    style: GoogleFonts.merriweather(
                        color: Colors.grey[700],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      hintText: 'Email',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.white60,
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: GoogleFonts.merriweather(
                        color: Colors.grey[700],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      hintText: 'Password',
                    ),
                  ),
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.lightBlueAccent),
                  backgroundColor: WidgetStatePropertyAll(Colors.white60)
                ),
                onPressed: () {
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: usernameController.text, password: passwordController.text)
                    .then((value) async {

                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        if (user.emailVerified){
                          setState(() {
                            usernameController.dispose();
                            usernameController = TextEditingController();

                            passwordController.dispose();
                            passwordController = TextEditingController();
                          });

                          String uID = value.user!.uid;

                          DocumentSnapshot doc = await FirebaseFirestore.instance
                              .collection("users").doc(uID).get();

                          try {
                            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                            String? name = data['name'];

                            if (name != null && name != '') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MyHomePage()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NewRegistration()),
                              );
                            }
                          } catch (e) {
                            String uid = FirebaseAuth.instance.currentUser!.uid;

                            await FirebaseFirestore.instance.collection("users").doc(uid).set({
                              "name": null,
                              "email": usernameController.text,
                              "createdAt": FieldValue.serverTimestamp(),
                              "level" : 'Scribbler',
                              "no_entries" : 0,
                              "profileImageUrl" : ''
                            });

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => NewRegistration()),
                            );
                          }
                        } else {
                          user.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Login failed. Please verify email.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                  }).catchError((error) {
                    print(error.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login failed. Email or password is invalid.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                },
                child: Text(
                    'Login',
                    style: GoogleFonts.merriweather(
                        color: Colors.grey[700],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
              SizedBox(height: 10,),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.lightBlueAccent),
                  backgroundColor: WidgetStatePropertyAll(Colors.white60)
                ),
                onPressed: () {
                  FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: usernameController.text, password: passwordController.text)
                    .then((value) async {
                      String uid = FirebaseAuth.instance.currentUser!.uid;

                      await FirebaseFirestore.instance.collection("users").doc(uid).set({
                        "name": null,
                        "email": usernameController.text,
                        "createdAt": FieldValue.serverTimestamp(),
                        "level" : 'Scribbler',
                        "no_entries" : 0,
                        "profileImageUrl" : ''
                      });

                      FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: usernameController.text, password: passwordController.text)
                        .then((value) async {

                        User? user = FirebaseAuth.instance.currentUser;

                        if (user!= null && !user.emailVerified) {
                          user.sendEmailVerification();
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Successfully signed up user! Email verification link sent.'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        await FirebaseAuth.instance.signOut();
                      }).catchError((error) {

                      });
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Register failed. Email is invalid or already exists.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                },
                child: Text(
                    'Register',
                    style: GoogleFonts.merriweather(
                        color: Colors.grey[700],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
