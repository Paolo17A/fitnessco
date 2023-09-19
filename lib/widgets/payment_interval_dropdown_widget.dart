import 'package:flutter/material.dart';

class PaymentIntervalDropdownWidget extends StatefulWidget {
  final String selectedPaymentInterval;
  final void Function(String?)? onChanged;

  const PaymentIntervalDropdownWidget({
    Key? key,
    required this.selectedPaymentInterval,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<PaymentIntervalDropdownWidget> createState() =>
      _MembershipStatusDropdownState();
}

class _MembershipStatusDropdownState
    extends State<PaymentIntervalDropdownWidget> {
  late String _selectedPaymentInterval;

  @override
  void initState() {
    super.initState();
    _selectedPaymentInterval = widget.selectedPaymentInterval;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text(
            'Payment Plan:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPaymentInterval,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              onChanged: (String? newValue) {
                widget.onChanged!(newValue);
              },
              items: <String>[
                'DAILY',
                'WEEKLY',
                'MONTHLY',
                'DOWN WEEKLY',
                'DOWN MONTHLY'
              ].map<DropdownMenuItem<String>>((String value) {
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
