import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finpro_cs4750/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseEntry extends StatefulWidget {
  const ChooseEntry({super.key});

  @override
  State<ChooseEntry> createState() => _ChooseEntryState();
}

class _ChooseEntryState extends State<ChooseEntry> {
  DateTime? selectedDate;
  String docId = "";
  String text = "";
  String prompt = '';

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025, 4, 29),
      lastDate: DateTime.now(),
    );

    setState(() {
      selectedDate = pickedDate;
      docId = selectedDate!.toIso8601String().split('T')[0];
      loadUserData();
    });
  }

  Future<void> loadUserData() async {
    String uID = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users')
        .doc(uID).collection('entries').doc(docId).get();

    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      setState(() {
        text = data['entry'];
        prompt = data['prompt'];
      });
    } catch(error) {
      setState(() {
        text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/new_entry.png"), // Replace with your image path
            fit: BoxFit.cover, // Ensures the image covers the whole screen
          ),
        ),
        child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 150,),
                Row(
                  children: [
                    Spacer(),
                    OutlinedButton(
                      onPressed: _selectDate,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white60,
                      ),
                      child: Text(
                        selectedDate != null
                            ? docId
                            : 'Select Date',
                        style: GoogleFonts.merriweather(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ),
                    SizedBox(width: 20,)
                  ],
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white60, // Background color
                      border: Border.all(color: Colors.black, width: 0.5), // Border color & width
                      borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                    ),
                    child: Text(
                        text != '' ? prompt : 'No prompt found.',
                      style: GoogleFonts.merriweather(
                          color: Colors.black,
                          fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    text != '' ? text : 'No entry found.',
                    style: GoogleFonts.merriweather(
                        color: Colors.black,
                        fontSize: 16,
                        height: 1.75,
                    ),
                  ),
                ),
                Spacer(flex: 1,),
                SizedBox(height: 150,)
              ],
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:() {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage())
          );
        },
        backgroundColor: Colors.brown[400],
        child: Icon(
          Icons.arrow_back,
          color: Colors.brown[800],
        ),
      ),
    );
  }
}
