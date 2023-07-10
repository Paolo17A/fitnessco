// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fitnessco/utils/remove_pic_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/color_utils.dart';
import '../widgets/FitnesscoTextField_widget.dart';
import 'clientHome_screen.dart';

class EditClientProfile extends StatefulWidget {
  const EditClientProfile({Key? key}) : super(key: key);

  @override
  _EditClientProfileState createState() => _EditClientProfileState();
}

class _EditClientProfileState extends State<EditClientProfile> {
  File? _imageFile;
  late ImagePicker imagePicker;
  late String _profileImageURL;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String _firstName = "";
  String _lastName = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      final userData = userSnapshot.data() as Map<String, dynamic>;
      _firstName = userData['firstName'] ?? "";
      _firstNameController.text = _firstName;

      _lastName = userData['lastName'] ?? "";
      _lastNameController.text = _lastName;

      final String profileImageURL = userData['profileImageURL'] as String;
      if (profileImageURL.isNotEmpty) {
        setState(() {
          _profileImageURL = profileImageURL;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving membership status: $e"),
        backgroundColor: Colors.purple,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    _firstName = _firstNameController.text.isNotEmpty
        ? _firstNameController.text
        : _firstName;
    _lastName = _lastNameController.text.isNotEmpty
        ? _lastNameController.text
        : _lastName;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
    });

    if (_imageFile != null) {
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);

      final uploadTask = storageRef.putFile(_imageFile!);
      final taskSnapshot = await uploadTask.whenComplete(() {});

      //let the download URL of the uploaded image
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Update the user's data in Firestore with the image URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'profileImageURL': downloadURL,
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile information saved successfully')));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ClientHomeScreen()),
        (Route<dynamic> route) => false);
  }

  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return CircleAvatar(radius: 100, backgroundImage: FileImage(_imageFile!));
    } else if (_profileImageURL != '') {
      return CircleAvatar(
        radius: 100,
        backgroundImage: NetworkImage(_profileImageURL),
      );
    } else {
      return const CircleAvatar(radius: 100, child: Icon(Icons.person));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    hexStringToColor("CB2B93"),
                    hexStringToColor("9546C4"),
                    hexStringToColor("5E61F4")
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16.0),
                        Align(
                          child:
                              SizedBox(width: 200, child: _buildProfileImage()),
                        ),
                        const SizedBox(height: 16.0),
                        if (_imageFile != null)
                          Align(
                            child: SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _imageFile = null;
                                    });
                                  },
                                  child: const Text('Remove Selected Picture')),
                            ),
                          ),
                        if (_imageFile == null && _profileImageURL != '')
                          Align(
                            child: SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                  onPressed: () =>
                                      removeProfilePicDialogue(context),
                                  child: const Text('Remove Current Picture')),
                            ),
                          ),
                        Align(
                          child: SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Upload Profile Picture'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        fitnesscoTextField(
                          'First Name',
                          Icons.person,
                          false,
                          _firstNameController,
                        ),
                        const SizedBox(height: 16.0),
                        fitnesscoTextField(
                          'Last Name',
                          Icons.person_outline,
                          false,
                          _lastNameController,
                        ),
                        const SizedBox(height: 32.0),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
