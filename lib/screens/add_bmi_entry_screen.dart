import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/bmi_history_screen.dart';
import 'package:flutter/material.dart';

class AddBMIEntryScreen extends StatefulWidget {
  final List<dynamic> currentBMIEntries;
  const AddBMIEntryScreen({super.key, required this.currentBMIEntries});

  @override
  State<AddBMIEntryScreen> createState() => _AddBMIEntryScreenState();
}

class _AddBMIEntryScreenState extends State<AddBMIEntryScreen> {
  //===============================================================================================
  bool _isLoading = false;
  final bmiController = TextEditingController();
  List<dynamic> localBMIEntries = [];
  //===============================================================================================

  @override
  void initState() {
    super.initState();
    localBMIEntries = widget.currentBMIEntries;
  }

  @override
  void dispose() {
    super.dispose();
    bmiController.dispose();
  }

  void _addBMIEntry() async {
    FocusScope.of(context).unfocus();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      //  First we must check if the input is valid
      if (bmiController.text.isEmpty || double.parse(bmiController.text) <= 0) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('The entered BMI value must be higher than zero')));
        bmiController.clear();
        return;
      }

      //  Set _isLoading value to true to display the loading panel
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> newBMI = {
        'dateTime': {
          'month': DateTime.now().month,
          'year': DateTime.now().year,
          'day': DateTime.now().day
        },
        'bmiValue': double.parse(bmiController.text)
      };

      //  We must check if the new BMI entry is a new one or is updating an earlier inputted entry
      bool isOverwriting = false;
      for (int i = 0; i < localBMIEntries.length; i++) {
        if (localBMIEntries[i]['dateTime']['month'] == DateTime.now().month &&
            localBMIEntries[i]['dateTime']['year'] == DateTime.now().year &&
            localBMIEntries[i]['dateTime']['day'] == DateTime.now().day) {
          isOverwriting = true;
          break;
        }
      }
      if (isOverwriting) {
        localBMIEntries[localBMIEntries.length - 1] = newBMI;
      } else {
        localBMIEntries.add(newBMI);
      }

      //  We update the BMI history in Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'bmiHistory': localBMIEntries});
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully updated BMI History')));

      //  Go back to the BMI History screen
      navigator.pop();
      navigator.pushReplacement(
          MaterialPageRoute(builder: ((context) => const BMIHistoryScreen())));
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error adding BMI entry: ${error.toString()}')));
      setState(() {
        _isLoading = false;
        bmiController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('New BMI Entry')),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Center(
                child: Column(
              children: [
                TextField(
                  controller: bmiController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Enter your BMI today'),
                ),
                ElevatedButton(
                    onPressed: _addBMIEntry, child: const Text('Add BMI Entry'))
              ],
            )),
          ),
          if (_isLoading)
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ]),
      ),
    );
  }
}
