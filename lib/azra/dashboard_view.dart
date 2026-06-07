import 'package:flutter/material.dart';
import 'exhibition_view.dart';
import 'form_screens.dart';

// Organizer Dashboard View with structural analytics and horizontal scroll cards
class OrganizerDashboardView extends StatelessWidget {
  const OrganizerDashboardView({Key? key}) : super(key: key);

  void _showDeleteRequestDialog(BuildContext context, String eventName) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Deletion: $eventName', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All deletions must be verified by the admin. Please state your reason below:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., Venue availability conflicts...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deletion request submitted to Admin.')),
              );
            },
            child: const Text('Submit Request', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectionReasonDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Admin Rejection Reason', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('"$reason"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFFCBD5E1),
                    child: Icon(Icons.business, color: Color(0xFF475569), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Muhd Ariff Aizat', style: Theme.of(context).textTheme.titleLarge),
                      Text('Welcome back!', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateExhibitionScreen())),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('New Exhibition', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Exhibition Statistics', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Text('Ongoing Exhibitions', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text('5', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF1E293B))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem(context, 'Pending', '2', const Color(0xFFD97706))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem(context, 'Approved', '5', const Color(0xFF10B981))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem(context, 'Rejected', '1', const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Exhibitions', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewAllExhibitionsGridScreen())),
                child: const Text('View More >', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 230,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildExhibitionCard(context, 'Technology Expo', 'Date: Oct 20-22, 2026', true),
                const SizedBox(width: 16),
                _buildExhibitionCard(context, 'Art & Creativity Fest', 'Date: Nov 10-12, 2026', true),
                const SizedBox(width: 16),
                _buildExhibitionCard(context, 'Global Business Summit', 'Date: Dec 05-08, 2026', false),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Application Status Tracker', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildApplicationStatusRow(context, 'SME Industrial Expo', 'Pending Review', 'Submitted: Oct 1', const Color(0xFFD97706), false),
              _buildApplicationStatusRow(context, 'AgroTech Malaysia', 'Rejected by Admin', 'Submitted: Oct 5', const Color(0xFFEF4444), true, 'The description text does not comply with safety rules.'),
              _buildApplicationStatusRow(context, 'EcoGreen Forum 2026', 'Pending Review', 'Submitted: Oct 7', const Color(0xFFD97706), false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildExhibitionCard(BuildContext context, String title, String date, bool isPublished) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewExhibitionDetailView())),
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                ),
                child: Stack(
                  children: [
                    const Center(child: Icon(Icons.image, size: 40, color: Color(0xFF94A3B8))),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPublished ? const Color(0xFF10B981) : const Color(0xFF64748B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPublished ? 'Published' : 'Draft',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, size: 16),
                        onSelected: (val) {
                          if (val == 'edit') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => EditExhibitionScreen(docId: '', data: const {})));
                          } else if (val == 'delete') {
                            _showDeleteRequestDialog(context, title);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit Event')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete Event', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationStatusRow(BuildContext context, String title, String status, String date, Color statusColor, bool actionable, [String failureReason = ""]) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: actionable ? () => _showRejectionReasonDialog(context, failureReason) : null,
        leading: Icon(Icons.history_toggle_off_rounded, color: statusColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Row(
          children: [
            Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
            if (actionable) const Text(' (Tap to view why)', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ),
    );
  }
}

// "View More" grid breakdown list screen
class ViewAllExhibitionsGridScreen extends StatelessWidget {
  const ViewAllExhibitionsGridScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Hosted Exhibitions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
        children: [
          _buildStaticGridCard(context, 'Technology Expo', 'Oct 20-22, 2026'),
          _buildStaticGridCard(context, 'Art & Creativity Fest', 'Nov 10-12, 2026'),
          _buildStaticGridCard(context, 'Global Business Summit', 'Dec 05-08, 2026'),
        ],
      ),
    );
  }

  Widget _buildStaticGridCard(BuildContext context, String title, String date) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Container(color: const Color(0xFFCBD5E1), child: const Center(child: Icon(Icons.image, color: Colors.white)))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}