import 'package:flutter/material.dart';

class PastExhibitionPage extends StatelessWidget {
  /// Real exhibition document data from Firestore.
  final Map<String, dynamic> data;

  const PastExhibitionPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'Exhibition';
    final venue = data['venue'] as String? ?? '—';
    final startDate = data['startDate'] as String? ?? '';
    final endDate = data['endDate'] as String? ?? '';
    final dateLabel = startDate.isEmpty ? '—' : '$startDate – $endDate';
    final description = data['description'] as String? ?? '';
    final imageUrl = data['imageUrl'] as String? ?? '';
    final organizerName = data['organizerName'] as String? ?? '';

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
            // 1. Top banner — real image if the organizer uploaded one
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.grey[300],
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
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
                  ),
                ],
              ),
            ),

            // 2. Main Content Details
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Info (real date & venue)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.calendar_today_outlined, "Date Held", dateLabel),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1),
                        ),
                        _buildInfoRow(Icons.location_on_outlined, "Location", venue),
                        if (organizerName.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1),
                          ),
                          _buildInfoRow(Icons.person_outline, "Organizer", organizerName),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Real Event Description
                  const Text(
                    "About the Exhibition",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description.isNotEmpty
                        ? description
                        : "No description was provided for this exhibition.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // 4. Back Button
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
        ),
      ],
    );
  }
}
