import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finpro_cs4750/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class NewEntry extends StatefulWidget {
  const NewEntry({super.key});

  @override
  State<NewEntry> createState() => _NewEntryState();
}

class _NewEntryState extends State<NewEntry> {
  TextEditingController _controller = TextEditingController();
  String prompt = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection("materials").doc("daily_prompts").get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    int promptIndex = DateTime.now().day % 7;
    setState(() {
      prompt = data['promptArr'][promptIndex];
    });
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources when the widget is removed from the tree
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/new_entry.png"), // Replace with your image path
            fit: BoxFit.cover, // Ensures the image covers the whole screen
          ),
        ),
        child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 100,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white60, // Background color
                      border: Border.all(color: Colors.black, width: 1.5), // Border color & width
                      borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                    ),
                    child: Text(
                      prompt,
                      style: GoogleFonts.merriweather(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: _controller,
                    maxLength: 500,
                    maxLines: null,  // Allow unlimited number of lines
                    minLines: 15,     // Minimum 15 lines visible by default
                    style: GoogleFonts.merriweather(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type your paragraph here...',
                      contentPadding: EdgeInsets.all(18.0),
                    ),
                    keyboardType: TextInputType.multiline, // Ensures multiple lines on mobile
                  ),
                ),
                Spacer(flex: 1),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text != '' && _controller.text.length >= 100) {
                      String docId = DateTime.now().toIso8601String().split('T')[0];
                      String uID = FirebaseAuth.instance.currentUser!.uid;

                      FirebaseFirestore.instance.collection('users')
                          .doc(uID).collection('entries').doc(docId).set({
                        'entry' : _controller.text,
                        'timestamp': FieldValue.serverTimestamp(),
                        'prompt' : prompt
                      });

                      FirebaseFirestore.instance.collection('users')
                          .doc(uID).update({
                        'no_entries' : FieldValue.increment(1)
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Entry is not long enough (at least 100 characters) or is empty.',
                            style: TextStyle(
                              color: Colors.white60
                            ),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  child: Text(
                      'Submit',
                    style: GoogleFonts.merriweather(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Spacer(flex: 1),
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
