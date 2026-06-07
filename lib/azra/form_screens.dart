import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// CREATE EXHIBITION SCREEN
// ─────────────────────────────────────────────
class CreateExhibitionScreen extends StatefulWidget {
  const CreateExhibitionScreen({Key? key}) : super(key: key);

  @override
  State<CreateExhibitionScreen> createState() => _CreateExhibitionScreenState();
}

class _CreateExhibitionScreenState extends State<CreateExhibitionScreen> {
  int? selectedBoothNumber;
  bool _isSaving = false;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _premiumPriceCtrl = TextEditingController(text: '1000');
  final _standardPriceCtrl = TextEditingController(text: '500');
  final _premiumQtyCtrl = TextEditingController(text: '10');
  final _standardQtyCtrl = TextEditingController(text: '24');

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _venueCtrl.dispose();
    _premiumPriceCtrl.dispose();
    _standardPriceCtrl.dispose();
    _premiumQtyCtrl.dispose();
    _standardQtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveExhibition() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exhibition title is required.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('exhibitions').add({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'startDate': _startDateCtrl.text.trim(),
        'endDate': _endDateCtrl.text.trim(),
        'venue': _venueCtrl.text.trim(),
        'premiumPrice': 'RM ${_premiumPriceCtrl.text.trim()}',
        'standardPrice': 'RM ${_standardPriceCtrl.text.trim()}',
        'premiumQty': _premiumQtyCtrl.text.trim(),
        'standardQty': _standardQtyCtrl.text.trim(),
        'status': 'Published',
        'organizerId': user?.uid ?? '',
        'organizerName': user?.email ?? 'Unknown',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exhibition created successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving exhibition: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmSave(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Exhibition', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Save this exhibition and publish it to the platform?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
            onPressed: () { Navigator.pop(ctx); _saveExhibition(); },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDiscard(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Changes', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('All entered data will be lost. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Exhibition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Exhibition Title'),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'Enter exhibition name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            _label('Event Description'),
            TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Describe the exhibition...', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Start Date'),
                      TextField(
                        controller: _startDateCtrl,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) _startDateCtrl.text = picked.toIso8601String().split('T').first;
                        },
                        decoration: const InputDecoration(hintText: 'YYYY-MM-DD', suffixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('End Date'),
                      TextField(
                        controller: _endDateCtrl,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) _endDateCtrl.text = picked.toIso8601String().split('T').first;
                        },
                        decoration: const InputDecoration(hintText: 'YYYY-MM-DD', suffixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Venue Location'),
            TextField(controller: _venueCtrl, decoration: const InputDecoration(hintText: 'Enter venue name or address', suffixIcon: Icon(Icons.location_on), border: OutlineInputBorder())),
            const SizedBox(height: 24),
            const Divider(),
            _label('Booth Pricing & Allocations'),
            Row(
              children: [
                Expanded(child: _buildBoothBox('Premium Booth', _premiumPriceCtrl, _premiumQtyCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildBoothBox('Standard Booth', _standardPriceCtrl, _standardQtyCtrl)),
              ],
            ),
            const SizedBox(height: 20),
            _label('Floor Map Preview'),
            _buildFloorMapGrid(),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () => _confirmDiscard(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: _isSaving ? null : () => _confirmSave(context),
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Event', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _label(String txt) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 4),
    child: Text(txt, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildBoothBox(String title, TextEditingController priceCtrl, TextEditingController qtyCtrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (RM)', isDense: true, border: UnderlineInputBorder())),
          const SizedBox(height: 4),
          TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Available Qty', isDense: true, border: UnderlineInputBorder())),
        ],
      ),
    );
  }

  Widget _buildFloorMapGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade300,
            child: const Center(child: Text('MAIN STAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.2),
            itemCount: 12,
            itemBuilder: (context, index) {
              final boothNo = index + 1;
              final isSelected = selectedBoothNumber == boothNo;
              return GestureDetector(
                onTap: () => setState(() => selectedBoothNumber = boothNo),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade400 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isSelected ? Colors.green.shade700 : Colors.transparent, width: 2),
                  ),
                  child: Center(
                    child: Text('A-$boothNo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(Colors.green.shade400, 'Selected'),
              const SizedBox(width: 16),
              _legend(Colors.grey.shade200, 'Available'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String t) => Row(
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(t, style: const TextStyle(fontSize: 11)),
    ],
  );
}

// ─────────────────────────────────────────────
// EDIT EXHIBITION SCREEN
// ─────────────────────────────────────────────
class EditExhibitionScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  const EditExhibitionScreen({Key? key, required this.docId, required this.data}) : super(key: key);

  @override
  State<EditExhibitionScreen> createState() => _EditExhibitionScreenState();
}

class _EditExhibitionScreenState extends State<EditExhibitionScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _startDateCtrl;
  late final TextEditingController _endDateCtrl;
  late final TextEditingController _venueCtrl;
  late final TextEditingController _premiumPriceCtrl;
  late final TextEditingController _standardPriceCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _titleCtrl = TextEditingController(text: d['title'] ?? '');
    _descCtrl = TextEditingController(text: d['description'] ?? d['desc'] ?? '');
    _startDateCtrl = TextEditingController(text: d['startDate'] ?? '');
    _endDateCtrl = TextEditingController(text: d['endDate'] ?? '');
    _venueCtrl = TextEditingController(text: d['venue'] ?? d['location'] ?? '');
    _premiumPriceCtrl = TextEditingController(text: d['premiumPrice'] ?? 'RM 1,000');
    _standardPriceCtrl = TextEditingController(text: d['standardPrice'] ?? 'RM 500');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _venueCtrl.dispose();
    _premiumPriceCtrl.dispose();
    _standardPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('exhibitions').doc(widget.docId).update({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'startDate': _startDateCtrl.text.trim(),
        'endDate': _endDateCtrl.text.trim(),
        'venue': _venueCtrl.text.trim(),
        'premiumPrice': _premiumPriceCtrl.text.trim(),
        'standardPrice': _standardPriceCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exhibition updated successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Exhibition', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            _label('Exhibition Title'),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 16),
            _label('Description'),
            TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Start Date'),
                      TextField(
                        controller: _startDateCtrl,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030));
                          if (picked != null) _startDateCtrl.text = picked.toIso8601String().split('T').first;
                        },
                        decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(), isDense: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('End Date'),
                      TextField(
                        controller: _endDateCtrl,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030));
                          if (picked != null) _endDateCtrl.text = picked.toIso8601String().split('T').first;
                        },
                        decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(), isDense: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Venue'),
            TextField(controller: _venueCtrl, decoration: const InputDecoration(suffixIcon: Icon(Icons.location_on, size: 18), border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Premium Price'),
                      TextField(controller: _premiumPriceCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Standard Price'),
                      TextField(controller: _standardPriceCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _label(String txt) => Padding(
    padding: const EdgeInsets.only(bottom: 4, top: 4),
    child: Text(txt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  );
}
