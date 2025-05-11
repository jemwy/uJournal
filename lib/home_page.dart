import 'package:finpro_cs4750/choose_entry.dart';
import 'package:finpro_cs4750/main.dart';
import 'package:flutter/material.dart';
import 'package:finpro_cs4750/profile_page.dart';
import 'package:finpro_cs4750/new_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String newEntry = "new journal entry";
  bool alrWritten = false;
  String docId = DateTime.now().toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection("users").doc(uid).collection("entries").doc(docId).get();

    setState(() {
      if(doc.exists) {
        newEntry = 'entry written for the day';
        alrWritten = true;
      } else {
        newEntry = "new journal entry";
        alrWritten = false;
      }
    });
  }

  Future<void> deleteUserAndSubcollections(String uID) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uID);
    final entriesCollection = userDoc.collection('entries');
    final profileImageRef = FirebaseStorage.instance.ref().child('profile_images').child(uID);

    try {
      // Step 1: Get all entries
      final entriesSnapshot = await entriesCollection.get();

      // Step 2: Delete each entry
      for (var doc in entriesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Step 3: Delete profile image from Firebase Storage
      try {
        await profileImageRef.delete();
        print('Profile image deleted.');
      } catch (e) {
        print('No profile image found or error deleting image: $e');
      }

      // Step 4: Delete the user document
      await userDoc.delete();

      print('User and subcollections deleted.');
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }

  Future<void> deleteCurrentUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        print("Auth user deleted.");
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Error deleting Firebase Auth user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              SizedBox(height: 30),
              Expanded(
                flex: 10,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfilePage()),
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.brown,
                            child: Icon(Icons.person, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    // Text(
                    //   '${DateTime.now().year} / ${DateTime.now().month} / ${DateTime.now().day}'
                    // ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white60, // Background color
                        border: Border.all(color: Colors.black, width: 1.5), // Border color & width
                        borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                      ),
                      child: Text(
                        '${DateTime.now().year} / ${DateTime.now().month} / ${DateTime.now().day}',
                        style: GoogleFonts.merriweather(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChooseEntry()),
                        );
                      },
                      icon: Icon(
                        Icons.book_outlined,
                        size: 50,
                        color: Colors.brown[700],
                      )
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 30,
                child: Row(
                  children: [

                  ],
                ),
              ),
              Expanded(
                flex: 10,
                child: OutlinedButton(
                  onPressed: () {
                    loadUserData();

                    if (!alrWritten) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewEntry()),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white60, // Set white background
                    shape: StadiumBorder(),
                  ),
                  child: Text(
                      newEntry,
                    style: GoogleFonts.merriweather(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  )
                )
              ),
              Expanded(
                flex: 30,
                child: Row(
                  children: [

                  ],
                ),
              ),
              Expanded(
                flex: 10,
                child: Row(
                  children: [

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Log Out'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage(title: 'LoginPage')),
                              (route) => false,
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('Delete Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  'WARNING. ALL ENTRIES WILL BE DELETED.',
                              ),
                              content: Text(
                                  'PLEASE CONFIRM REMOVAL OF YOUR ACCOUNT.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close dialog
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green, // Text color
                                  ),
                                  child: Text('GO BACK'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    deleteUserAndSubcollections(
                                        FirebaseAuth.instance.currentUser!.uid
                                    );

                                    deleteCurrentUser();

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginPage(title: 'LoginPage')),
                                          (route) => false,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red, // Text color
                                  ),
                                  child: Text('DELETE FOREVER'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
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
