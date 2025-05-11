import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finpro_cs4750/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finpro_cs4750/new_registration.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? entries;
  String? level;
  String? userImagePath;
  String imageUrl = '';
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users").doc(uid).get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      name = data['name'];
      entries = data['no_entries'].toString();
      level = data['level'];
      imageUrl = data['profileImageUrl'];
    });
  }


  Future<File?> pickAndCropImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child(userId);

    await ref.putFile(imageFile);
    return await ref.getDownloadURL(); // This is your image URL
  }

  Future<void> saveImageUrlToFirestore(String userId, String imageUrl) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profileImageUrl': imageUrl,
    });
  }

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
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/profile_header.png"), // Replace with your image path
                      fit: BoxFit.cover, // Ensures the image covers the whole screen
                    ),
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 350,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageUrl != ""
                                ? NetworkImage(imageUrl)
                                : AssetImage("assets/blank_pfp.png") as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ),
                    Positioned(
                      top: 315,
                      right: 10,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt),
                        color: Colors.brown[700],
                        onPressed: () async {
                          final image = await pickAndCropImage();
                          if (image != null) {
                            final url = await uploadProfileImage(image, userId);
                            if (url != null) {
                              await saveImageUrlToFirestore(userId, url);
                              setState(() {
                                imageUrl = url; // update state to show new image
                              });
                            }
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20), // Outer padding around all three
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to full width
                  children: [
                    Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.brown[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                  'Name: $name',
                                  style: GoogleFonts.merriweather(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.brown[300],
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => NewRegistration())
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.brown[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No. of Entries: $entries',
                        style: GoogleFonts.merriweather(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.brown[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Title: $level',
                        style: GoogleFonts.merriweather(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              )
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
