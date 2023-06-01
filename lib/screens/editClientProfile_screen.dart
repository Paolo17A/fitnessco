// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import '../widgets/FitnesscoTextField_widget.dart';

class EditClientProfile extends StatefulWidget {
  final String uid;
  final void Function(String firstName, String lastName) onProfileUpdated;

  const EditClientProfile({
    Key? key,
    required this.uid,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditClientProfileState createState() => _EditClientProfileState();
}

class _EditClientProfileState extends State<EditClientProfile> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String _firstName = "";
  String _lastName = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      final userData = userSnapshot.data() as Map<String, dynamic>;
      _firstName = userData['firstName'] ?? "";
      _firstNameController.text = _firstName;

      _lastName = userData['lastName'] ?? "";
      _lastNameController.text = _lastName;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving membership statis: $e"),
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

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile information saved successfully')));
      widget.onProfileUpdated(_firstName, _lastName);
      Navigator.pop(context); // Navigate back to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
          : Container(
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
    );
  }
}
