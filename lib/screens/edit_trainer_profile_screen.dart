import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/utils/remove_pic_dialogue.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/navigation_bar_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/color_utils.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../widgets/dropdown_widget.dart';
import '../widgets/fitnessco_textfield_widget.dart';

class EditTrainerProfile extends StatefulWidget {
  const EditTrainerProfile({
    Key? key,
  });

  @override
  _EditTrainerProfileState createState() => _EditTrainerProfileState();
}

class _EditTrainerProfileState extends State<EditTrainerProfile> {
  bool _isLoading = true;
  File? _imageFile;
  ImagePicker imagePicker = ImagePicker();
  String _profileImageURL = '';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String _firstName = "";
  String _lastName = "";
  String _sex = '';
  List<String> sexChoices = ['MALE', 'FEMALE'];
  final _ageController = TextEditingController();
  final _cellphoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  List<dynamic> certifications = [];
  List<dynamic> interests = [];
  List<dynamic> specialty = [];

  final _certificationsController = TextEditingController();
  final _interestsController = TextEditingController();
  final _specialtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userData = await getCurrentUserData();
      _firstName = userData['firstName'] ?? "";
      _firstNameController.text = _firstName;
      _lastName = userData['lastName'] ?? "";
      _lastNameController.text = _lastName;

      _profileImageURL = userData['profileImageURL'] as String;
      _sex = userData['profileDetails']['sex'];
      _ageController.text = (userData['profileDetails']['age']).toString();
      _cellphoneNumberController.text =
          userData['profileDetails']['contactNumber'];
      _addressController.text = userData['profileDetails']['address'];
      certifications =
          userData['profileDetails']['certifications'] as List<dynamic>;
      interests = userData['profileDetails']['interests'];
      specialty = userData['profileDetails']['specialty'];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      showErrorMessage(context, label: "Error retrieving user data");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _sex.isEmpty ||
        _ageController.text.isEmpty ||
        _cellphoneNumberController.text.isEmpty ||
        _addressController.text.isEmpty) {
      showErrorMessage(context, label: 'Pleae fill up all profile fields.');
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      _firstName = _firstNameController.text.isNotEmpty
          ? _firstNameController.text
          : _firstName;
      _lastName = _lastNameController.text.isNotEmpty
          ? _lastNameController.text
          : _lastName;
      await updateCurrentUserData({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'profileDetails': {
          'sex': _sex,
          'age': double.parse(_ageController.text),
          'contactNumber': _cellphoneNumberController.text,
          'address': _addressController.text,
          'certifications': certifications,
          'interests': interests,
          'specialty': specialty
        }
      });

      showSuccessMessage(context, label: "Successfully updated your profile!",
          onPress: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/trainerHome');
      });
    } catch (Error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: "Error retrieving user data");
    }
  }

  Future _addCertification() async {
    if (_certificationsController.text.isEmpty) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      certifications.add(_certificationsController.text.trim().toString());
      await _updateProfileDetails();

      showSuccessMessage(context,
          label: 'Successfully added certification.',
          onPress: () => Navigator.of(context).pop());
    } catch (error) {
      showErrorMessage(context, label: 'Error adding certification');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _deleteCertification(String entry) async {
    try {
      setState(() {
        _isLoading = true;
      });
      certifications.remove(entry);
      await _updateProfileDetails();
      Navigator.of(context).pop();
    } catch (error) {
      showErrorMessage(context, label: 'Error deleting certification');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _addInterest() async {
    if (_interestsController.text.isEmpty) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      interests.add(_interestsController.text.trim());
      await _updateProfileDetails();
      showSuccessMessage(context,
          label: 'Successfully added interest.',
          onPress: () => Navigator.of(context).pop());
    } catch (error) {
      showErrorMessage(context, label: 'Error adding interest');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _deleteInterest(String entry) async {
    try {
      setState(() {
        _isLoading = true;
      });
      interests.remove(entry);
      await _updateProfileDetails();
      Navigator.of(context).pop();
    } catch (error) {
      showErrorMessage(context, label: 'Error deleting interest');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _addSpecialty() async {
    if (_specialtyController.text.isEmpty) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      specialty.add(_specialtyController.text.trim());
      await _updateProfileDetails();
      showSuccessMessage(context,
          label: 'Successfully added specialty.',
          onPress: () => Navigator.of(context).pop());
    } catch (error) {
      showErrorMessage(context, label: 'Error adding specialty');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _deleteSpecialty(String entry) async {
    try {
      setState(() {
        _isLoading = true;
      });
      specialty.remove(entry);
      await _updateProfileDetails();
      Navigator.of(context).pop();
    } catch (error) {
      showErrorMessage(context, label: 'Error deleting specialty');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _updateProfileDetails() async {
    await updateCurrentUserData({
      'profileDetails': {
        'sex': _sex,
        'age': _ageController.text.isNotEmpty
            ? double.parse(_ageController.text)
            : 0,
        'contactNumber': _cellphoneNumberController.text,
        'address': _addressController.text,
        'certifications': certifications,
        'interests': interests,
        'specialty': specialty
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoading = true;
      });
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);

      final uploadTask = storageRef.putFile(_imageFile!);
      final taskSnapshot = await uploadTask.whenComplete(() {});

      //let the download URL of the uploaded image
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Update the user's data in Firestore with the image URL
      await updateCurrentUserData({
        'profileImageURL': downloadURL,
      });
      setState(() {
        _profileImageURL = downloadURL;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeProfilePic() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      await updateCurrentUserData({
        'profileImageURL': '',
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);

      await storageRef.delete();

      setState(() {
        _imageFile = null;
        _profileImageURL = '';
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error removing profile pic.')));
      setState(() {
        _imageFile = null;
        _profileImageURL = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/trainerHome');
        return true;
      },
      child: DefaultTabController(
          length: 4,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(),
            bottomNavigationBar: trainerNavBar(context, currentIndex: 2),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: stackedLoadingContainer(context, _isLoading, [
                userAuthBackgroundContainer(context,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Center(
                            child: futuraText('Edit Profile Description',
                                textStyle: whiteBoldStyle(size: 25))),
                        _profileImageContainer(),
                        _profileTabs(),
                        _confirmChangesButton()
                      ],
                    ))
              ]),
            ),
          )),
    );
  }

  Widget _profileImageContainer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: Row(children: [
              buildProfileImage(profileImageURL: _profileImageURL, radius: 50),
              const SizedBox(width: 10),
              SizedBox(
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: futuraText('UPLOAD',
                              textStyle: TextStyle(fontSize: 14)),
                        )),
                    if (_profileImageURL.isNotEmpty)
                      SizedBox(
                        height: 25,
                        child: ElevatedButton(
                            onPressed: () => removeProfilePicDialogue(context,
                                onRemove: _removeProfilePic),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: futuraText('REMOVE',
                                textStyle: TextStyle(fontSize: 10))),
                      ),
                  ],
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }

  Widget _profileTabs() {
    return roundedContainer(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.6,
        color: CustomColors.love.withOpacity(0.6),
        child: Column(
          children: [
            SizedBox(
              width: double.maxFinite,
              child: TabBar(tabs: [
                Tab(
                    child: futuraText('PROFILE',
                        textStyle: blackBoldStyle(size: 9))),
                Tab(
                    child: futuraText('CERTIFICA-\nTION',
                        textStyle: blackBoldStyle(size: 9))),
                Tab(
                    child: futuraText('INTERESTS',
                        textStyle: blackBoldStyle(size: 9))),
                Tab(
                    child: futuraText('TRAINING\nSPECIALTY',
                        textStyle: blackBoldStyle(size: 9))),
              ]),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.53,
              child: TabBarView(children: [
                _profileFields(),
                _certificationsContainer(),
                _interestsContainer(),
                _specialtyContainer()
              ]),
            )
          ],
        ));
  }

  Widget _profileFields() {
    return Container(
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(children: [futuraText('FIRST NAME')]),
            SizedBox(
                height: 30,
                child: fitnesscoTextField(
                    '', TextInputType.name, _firstNameController,
                    typeColor: Colors.black)),
            const SizedBox(height: 30),
            Row(children: [futuraText('LAST NAME')]),
            SizedBox(
                height: 30,
                child: fitnesscoTextField(
                    '', TextInputType.name, _lastNameController,
                    typeColor: Colors.black)),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    futuraText('SEX'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 30,
                      child: dropdownWidget(_sex, (val) {
                        setState(() {
                          _sex = val!;
                        });
                      }, sexChoices, _sex, false, padding: 0),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    futuraText('AGE'),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 30,
                        child: fitnesscoTextField(
                            '',
                            TextInputType.numberWithOptions(decimal: false),
                            _ageController,
                            typeColor: Colors.black))
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                futuraText('CELLPHONE NUMBER'),
                SizedBox(
                    height: 30,
                    child: fitnesscoTextField(
                        '',
                        TextInputType.numberWithOptions(decimal: false),
                        _cellphoneNumberController,
                        typeColor: Colors.black)),
                const SizedBox(height: 20),
                futuraText('ADDRESS'),
                SizedBox(
                    height: 30,
                    child: fitnesscoTextField(
                        '', TextInputType.streetAddress, _addressController,
                        typeColor: Colors.black)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _certificationsContainer() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    children: certifications
                        .map((cert) => trainerItemDeleter(
                              context,
                              item: cert,
                              onDelete: () => _deleteCertification(cert),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Center(
                                  child: Row(
                                    children: [
                                      futuraText(cert,
                                          textStyle: TextStyle(
                                              color: CustomColors.purpleSnail,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                      height: 30,
                      child: fitnesscoTextField(
                          '', TextInputType.text, _certificationsController,
                          typeColor: Colors.black))
                ],
              ),
              addEntryButton(_addCertification)
            ]));
  }

  Widget _interestsContainer() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    children: interests
                        .map((interest) => trainerItemDeleter(context,
                            onDelete: () => _deleteInterest(interest),
                            item: interest,
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Row(children: [
                                  futuraText(interest,
                                      textStyle: TextStyle(
                                          color: CustomColors.purpleSnail,
                                          fontWeight: FontWeight.bold)),
                                ]))))
                        .toList(),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                      height: 30,
                      child: fitnesscoTextField(
                          '', TextInputType.text, _interestsController,
                          typeColor: Colors.black))
                ],
              ),
              addEntryButton(_addInterest),
            ]));
  }

  Widget _specialtyContainer() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    children: specialty
                        .map((special) => trainerItemDeleter(
                              context,
                              onDelete: () => _deleteSpecialty(special),
                              item: special,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Row(children: [
                                  futuraText(special,
                                      textStyle: TextStyle(
                                          color: CustomColors.purpleSnail,
                                          fontWeight: FontWeight.bold))
                                ]),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                      height: 30,
                      child: fitnesscoTextField(
                          '', TextInputType.text, _specialtyController,
                          typeColor: Colors.black))
                ],
              ),
              addEntryButton(_addSpecialty),
            ]));
  }

  Widget _confirmChangesButton() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: gradientOvalButton(
          label: 'CONFIRM CHANGES',
          width: 250,
          height: 40,
          onTap: () => _updateProfile()),
    );
  }

  Widget addEntryButton(Function onPress) {
    return SizedBox(
        height: 30,
        child: ElevatedButton(
            onPressed: () => onPress(),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: futuraText('ADD', textStyle: whiteBoldStyle())));
  }
}
