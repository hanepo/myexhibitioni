import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../guest/guest_page.dart';
import '../azra/form_screens.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  void _navigateTo(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _AdminHomePage(onNavigate: _navigateTo),
      const _ManageEventsPage(),
      const _FloorMapPage(),
      const _ReservationPage(),
      const _AdminProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.museum), label: 'Floor Map'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Reservations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 1. ADMIN HOME
// ─────────────────────────────────────────────
class _AdminHomePage extends StatelessWidget {
  final void Function(int) onNavigate;
  const _AdminHomePage({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MyExhibit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_outlined, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('applications').where('status', isEqualTo: 'Approved').snapshots(),
              builder: (context, appSnap) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('exhibitions').snapshots(),
                  builder: (context, exSnap) {
                    final activeExhibitors = appSnap.data?.docs.length ?? 0;
                    final liveEvents = exSnap.data?.docs.length ?? 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MetricCircle(value: '$activeExhibitors', label: 'Active\nExhibitors'),
                        const _MetricCircle(value: '–', label: 'Visitor\nPasses'),
                        _MetricCircle(value: '$liveEvents', label: 'Live\nEvents'),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Management Panel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _ManagementCard(icon: Icons.calendar_today, title: 'MANAGE\nEvents', badge: 'Live', onTap: () => onNavigate(1)),
                _ManagementCard(icon: Icons.museum, title: 'LAYOUT PLAN\nFloor App', badge: 'Map Set', badgeColor: Colors.blue, onTap: () => onNavigate(2)),
                _ManagementCard(
                  icon: Icons.people,
                  title: 'ACCOUNTS\nUser Profiles',
                  badge: null,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementPage())),
                ),
                _ManagementCard(icon: Icons.receipt_long, title: 'BOOKINGS\nReservation', badge: 'New', badgeColor: Colors.green, onTap: () => onNavigate(3)),
                _ManagementCard(
                  icon: Icons.tune,
                  title: 'PRICING & SPECS\nBooth\nConfiguration',
                  badge: '2 Active Types',
                  badgeColor: Colors.grey,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBoothConfigPage())),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MetricCircle extends StatelessWidget {
  final String value;
  final String label;
  const _MetricCircle({Key? key, required this.value, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
          child: Center(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final Color badgeColor;
  final VoidCallback onTap;
  const _ManagementCard({Key? key, required this.icon, required this.title, required this.badge, this.badgeColor = Colors.orange, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: Colors.black87),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: badgeColor.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                    child: Text(badge!, style: TextStyle(fontSize: 9, color: badgeColor, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 3),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2. MANAGE EVENTS PAGE
// ─────────────────────────────────────────────
class _ManageEventsPage extends StatefulWidget {
  const _ManageEventsPage({Key? key}) : super(key: key);

  @override
  State<_ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<_ManageEventsPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Event', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search events...',
                hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('exhibitions').snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snap.data?.docs ?? [];
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final title = (data['title'] as String? ?? '').toLowerCase();
                    final venue = (data['venue'] as String? ?? '').toLowerCase();
                    return title.contains(_searchQuery) || venue.contains(_searchQuery);
                  }).toList();
                }
                if (docs.isEmpty) {
                  return const Center(child: Text('No events found.', style: TextStyle(color: Colors.grey)));
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${docs.length} event(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final ev = doc.data() as Map<String, dynamic>;
                            final status = ev['status'] as String? ?? 'Published';
                            final isPending = status == 'Pending';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(ev['title'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                            Text('${ev['startDate'] ?? ''} – ${ev['endDate'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isPending ? Colors.red.shade50 : Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(status, style: TextStyle(color: isPending ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                                        onPressed: () => _showEventOptions(context, doc.id, ev),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEventOptions(BuildContext context, String docId, Map<String, dynamic> ev) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENTLY SELECTED', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(ev['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('${ev['startDate'] ?? ''} – ${ev['endDate'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            Text('AVAILABLE CONTROLS', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, letterSpacing: 1)),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_outlined, color: Colors.black54),
              ),
              title: const Text('Edit Event Information', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Modify date, status levels, or title fields', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => EditExhibitionScreen(docId: docId, data: ev)));
              },
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.delete_outline, color: Colors.red.shade400),
              ),
              title: Text('Delete This Event', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade400)),
              subtitle: const Text('Permanently remove records from dashboard', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(ctx);
                await FirebaseFirestore.instance.collection('exhibitions').doc(docId).delete();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted.')));
              },
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
// 3. FLOOR MAP PAGE
// ─────────────────────────────────────────────
class _FloorMapPage extends StatelessWidget {
  const _FloorMapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Floor Map', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            const Text('Floor Plan Image Area', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                _MapDot(color: Colors.green.shade600, label: 'Premium'),
                const SizedBox(width: 12),
                _MapDot(color: Colors.red.shade400, label: 'Booked'),
                const SizedBox(width: 12),
                _MapDot(color: Colors.blue, label: 'Standard'),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload image feature coming soon.'))),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: Size.zero),
                  child: const Text('Upload Image', style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Floor map reset.'))),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: Size.zero),
                  child: const Text('Reset', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: Stack(
                children: [
                  const Center(child: Text('Scroll to zoom, click to add booth', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  Positioned(left: 60, top: 40, child: _PinDot(color: Colors.green.shade600)),
                  Positioned(left: 120, top: 80, child: _PinDot(color: Colors.blue)),
                  Positioned(left: 160, top: 110, child: _PinDot(color: Colors.red.shade400)),
                  Positioned(left: 90, top: 130, child: _PinDot(color: Colors.blue)),
                  Positioned(left: 140, top: 160, child: _PinDot(color: Colors.green.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _BoothTypeCard(
                    title: 'Premium Booth',
                    unitId: '01AB - Premium Booth',
                    price: 'RM 1,000/day',
                    onAdd: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium booth added.'))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BoothTypeCard(
                    title: 'Standard Booth',
                    unitId: '01CD - Standard',
                    price: 'RM 500/day',
                    onAdd: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Standard booth added.'))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapDot extends StatelessWidget {
  final Color color;
  final String label;
  const _MapDot({Key? key, required this.color, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _PinDot extends StatelessWidget {
  final Color color;
  const _PinDot({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _BoothTypeCard extends StatelessWidget {
  final String title;
  final String unitId;
  final String price;
  final VoidCallback onAdd;
  const _BoothTypeCard({Key? key, required this.title, required this.unitId, required this.price, required this.onAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Add Booth', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(unitId, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 4. RESERVATION PAGE
// ─────────────────────────────────────────────
class _ReservationPage extends StatefulWidget {
  const _ReservationPage({Key? key}) : super(key: key);

  @override
  State<_ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<_ReservationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicator: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
          tabs: const [Tab(text: 'All'), Tab(text: 'Pending'), Tab(text: 'Approved')],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReservationList(statusFilter: null),
          _ReservationList(statusFilter: 'Pending'),
          _ReservationList(statusFilter: 'Approved'),
        ],
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  final String? statusFilter;
  const _ReservationList({Key? key, required this.statusFilter}) : super(key: key);

  Stream<QuerySnapshot> get _stream {
    Query q = FirebaseFirestore.instance.collection('applications');
    if (statusFilter != null) q = q.where('status', isEqualTo: statusFilter);
    return q.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No reservations found.', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final status = data['status'] as String? ?? 'Pending';
            final isPending = status == 'Pending';
            final createdAt = (data['createdAt'] as dynamic)?.toDate()?.toString().split(' ').first ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: isPending ? Colors.red.shade100 : Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPending ? Colors.red : Colors.green)),
                      ),
                      const Spacer(),
                      Text(createdAt, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(data['companyName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Booth: ${data['boothLabel'] ?? ''} (${data['boothSize'] ?? ''})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('Contact: ${data['contactEmail'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// 5. USER MANAGEMENT
// ─────────────────────────────────────────────
class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Organizer': return Colors.purple;
      case 'Admin': return Colors.blue;
      default: return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snap.data?.docs ?? [];
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final name = (data['name'] as String? ?? '').toLowerCase();
                    final email = (data['email'] as String? ?? '').toLowerCase();
                    return name.contains(_searchQuery) || email.contains(_searchQuery);
                  }).toList();
                }
                if (docs.isEmpty) {
                  return const Center(child: Text('No users found.', style: TextStyle(color: Colors.grey)));
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('${docs.length} result(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final role = data['role'] as String? ?? 'Exhibitor';
                            final name = data['name'] as String? ?? data['email'] as String? ?? 'Unknown';
                            final email = data['email'] as String? ?? '';
                            return ListTile(
                              leading: CircleAvatar(backgroundColor: Colors.grey.shade300, child: const Icon(Icons.person, color: Colors.white, size: 20)),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(email, style: const TextStyle(fontSize: 12)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: _roleColor(role).withAlpha(30), borderRadius: BorderRadius.circular(4)),
                                child: Text(role, style: TextStyle(fontSize: 10, color: _roleColor(role), fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 6. BOOTH CONFIGURATION PAGE
// ─────────────────────────────────────────────
class AdminBoothConfigPage extends StatelessWidget {
  const AdminBoothConfigPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booth Configuration', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.edit_outlined, color: Colors.black))],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.image_outlined, size: 36, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('Exhibition Layout Mock Banner', style: TextStyle(color: Colors.grey, fontSize: 11))),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
              child: const Text('ACTIVE PACKAGE', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            const Text('Premium Booth Pack', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SPACE ALLOCATED', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text('10 SQM Square Area', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BASE COST', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text('RM 1,000 / Day', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('INCLUDED PERKS', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Row(
              children: const [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                SizedBox(width: 6),
                Expanded(child: Text('High-Speed Wifi Access + Dedicated 15A Power Outlet', style: TextStyle(fontSize: 13))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuration deleted.'))),
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                label: const Text('Delete Configuration', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('ASSIGNED LAYOUT UNITS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('4 Total Mapped', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Expanded(child: _UnitCard(unitId: 'A-01', status: 'Available')),
                SizedBox(width: 8),
                Expanded(child: _UnitCard(unitId: 'A-02', status: 'Reserved')),
                SizedBox(width: 8),
                Expanded(child: _UnitCard(unitId: 'B-01', status: 'Available')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final String unitId;
  final String status;
  const _UnitCard({Key? key, required this.unitId, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool available = status == 'Available';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: available ? Colors.green : Colors.orange, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('UNIT ID', style: TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 2),
          Text(unitId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(status, style: TextStyle(color: available ? Colors.green : Colors.orange, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADMIN PROFILE PAGE
// ─────────────────────────────────────────────
class _AdminProfilePage extends StatelessWidget {
  const _AdminProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Color(0xFFCBD5E1), child: Icon(Icons.admin_panel_settings, size: 36, color: Colors.white)),
            const SizedBox(height: 12),
            const Text('Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Role: System Administrator', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), foregroundColor: Colors.red),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MyExhibitPage()), (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
