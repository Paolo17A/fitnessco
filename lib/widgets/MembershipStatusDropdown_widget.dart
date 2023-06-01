// ignore_for_file: file_names

import 'package:flutter/material.dart';

class MembershipStatusDropdown extends StatefulWidget {
  final String selectedMembershipStatus;
  final void Function(String?)? onChanged;

  const MembershipStatusDropdown({
    Key? key,
    required this.selectedMembershipStatus,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<MembershipStatusDropdown> createState() =>
      _MembershipStatusDropdownState();
}

class _MembershipStatusDropdownState extends State<MembershipStatusDropdown> {
  late String _selectedMembershipStatus;

  @override
  void initState() {
    super.initState();
    _selectedMembershipStatus = widget.selectedMembershipStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text(
            'Membership Status:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: widget.selectedMembershipStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              onChanged: (String? newValue) {
                widget.onChanged!(newValue);
              },
              items: <String>['PAID', 'UNPAID']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
