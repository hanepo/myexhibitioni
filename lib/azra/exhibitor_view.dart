import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// APPLICATION TAB  (filtered to this organizer's exhibitions)
// ─────────────────────────────────────────────
class ApplicationTabScreen extends StatefulWidget {
  final String organizerId;
  const ApplicationTabScreen({Key? key, required this.organizerId}) : super(key: key);

  @override
  State<ApplicationTabScreen> createState() => _ApplicationTabScreenState();
}

class _ApplicationTabScreenState extends State<ApplicationTabScreen> {
  List<String> _exhibitionIds = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadExhibitionIds();
  }

  Future<void> _loadExhibitionIds() async {
    final snap = await FirebaseFirestore.instance
        .collection('exhibitions')
        .where('organizerId', isEqualTo: widget.organizerId)
        .get();
    if (!mounted) return;
    setState(() {
      _exhibitionIds = snap.docs.map((d) => d.id).toList();
      _loaded = true;
    });
  }

  Stream<QuerySnapshot>? get _stream {
    if (!_loaded || _exhibitionIds.isEmpty) return null;
    final ids = _exhibitionIds.length > 30 ? _exhibitionIds.sublist(0, 30) : _exhibitionIds;
    return FirebaseFirestore.instance
        .collection('applications')
        .where('exhibitionId', whereIn: ids)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Application', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [Tab(text: 'All'), Tab(text: 'Pending'), Tab(text: 'Approved'), Tab(text: 'Rejected')],
          ),
        ),
        body: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : _exhibitionIds.isEmpty
                ? const Center(child: Text('No exhibitions yet.', style: TextStyle(color: Colors.grey)))
                : TabBarView(
                    children: [
                      _buildList(context, null),
                      _buildList(context, 'Pending'),
                      _buildList(context, 'Approved'),
                      _buildList(context, 'Rejected'),
                    ],
                  ),
      ),
    );
  }

  Widget _buildList(BuildContext context, String? statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snap.data?.docs ?? [];
        if (statusFilter != null) {
          docs = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == statusFilter).toList();
        }
        if (docs.isEmpty) {
          return const Center(child: Text('No applications found.', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] as String? ?? 'Pending';
            IconData icon = Icons.access_time;
            Color iconColor = Colors.orange;
            if (status == 'Approved') { icon = Icons.check_circle; iconColor = Colors.green; }
            if (status == 'Rejected') { icon = Icons.cancel; iconColor = Colors.red; }
            final createdAt = (data['createdAt'] as dynamic)?.toDate()?.toString().split(' ').first ?? '';
            return ListTile(
              leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(icon, color: iconColor, size: 20)),
              title: Text(data['companyName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                '${data['exhibitionTitle'] ?? ''}\nBooth: ${data['boothLabel'] ?? ''} · ${data['boothLocation'] ?? ''}',
                style: const TextStyle(fontSize: 12),
              ),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Submitted', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  Text(createdAt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExhibitorDetailAssessmentScreen(docId: doc.id, data: data))),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// EXHIBITOR TAB  (filtered to this organizer's exhibitions)
// ─────────────────────────────────────────────
class ExhibitorTabScreen extends StatefulWidget {
  final String organizerId;
  const ExhibitorTabScreen({Key? key, required this.organizerId}) : super(key: key);

  @override
  State<ExhibitorTabScreen> createState() => _ExhibitorTabScreenState();
}

class _ExhibitorTabScreenState extends State<ExhibitorTabScreen> {
  List<String> _exhibitionIds = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadExhibitionIds();
  }

  Future<void> _loadExhibitionIds() async {
    final snap = await FirebaseFirestore.instance
        .collection('exhibitions')
        .where('organizerId', isEqualTo: widget.organizerId)
        .get();
    if (!mounted) return;
    setState(() {
      _exhibitionIds = snap.docs.map((d) => d.id).toList();
      _loaded = true;
    });
  }

  Stream<QuerySnapshot>? get _stream {
    if (!_loaded || _exhibitionIds.isEmpty) return null;
    final ids = _exhibitionIds.length > 30 ? _exhibitionIds.sublist(0, 30) : _exhibitionIds;
    return FirebaseFirestore.instance
        .collection('applications')
        .where('exhibitionId', whereIn: ids)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exhibitor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [Tab(text: 'All'), Tab(text: 'Pending'), Tab(text: 'Approved'), Tab(text: 'Rejected')],
          ),
        ),
        body: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : _exhibitionIds.isEmpty
                ? const Center(child: Text('No exhibitions yet.', style: TextStyle(color: Colors.grey)))
                : TabBarView(
                    children: [
                      _buildList(context, null),
                      _buildList(context, 'Pending'),
                      _buildList(context, 'Approved'),
                      _buildList(context, 'Rejected'),
                    ],
                  ),
      ),
    );
  }

  Widget _buildList(BuildContext context, String? statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snap.data?.docs ?? [];
        if (statusFilter != null) {
          docs = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == statusFilter).toList();
        }
        if (docs.isEmpty) {
          return const Center(child: Text('No exhibitors found.', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as dynamic)?.toDate()?.toString().split(' ').first ?? '';
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['contactPerson'] ?? data['companyName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${data['companyName'] ?? ''}\n${data['exhibitionTitle'] ?? ''}\nSubmitted: $createdAt'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                isThreeLine: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExhibitorDetailAssessmentScreen(docId: doc.id, data: data))),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// EXHIBITOR DETAIL / ASSESSMENT SCREEN
// ─────────────────────────────────────────────
class ExhibitorDetailAssessmentScreen extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const ExhibitorDetailAssessmentScreen({Key? key, required this.docId, required this.data}) : super(key: key);

  void _reject(BuildContext context) {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reason for Rejection', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please specify the rationale for rejecting this application.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(controller: textCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter reason...')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('applications').doc(docId).update({
                'status': 'Rejected',
                'rejectionReason': textCtrl.text.trim(),
              });
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application rejected.')));
            },
            child: const Text('Submit Rejection', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _approve(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Approval', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Approve this exhibitor application?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('applications').doc(docId).update({
                'status': 'Approved',
                'rejectionReason': '',
              });
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application approved.')));
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'Pending';
    final rejectionReason = data['rejectionReason'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(data['companyName'] ?? 'Application Detail', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 24, backgroundColor: Colors.black12, child: Icon(Icons.business)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['contactPerson'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(data['companyName'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _row('Status', status),
            if ((data['exhibitionTitle'] as String? ?? '').isNotEmpty)
              _row('Exhibition', data['exhibitionTitle'] as String),
            _row('Booth', '${data['boothLabel'] ?? ''} (${data['boothSize'] ?? ''})'),
            _row('Location', data['boothLocation'] ?? ''),
            _row('Price', 'RM ${data['boothPrice'] ?? ''}'),
            _row('Contact Email', data['contactEmail'] ?? ''),
            _row('Contact Phone', data['contactPhone'] ?? ''),
            _row('Total Cost', 'RM ${data['totalCost'] ?? ''}'),
            const SizedBox(height: 12),
            const Text('Exhibit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(data['exhibitProfile'] ?? '', style: const TextStyle(color: Colors.black87)),
            if (rejectionReason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                child: Text('Rejection Reason: $rejectionReason', style: TextStyle(color: Colors.red.shade800, fontSize: 13)),
              ),
            ],
            if (status == 'Pending') ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () => _reject(context),
                    child: const Text('Reject Application'),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () => _approve(context),
                    child: const Text('Approve Application', style: TextStyle(color: Colors.white)),
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
