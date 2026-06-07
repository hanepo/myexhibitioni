import 'package:flutter/material.dart';

class PastExhibitionPage extends StatelessWidget {
  final String title;

  const PastExhibitionPage({
    super.key,
    this.title = "Culture Fest 2026", // Default fallback if no title is passed
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Image Placeholder Banner (Matches your gray theme)
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.grey[300],
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0), // Soft warm amber tint
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.withOpacity(0.4), width: 0.5),
                ),
                child: Text(
                  "COMPLETED EVENT",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // 2. Main Content Details Container
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exhibition Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Info Grid Box (Date & Venue)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.calendar_today_outlined, "Date Held", "14 - 16 March 2026"),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1),
                        ),
                        _buildInfoRow(Icons.location_on_outlined, "Location", "UniKL MIIT Main Hall, KL"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Event Description Section
                  const Text(
                    "About the Exhibition",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This exhibition showcased incredible projects, milestones, and cultural creative works. "
                        "It brought together hundreds of students, local community delegates, and international visitors "
                        "to celebrate innovation, heritage, and academic excellence within the university ecosystem.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // 4. Exhibition Highlights Bullet Section
                  const Text(
                    "Event Highlights & Achievements",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightBullet("Over 50+ unique creative exhibition booths installed."),
                  _buildHighlightBullet("Attracted more than 1,200 local and global attendees."),
                  _buildHighlightBullet("Awarded top outstanding student projects during the closing ceremony."),
                  _buildHighlightBullet("Interactive cultural presentation workshops hosted by international students."),

                  const SizedBox(height: 32),

                  // 5. Back to Dashboard Button (Matches your core design elements)
                  Center(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Back to Hub",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
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

  // Row helper helper layout for key details
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  // Bullet point helper layout
  Widget _buildHighlightBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: Icon(Icons.circle, size: 6, color: Colors.black),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}