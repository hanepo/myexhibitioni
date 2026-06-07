import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_screens.dart';
import 'exhibitor_view.dart';
import '../guest/guest_page.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  int _currentIndex = 0;
  String _organizerName = '';

  Stream<QuerySnapshot<Map<String, dynamic>>> get _exhibitionsStream {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return FirebaseFirestore.instance
        .collection('exhibitions')
        .where('organizerId', isEqualTo: uid)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!mounted) return;
    setState(() => _organizerName = doc.data()?['name'] as String? ?? user.email ?? 'Organizer');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      _buildDashboardHome(context),
      const ApplicationTabScreen(),
      const ExhibitorTabScreen(),
      const OrganizerProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: children),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.file_upload), label: 'Application'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Exhibitor'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboardHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(radius: 24, backgroundColor: Color(0xFFE2E8F0)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_organizerName.isNotEmpty ? _organizerName : 'Organizer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Welcome back!', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateExhibitionScreen())),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('New Exhibition', style: TextStyle(color: Colors.white, fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text('Exhibition Statistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _exhibitionsStream,
              builder: (context, exSnap) {
                final exDocs = exSnap.data?.docs ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          const Text('My Exhibitions', style: TextStyle(color: Colors.grey)),
                          Text('${exDocs.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('applications').snapshots(),
                      builder: (context, appSnap) {
                        final appDocs = appSnap.data?.docs ?? [];
                        final pending = appDocs.where((d) => (d.data() as Map)['status'] == 'Pending').length;
                        final approved = appDocs.where((d) => (d.data() as Map)['status'] == 'Approved').length;
                        final rejected = appDocs.where((d) => (d.data() as Map)['status'] == 'Rejected').length;
                        return Row(
                          children: [
                            _buildStatBox('Pending', '$pending'),
                            const SizedBox(width: 8),
                            _buildStatBox('Approved', '$approved'),
                            const SizedBox(width: 8),
                            _buildStatBox('Rejected', '$rejected'),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Current Exhibitions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllHostedExhibitionsScreen())),
                          child: const Text('View More >', style: TextStyle(color: Colors.black, fontSize: 12)),
                        ),
                      ],
                    ),
                    exDocs.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('No exhibitions yet. Create one!', style: TextStyle(color: Colors.grey)),
                          )
                        : SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: exDocs.length,
                              itemBuilder: (context, index) {
                                final doc = exDocs[index];
                                final ex = doc.data();
                                return GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewExhibitionDetailsScreen(docId: doc.id, data: ex))),
                                  child: Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 90,
                                          color: const Color(0xFFF1F5F9),
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(6),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                                              child: Text(ex['status'] ?? 'Published', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(ex['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 2),
                                              Text('${ex['startDate'] ?? ''} – ${ex['endDate'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Application Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('applications').limit(5).snapshots(),
              builder: (context, snap) {
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Text('No applications yet.', style: TextStyle(color: Colors.grey, fontSize: 13));
                }
                return Column(
                  children: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final status = data['status'] as String? ?? 'Pending';
                    final company = data['companyName'] as String? ?? 'Unknown';
                    final date = (data['createdAt'] as dynamic)?.toDate()?.toString().split(' ').first ?? '';
                    return _buildApplicationRow('Application from $company', status, date);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // UPDATE 2: Application Status same color with Tab Application
  Widget _buildApplicationRow(String title, String subtitle, String date) {
    Color iconBgColor = Colors.orange.shade100;
    Color iconColor = Colors.orange;
    IconData statusIcon = Icons.access_time;

    if (subtitle.contains('Approved')) {
      iconBgColor = Colors.green.shade100;
      iconColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (subtitle.contains('Rejected')) {
      iconBgColor = Colors.red.shade100;
      iconColor = Colors.red;
      statusIcon = Icons.highlight_off;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconBgColor,
            child: Icon(statusIcon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Submitted on', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}

class AllHostedExhibitionsScreen extends StatelessWidget {
  const AllHostedExhibitionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Hosted Exhibitions', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('exhibitions')
            .where('organizerId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No exhibitions found.', style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final ex = doc.data();
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.business, color: Colors.blueGrey),
                  title: Text(ex['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${ex['venue'] ?? ''}\n${ex['startDate'] ?? ''} – ${ex['endDate'] ?? ''}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  isThreeLine: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewExhibitionDetailsScreen(docId: doc.id, data: ex))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ViewExhibitionDetailsScreen extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic> data;
  const ViewExhibitionDetailsScreen({Key? key, this.docId, required this.data}) : super(key: key);

  @override
  State<ViewExhibitionDetailsScreen> createState() => _ViewExhibitionDetailsScreenState();
}

class _ViewExhibitionDetailsScreenState extends State<ViewExhibitionDetailsScreen> {
  bool _isEditingInline = false;
  bool _isDescExpanded = false;
  int? selectedFloorMapBoothNo;

  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _descController;
  late TextEditingController _premiumPriceController;
  late TextEditingController _standardPriceController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data['title'] as String? ?? '');
    _locationController = TextEditingController(text: widget.data['venue'] as String? ?? '');
    _dateController = TextEditingController(text: '${widget.data['startDate'] ?? ''} – ${widget.data['endDate'] ?? ''}');
    _descController = TextEditingController(text: widget.data['description'] as String? ?? '');
    _premiumPriceController = TextEditingController(text: widget.data['premiumPrice'] as String? ?? '');
    _standardPriceController = TextEditingController(text: widget.data['standardPrice'] as String? ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _descController.dispose();
    _premiumPriceController.dispose();
    _standardPriceController.dispose();
    super.dispose();
  }

  void _showDeleteReasonDialog() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reason for Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for deleting this exhibition. This reason will be sent directly to the Admin system validation.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter rejection / deletion reason criteria...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.docId != null) {
                await FirebaseFirestore.instance.collection('exhibitions').doc(widget.docId).delete();
              }
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exhibition deleted.')));
            },
            child: const Text('Submit & Request Delete', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showInlineSaveChangesConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Changes', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to preserve and save the updated details for this exhibition configuration record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
            onPressed: () async {
              Navigator.pop(ctx);
              final updates = {
                'title': _titleController.text.trim(),
                'venue': _locationController.text.trim(),
                'startDate': _dateController.text.trim(),
                'description': _descController.text.trim(),
                'premiumPrice': _premiumPriceController.text.trim(),
                'standardPrice': _standardPriceController.text.trim(),
              };
              if (widget.docId != null) {
                await FirebaseFirestore.instance.collection('exhibitions').doc(widget.docId).update(updates);
              }
              if (!mounted) return;
              setState(() => _isEditingInline = false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exhibition updated.')));
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showRegisteredExhibitorsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registered Exhibitors List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Approved applications for this exhibition.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const Divider(),
            Expanded(
              child: widget.docId == null
                  ? const Center(child: Text('No data available.', style: TextStyle(color: Colors.grey)))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('applications')
                          .where('exhibitionId', isEqualTo: widget.docId)
                          .where('status', isEqualTo: 'Approved')
                          .snapshots(),
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final docs = snap.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('No approved exhibitors yet.', style: TextStyle(color: Colors.grey)));
                        }
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (ctx, i) {
                            final d = docs[i].data() as Map<String, dynamic>;
                            final company = d['companyName'] as String? ?? d['exhibitorName'] as String? ?? 'Unknown';
                            final booth   = d['boothLabel'] as String? ?? '—';
                            return _buildExhibitorRowItem(company, booth);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExhibitorRowItem(String comp, String booth) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFF1E293B), child: Icon(Icons.business, color: Colors.white, size: 16)),
        title: Text(comp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.indigo.shade200)),
          child: Text(booth, style: TextStyle(color: Colors.indigo.shade900, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildInlineInteractiveGridEditor() {
    const booths = ['E-1', 'E-2', 'E-3', 'E-4', 'E-5', 'E-6', 'E-7', 'E-8'];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Floor Map Allocation Blueprint', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                child: const Text('Interactive Mode', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),
          // Load reserved booths from Firestore for this exhibition
          StreamBuilder<QuerySnapshot>(
            stream: widget.docId != null
                ? FirebaseFirestore.instance
                    .collection('applications')
                    .where('exhibitionId', isEqualTo: widget.docId)
                    .where('status', whereIn: ['Pending', 'Approved'])
                    .snapshots()
                : const Stream.empty(),
            builder: (context, snap) {
              final reservedLabels = snap.data?.docs
                      .map((d) => (d.data() as Map<String, dynamic>)['boothLabel'] as String? ?? '')
                      .where((s) => s.isNotEmpty)
                      .toSet() ??
                  <String>{};
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.3),
                itemCount: booths.length,
                itemBuilder: (context, index) {
                  final label = booths[index];
                  final isReserved = reservedLabels.contains(label);
                  final isSelected = selectedFloorMapBoothNo == index + 1;

                  Color cellBg;
                  if (isReserved) {
                    cellBg = Colors.red.shade300;
                  } else if (isSelected) {
                    cellBg = Colors.green.shade400;
                  } else {
                    cellBg = Colors.grey.shade200;
                  }

                  return GestureDetector(
                    onTap: isReserved ? null : () => setState(() => selectedFloorMapBoothNo = index + 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cellBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: isSelected ? Colors.green.shade700 : Colors.black12,
                            width: isSelected ? 2 : 1),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(label,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: (isReserved || isSelected) ? Colors.white : Colors.black87)),
                            Text(
                              isReserved ? '(Reserved)' : isSelected ? '(Selected)' : '(Available)',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: (isReserved || isSelected) ? Colors.white70 : Colors.grey),
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
          const SizedBox(height: 8),
          Row(children: [
            _legendDot(Colors.grey.shade200, 'Available'),
            const SizedBox(width: 12),
            _legendDot(Colors.green.shade400, 'Selected'),
            const SizedBox(width: 12),
            _legendDot(Colors.red.shade300, 'Reserved'),
          ]),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2), border: Border.all(color: Colors.black12))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isEditingInline ? const Text('Modify Exhibition Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)) : Text(widget.data['title'] as String? ?? 'Exhibition', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  color: const Color(0xFFCBD5E1),
                  width: double.infinity,
                  child: const Center(child: Icon(Icons.image, size: 48, color: Colors.white)),
                ),
                if (_isEditingInline)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Media picker engine triggered for blueprint substitution.')));
                      },
                      icon: const Icon(Icons.photo_camera, size: 16, color: Colors.white),
                      label: const Text('Change Image', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditingInline) ...[
                    _buildFieldLabel('Exhibition Title / Header Entry'),
                    TextField(controller: _titleController, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Venue Complex'),
                              TextField(controller: _locationController, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Calendar Scheduling'),
                              TextField(controller: _dateController, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(widget.data['title'] as String? ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(widget.data['venue'] as String? ?? '', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${widget.data['startDate'] ?? ''} – ${widget.data['endDate'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 18),
                      const SizedBox(width: 6),
                      StreamBuilder<QuerySnapshot>(
                        stream: widget.docId != null
                            ? FirebaseFirestore.instance.collection('applications').where('exhibitionId', isEqualTo: widget.docId).snapshots()
                            : const Stream.empty(),
                        builder: (ctx, snap) {
                          final count = snap.data?.docs.length ?? 0;
                          return Text('$count Exhibitor${count == 1 ? '' : 's'} Applied', style: const TextStyle(fontWeight: FontWeight.w500));
                        },
                      ),
                      const Spacer(),
                      TextButton(onPressed: _showRegisteredExhibitorsBottomSheet, child: const Text('View all'))
                    ],
                  ),
                  const Divider(),
                  const Text('About Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (_isEditingInline) ...[
                    TextField(controller: _descController, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder())),
                  ] else ...[
                    Text(
                        widget.data['description'] as String? ?? '',
                        maxLines: _isDescExpanded ? null : 2,
                        overflow: _isDescExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87, height: 1.4)
                    ),
                    InkWell(
                      onTap: () => setState(() => _isDescExpanded = !_isDescExpanded),
                      child: Text(_isDescExpanded ? 'Read Less' : 'Read More', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                  const SizedBox(height: 20),
                  const Text('Booth Types Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildGridBoothBox('Premium Booth', _premiumPriceController, widget.data['premiumQty'] as String? ?? '—', Colors.amber.shade50, _isEditingInline),
                      const SizedBox(width: 12),
                      _buildGridBoothBox('Standard Booth', _standardPriceController, widget.data['standardQty'] as String? ?? '—', Colors.blueGrey.shade50, _isEditingInline),
                    ],
                  ),
                  if (_isEditingInline) ...[
                    const SizedBox(height: 20),
                    const Text('Modify Structural Layout Plan Grid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    _buildInlineInteractiveGridEditor(),
                  ],
                  if (widget.data['rejectedReason'] != null && widget.data['rejectedReason'].toString().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red.shade200), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.report_problem, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Reason for Rejection', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(widget.data['rejectedReason'], style: const TextStyle(color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_isEditingInline) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: () {
                              setState(() {
                                _titleController.text = widget.data['title'] as String? ?? '';
                                _locationController.text = widget.data['venue'] as String? ?? '';
                                _dateController.text = '${widget.data['startDate'] ?? ''} – ${widget.data['endDate'] ?? ''}';
                                _descController.text = widget.data['description'] as String? ?? '';
                                _premiumPriceController.text = widget.data['premiumPrice'] as String? ?? '';
                                _standardPriceController.text = widget.data['standardPrice'] as String? ?? '';
                                _isEditingInline = false;
                              });
                            },
                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: _showInlineSaveChangesConfirmation,
                            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                        onPressed: () => setState(() => _isEditingInline = true),
                        child: const Text('Edit Exhibition Details', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                        onPressed: _showDeleteReasonDialog,
                        child: const Text('Delete Exhibition', style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String s) => Padding(padding: const EdgeInsets.only(bottom: 4, top: 6), child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)));

  Widget _buildGridBoothBox(String type, TextEditingController ctrl, String qty, Color bg, bool isEditable) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            const Icon(Icons.grid_view, size: 28, color: Colors.black54),
            const SizedBox(height: 8),
            Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (isEditable) ...[
              TextField(controller: ctrl, style: const TextStyle(fontSize: 12), decoration: const InputDecoration(isDense: true, border: OutlineInputBorder())),
            ] else ...[
              Text('${ctrl.text}/day', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
              child: Text('$qty Available', style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

// STARTS HERE (Line 417)
// =========================================================================
// ORGANIZER PROFILE MODULE WITH INTEGRATED LOGOUT MECHANISM
// =========================================================================
class OrganizerProfileScreen extends StatefulWidget {
  const OrganizerProfileScreen({Key? key}) : super(key: key);

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isEditing = false;
  bool _loading = true;
  int _eventCount = 0;
  int _approvedCount = 0;
  int _exhibitorCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = userDoc.data() ?? {};

    final exSnap = await FirebaseFirestore.instance
        .collection('exhibitions')
        .where('organizerId', isEqualTo: uid)
        .get();

    final appSnap = await FirebaseFirestore.instance
        .collection('applications')
        .where('status', isEqualTo: 'Approved')
        .get();

    if (!mounted) return;
    setState(() {
      _nameCtrl.text = data['name'] as String? ?? user.displayName ?? '';
      _orgCtrl.text = data['company'] as String? ?? '';
      _emailCtrl.text = user.email ?? '';
      _phoneCtrl.text = data['phone'] as String? ?? '';
      _eventCount = exSnap.docs.length;
      _approvedCount = appSnap.docs.length;
      _exhibitorCount = appSnap.docs.length;
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': _nameCtrl.text.trim(),
      'company': _orgCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _orgCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of the Exhibition Management System?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.black),
            onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFCBD5E1),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(_nameCtrl.text.isEmpty ? 'Organizer' : _nameCtrl.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_orgCtrl.text.isEmpty ? '' : '${_orgCtrl.text} | '}Organizer', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                _buildStatBox('Events', '$_eventCount'),
                const SizedBox(width: 8),
                _buildStatBox('Booths Sold', '$_approvedCount'),
                const SizedBox(width: 8),
                _buildStatBox('Exhibitors', '$_exhibitorCount'),
              ],
            ),
            const SizedBox(height: 24),

            _buildProfileField('Full Name', _nameCtrl, Icons.edit),
            _buildProfileField('Organization Name', _orgCtrl, Icons.edit),
            _buildProfileField('Email', _emailCtrl, Icons.edit),
            _buildProfileField('Contact Number', _phoneCtrl, Icons.edit),

            const SizedBox(height: 32),

            // ADDED: Red-bordered Logout Button custom block layout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  foregroundColor: Colors.red,
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: () {
                  _showLogoutConfirmationDialog(context);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController ctrl, IconData icon, {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            enabled: _isEditing,
            obscureText: isObscure,
            decoration: InputDecoration(
              suffixIcon: Icon(icon, size: 18),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
// ENDS HERE (Line 565)
