import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isExhibitor = true;
  bool _isOrganizer = false;
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError("All fields must be filled in.");
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showError("Please enter a valid email address.");
      return;
    }

    // This checks for requirements, then accepts any length 12+ regardless of specific symbols
    // Added # to the allowed list inside the brackets []
    // This checks for requirements, then accepts any length 12+ regardless of specific symbols
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{12,}$');
    if (!passwordRegex.hasMatch(_passwordController.text.trim())) {
      _showError("Password must be 12+ chars, with Upper/Lower case, a number, and a special character.");
      return;
    }

    if (!_agreeToTerms) {
      _showError("Please agree to the terms and privacy policy.");
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String role = _isOrganizer ? 'Organizer' : 'Exhibitor';

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Clear the fields
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() => _agreeToTerms = false);

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created! Please sign in.")),
        );

        // Redirect to LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Registration failed.");
    } catch (e) {
      _showError("An error occurred: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          children: [
            const Text('Sign Up', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Pick your role, then enter your credentials.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _buildRoleCard("I'm an exhibitor", "I want to book booths and join trade shows.\n→ Browse live shows\n→ Pick booths on a map\n→ One-click checkout", _isExhibitor, () => setState(() { _isExhibitor = true; _isOrganizer = false; }))),
              const SizedBox(width: 12),
              Expanded(child: _buildRoleCard("I'm an organizer", "I host events and manage floor plans.\n→ Design floor plan\n→ Approve exhibitors\n→ Live dashboard", _isOrganizer, () => setState(() { _isExhibitor = false; _isOrganizer = true; }))),
            ]),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Name"),
                  TextField(controller: _nameController, decoration: _buildInputDecoration("Name")),
                  const SizedBox(height: 16),
                  _buildLabel("Email"),
                  TextField(controller: _emailController, decoration: _buildInputDecoration("name@example.com")),
                  const SizedBox(height: 16),
                  _buildLabel("Password"),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: _buildInputDecoration("Password").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: _agreeToTerms,
                    title: const Text("I agree to the MyExhibit terms of service.", style: TextStyle(fontSize: 13)),
                    onChanged: (val) => setState(() => _agreeToTerms = val!),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _handleSignUp,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E2E2E)),
                      child: const Text("Register", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildRoleCard(String title, String desc, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: isSelected ? 1.8 : 1.0)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: isSelected ? Colors.deepPurple : Colors.grey),
          ]),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 9.5, height: 1.3)),
        ]),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(hintText: hint, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10));
  }
}