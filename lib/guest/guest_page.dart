import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'all_upcoming_page.dart';
import 'all_ongoing_page.dart';
import 'exhibition_upcoming_page.dart';
import 'exhibition_ongoing_page.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'past_exhibition_page.dart';

class MyExhibitPage extends StatelessWidget {
  const MyExhibitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MyExhibit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: const Text('Sign In', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Navigation Cards (Upcoming/Ongoing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      Icons.calendar_month,
                      "Upcoming",
                      Colors.green, // Updated category card icon to match green
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AllUpcomingPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      Icons.sync,
                      "Ongoing",
                      Colors.blue, // Kept ongoing category card icon blue
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AllOngoingPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 2. Featured Exhibitions Section
            _buildSectionHeader("Featured Exhibitions"),
            _buildHorizontalExhibitionList("Upcoming"),
            const SizedBox(height: 12),
            _buildViewMoreButton(context, const AllUpcomingPage()),

            // 3. Current Exhibitions Section
            _buildSectionHeader("Current Exhibitions"),
            _buildHorizontalExhibitionList("Ongoing"),
            const SizedBox(height: 12),
            _buildViewMoreButton(context, const AllOngoingPage()),

            // 4. How to Participate Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("How to Participate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildStepItem(Icons.edit, "Sign Up", "Create your account"),
                  const Divider(),
                  _buildStepItem(Icons.location_on, "Select a Booth", "Choose your spot on the map"),
                  const Divider(),
                  _buildStepItem(Icons.check_box, "Confirm", "Book your participation"),
                ],
              ),
            ),

            // 5. Register Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                style: ButtonStyle(
                  // Handles background color changes dynamically based on state
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.grey[800]!; // Dark gray ripple on click/press
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.grey[900]!; // Slightly lighter black tint on hover
                    }
                    return Colors.black; // Default solid state
                  }),
                  // Adds a slight responsive shadow change when hovered or pressed
                  elevation: WidgetStateProperty.resolveWith<double>((states) {
                    if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                      return 4.0;
                    }
                    return 0.0;
                  }),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                child: const Text("Register Now", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                child: const Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    children: [
                      TextSpan(text: 'Sign In', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 6. Past Exhibitions Highlights
            const PastExhibitionsSlider(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper widget for Top Category Cards with dynamic onTap callback
  Widget _buildCategoryCard(IconData icon, String label, Color iconColor, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Helper widget for Section Headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Center(
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Horizontal List for Exhibitions – reads from Firestore
  Widget _buildHorizontalExhibitionList(String tag) {
    final bool isUpcoming = tag == "Upcoming";
    final Color themeColor = isUpcoming ? Colors.green : Colors.blue;
    final Color badgeBgColor = isUpcoming ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD);
    final String badgeLabel = isUpcoming ? 'UPCOMING' : 'LIVE NOW';

    return SizedBox(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('exhibitions').limit(8).snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No ${tag.toLowerCase()} exhibitions yet.',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            );
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] as String? ?? 'Exhibition';
              final startDate = data['startDate'] as String? ?? '';
              final endDate = data['endDate'] as String? ?? '';
              final dateLabel = startDate.isEmpty ? '' : '$startDate – $endDate';
              return Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(right: 12, bottom: 4),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => isUpcoming
                        ? ExhibitionDetailPage(docId: docs[index].id, data: data)
                        : ExhibitionOngoingPage(docId: docs[index].id, data: data)),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                            ),
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: themeColor.withOpacity(0.3), width: 0.5),
                              ),
                              child: Text(badgeLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: themeColor)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(dateLabel, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Updated Helper View More Button configuration
  Widget _buildViewMoreButton(BuildContext context, Widget destinationPage) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text("View More", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey[100], child: Icon(icon, size: 20, color: Colors.black)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
    );
  }
}

// --- The Auto-Sliding Slider Widget ---
class PastExhibitionsSlider extends StatefulWidget {
  const PastExhibitionsSlider({super.key});

  @override
  State<PastExhibitionsSlider> createState() => _PastExhibitionsSliderState();
}

class _PastExhibitionsSliderState extends State<PastExhibitionsSlider> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _highlights = [
    "Culture Fest 2026",
    "Tech Expo MIIT",
    "Heritage Night",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _highlights.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10, top: 16),
          child: Text("Past Exhibitions Highlights",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemCount: _highlights.length,
            itemBuilder: (context, index) {
              final titleText = _highlights[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PastExhibitionPage(title: titleText),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      titleText,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _highlights.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.black : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}