// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageGymScreen extends StatefulWidget {
  const ManageGymScreen({super.key});
  @override
  ManageGymScreenState createState() => ManageGymScreenState();
}

class ManageGymScreenState extends State<ManageGymScreen> {
  final TextEditingController _membershipRateController =
      TextEditingController();
  final TextEditingController _commissionRateController =
      TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGymSettings();
  }

  void _fetchGymSettings() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('gym_settings')
          .doc('settings')
          .get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        _membershipRateController.text =
            data['membership_rate'].toStringAsFixed(2);
        _commissionRateController.text =
            data['commission_rate'].toStringAsFixed(2);
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

  void _saveGymSettings() async {
    // Store the gym settings in Firebase Firestore
    double membershipRate =
        double.tryParse(_membershipRateController.text) ?? 0.0;
    double commissionRate =
        double.tryParse(_commissionRateController.text) ?? 0.0;

    try {
      await FirebaseFirestore.instance
          .collection('gym_settings')
          .doc('settings')
          .set({
        'membership_rate': membershipRate,
        'commission_rate': commissionRate,
      });

      // Show a snackbar to indicate successful saving of gym settings
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gym settings saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving gym settings: $e')),
      );
    }
  }

  @override
  void dispose() {
    _membershipRateController.dispose();
    _commissionRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Gym'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: _membershipRateController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Membership Rate',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _commissionRateController,
                    decoration: const InputDecoration(
                      labelText: 'Trainer Commission Rate',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _saveGymSettings,
                    child: const Text('Save Gym Settings'),
                  ),
                ],
              ),
            ),
    );
  }
}
