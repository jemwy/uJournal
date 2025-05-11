import 'package:flutter/material.dart';
import 'package:finpro_cs4750/home_page.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class NewRegistration extends StatefulWidget {
  const NewRegistration({super.key});

  @override
  State<NewRegistration> createState() => _NewRegistrationState();
}

class _NewRegistrationState extends State<NewRegistration> {
  TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/home_page.jpg"), // Replace with your image path
            fit: BoxFit.cover, // Ensures the image covers the whole screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 300,),
              Expanded(
                flex: 60,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50], // Background color
                          border: Border.all(color: Colors.black, width: 0.5), // Border color & width
                          borderRadius: BorderRadius.circular(30), // Optional: rounded corners
                        ),
                        child: Text(
                          'Please type your name. You can change it later.',
                          style: GoogleFonts.merriweather(
                            color: Colors.grey[700],
                            fontSize: 25,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.grey[100],
                        margin: EdgeInsets.all(20),
                        child: TextFormField(
                          controller: name,
                          obscureText: false,
                          style: GoogleFonts.merriweather(
                              color: Colors.grey[700],
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Name',
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white)
                      ),
                      onPressed: () {
                        String uID = FirebaseAuth.instance.currentUser!.uid;

                        FirebaseFirestore.instance.collection('users')
                          .doc(uID).update({
                          'name' : name.text
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      },
                      child: Text(
                          'Submit',
                          style: GoogleFonts.merriweather(
                              color: Colors.grey[700],
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          )
                      )
                    )
                  ]
                ),
              ),
              Spacer(flex: 20,)
            ],
          )
        ),
      )
    );
  }
}
