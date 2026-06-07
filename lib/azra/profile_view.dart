import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../guest/guest_page.dart';

class OrganizerProfileView extends StatefulWidget {
  const OrganizerProfileView({Key? key}) : super(key: key);

  @override
  State<OrganizerProfileView> createState() => _OrganizerProfileViewState();
}

class _OrganizerProfileViewState extends State<OrganizerProfileView> {
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isEditing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    setState(() {
      _nameCtrl.text = data['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? '';
      _companyCtrl.text = data['company'] ?? '';
      _emailCtrl.text = FirebaseAuth.instance.currentUser?.email ?? '';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameCtrl.text.trim(),
      'company': _companyCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MyExhibitPage()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.storefront, size: 40)),
          const SizedBox(height: 12),
          Text(_nameCtrl.text.isEmpty ? 'Organizer' : _nameCtrl.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Text('Organizer', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          _buildField('Full Name', _nameCtrl, _isEditing),
          const SizedBox(height: 12),
          _buildField('Company', _companyCtrl, _isEditing),
          const SizedBox(height: 12),
          _buildField('Email', _emailCtrl, false),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
                  child: Text(_isEditing ? 'Save Changes' : 'Edit Profile', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _confirmLogout,
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, bool enabled) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
