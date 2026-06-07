import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExhibitorApplicationFormPage extends StatefulWidget {
  final String boothLabel;
  final String boothSize;
  final String boothPrice;
  final String boothLocation;
  final String? exhibitionId;
  final String? exhibitionTitle;
  const ExhibitorApplicationFormPage({
    Key? key,
    required this.boothLabel,
    required this.boothSize,
    required this.boothPrice,
    required this.boothLocation,
    this.exhibitionId,
    this.exhibitionTitle,
  }) : super(key: key);

  @override
  State<ExhibitorApplicationFormPage> createState() =>
      _ExhibitorApplicationFormPageState();
}

class _ExhibitorApplicationFormPageState
    extends State<ExhibitorApplicationFormPage> {
  final _companyCtrl = TextEditingController();
  final _exhibitProfileCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _addTable = false;
  bool _addChair = false;
  bool _addSpotlight = false;
  bool _addTv = false;

  static const double _tableCost = 100;
  static const double _chairCost = 30;
  static const double _spotlightCost = 80;
  static const double _tvCost = 300;

  double get _addOnTotal =>
      (_addTable ? _tableCost : 0) +
      (_addChair ? _chairCost : 0) +
      (_addSpotlight ? _spotlightCost : 0) +
      (_addTv ? _tvCost : 0);

  double get _baseCost {
    final numStr = widget.boothPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numStr) ?? 500.0;
  }

  double get _totalCost => _baseCost + _addOnTotal;

  void _submit() {
    if (_companyCtrl.text.trim().isEmpty ||
        _contactCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all required fields.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Application',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Submit application for ${widget.boothLabel}?\n\nTotal: RM ${_totalCost.toStringAsFixed(2)}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('applications')
                    .add({
                  'exhibitorId': user.uid,
                  'exhibitorName': user.email ?? '',
                  'exhibitionId': widget.exhibitionId ?? '',
                  'exhibitionTitle': widget.exhibitionTitle ?? '',
                  'boothLabel': widget.boothLabel,
                  'boothSize': widget.boothSize,
                  'boothPrice': widget.boothPrice,
                  'boothLocation': widget.boothLocation,
                  'companyName': _companyCtrl.text.trim(),
                  'exhibitProfile': _exhibitProfileCtrl.text.trim(),
                  'contactPerson': _contactCtrl.text.trim(),
                  'contactEmail': _emailCtrl.text.trim(),
                  'contactPhone': _phoneCtrl.text.trim(),
                  'addons': [
                    if (_addTable) 'table',
                    if (_addChair) 'chair',
                    if (_addSpotlight) 'spotlight',
                    if (_addTv) 'tv',
                  ],
                  'totalCost': _totalCost,
                  'status': 'Pending',
                  'rejectionReason': '',
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Application submitted successfully!'),
                    backgroundColor: Colors.green),
              );
            },
            child:
                const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _exhibitProfileCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply For Booth',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booth Selected',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.boothLabel,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${widget.boothSize} | ${widget.boothPrice}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF5C4EBD)),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Company Informations',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _formField('Company Name *', _companyCtrl),
            _formField('Exhibit Profile *', _exhibitProfileCtrl),
            _formField('Contact Person *', _contactCtrl),
            _formField('Email *', _emailCtrl,
                keyboardType: TextInputType.emailAddress),
            _formField('Phone *', _phoneCtrl,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),

            const Text('Add Items (Optional)',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _AddOnRow(
              label: 'Additional table',
              price: 'RM ${_tableCost.toStringAsFixed(0)}',
              value: _addTable,
              onChanged: (v) => setState(() => _addTable = v!),
            ),
            _AddOnRow(
              label: 'Additional chair',
              price: 'RM ${_chairCost.toStringAsFixed(0)}',
              value: _addChair,
              onChanged: (v) => setState(() => _addChair = v!),
            ),
            _AddOnRow(
              label: 'Spotlight',
              price: 'RM ${_spotlightCost.toStringAsFixed(0)}',
              value: _addSpotlight,
              onChanged: (v) => setState(() => _addSpotlight = v!),
            ),
            _AddOnRow(
              label: 'TV (43")',
              price: 'RM ${_tvCost.toStringAsFixed(0)}',
              value: _addTv,
              onChanged: (v) => setState(() => _addTv = v!),
            ),
            const SizedBox(height: 20),

            const Text('Running Cost Estimate',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _costRow('Booth Fee', _baseCost),
                  if (_addTable) _costRow('Additional table', _tableCost),
                  if (_addChair) _costRow('Additional chair', _chairCost),
                  if (_addSpotlight) _costRow('Spotlight', _spotlightCost),
                  if (_addTv) _costRow('TV (43")', _tvCost),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('RM ${_totalCost.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Submit Application',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _formField(String hint, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  const BorderSide(color: Colors.black, width: 1.5)),
        ),
      ),
    );
  }

  Widget _costRow(String label, double amount) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 13)),
            Text('RM ${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      );
}

class _AddOnRow extends StatelessWidget {
  final String label;
  final String price;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _AddOnRow(
      {Key? key,
      required this.label,
      required this.price,
      required this.value,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(price,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Checkbox(
              value: value, activeColor: Colors.black, onChanged: onChanged),
        ],
      ),
    );
  }
}
