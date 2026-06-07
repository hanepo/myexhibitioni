import 'package:flutter/material.dart';

// Complete detail screen displaying description and sub-booth statistics
class ViewExhibitionDetailView extends StatefulWidget {
  const ViewExhibitionDetailView({Key? key}) : super(key: key);

  @override
  State<ViewExhibitionDetailView> createState() => _ViewExhibitionDetailViewState();
}

class _ViewExhibitionDetailViewState extends State<ViewExhibitionDetailView> {
  bool _isExpanded = false;
  final String _fullDesc = "The premium tech expo is a specialized ecosystem space, showcasing the latest digital transformations, emerging algorithmic tech, embedded infrastructure security systems, automated hardware arrays, and collaborative computing projects.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  color: const Color(0xFFCBD5E1),
                  child: const Center(child: Icon(Icons.landscape, size: 60, color: Color(0xFF94A3B8))),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tech Expo 2026', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.location_on, size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 4),
                      Text('Maeps, Serdang', style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(width: 24),
                      Icon(Icons.calendar_month, size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 4),
                      Text('March 23-25, 2026', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildOverlappingAvatars(),
                          const SizedBox(width: 8),
                          const Text('30+ Exhibitors Registered', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisteredExhibitorsListScreen())),
                        child: const Text('View all', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('About Event', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    _isExpanded ? _fullDesc : "${_fullDesc.substring(0, 100)}...",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Text(
                      _isExpanded ? "Read less" : "Read more",
                      style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Booth Types Configuration', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildBoothTypeCard('Premium Booth', '10 Available', 'RM 1,000/day', const Color(0xFFFEF3C7))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildBoothTypeCard('Standard Booth', '24 Available', 'RM 500/day', const Color(0xFFE2E8F0))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlappingAvatars() {
    return SizedBox(
      width: 80,
      height: 32,
      child: Stack(
        children: List.generate(3, (index) {
          return Positioned(
            left: index * 18,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFF1E293B),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 16, color: Colors.grey[600]),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBoothTypeCard(String typeName, String qtyLabel, String price, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: const Center(child: Icon(Icons.grid_view_rounded, size: 36, color: Color(0xFF475569))),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(4)),
                  child: Text(qtyLabel, style: const TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 6),
                Text(typeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(price, style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Exhibitors sub-registry view screen
class RegisteredExhibitorsListScreen extends StatelessWidget {
  const RegisteredExhibitorsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Exhibitors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: CircleAvatar(child: Text('X')), title: Text('XYZ Corp'), subtitle: Text('Booth Assignment: Premium A-15')),
          ListTile(leading: CircleAvatar(child: Text('A')), title: Text('ABC Ltd'), subtitle: Text('Booth Assignment: Standard B-02')),
          ListTile(leading: CircleAvatar(child: Text('Q')), title: Text('QTY Inc'), subtitle: Text('Booth Assignment: Premium A-18')),
        ],
      ),
    );
  }
}