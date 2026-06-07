import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../guest/guest_page.dart';
import '../guest/all_upcoming_page.dart';
import '../guest/all_ongoing_page.dart';
import '../guest/exhibition_upcoming_page.dart';
import '../guest/exhibition_ongoing_page.dart';
import 'application_form.dart';

// ─────────────────────────────────────────────
// EXHIBITOR DASHBOARD – bottom nav shell
// Home | Event | Profile
// ─────────────────────────────────────────────
class ExhibitorDashboardScreen extends StatefulWidget {
  const ExhibitorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ExhibitorDashboardScreen> createState() =>
      _ExhibitorDashboardScreenState();
}

class _ExhibitorDashboardScreenState extends State<ExhibitorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _ExhibitorHomePage(),
      const _EventMenuPage(),
      const _ExhibitorProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Event'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────
class _ExhibitorHomePage extends StatelessWidget {
  const _ExhibitorHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('MyExhibit',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _NavButton(
                    icon: Icons.calendar_month,
                    label: 'Upcoming',
                    iconColor: Colors.green,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AllUpcomingPage())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NavButton(
                    icon: Icons.play_circle_fill,
                    label: 'Ongoing',
                    iconColor: Colors.blue,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AllOngoingPage())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Featured Exhibitions',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _ExhibitionGrid(
                stream: FirebaseFirestore.instance
                    .collection('exhibitions')
                    .limit(4)
                    .snapshots(),
                isUpcoming: true),
            const SizedBox(height: 20),
            const Text('Current Exhibitions',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _ExhibitionGrid(
                stream: FirebaseFirestore.instance
                    .collection('exhibitions')
                    .limit(4)
                    .snapshots(),
                isUpcoming: false),
            const SizedBox(height: 20),
            const Text('How to Participate',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _StepRow(
                icon: Icons.person_add,
                title: 'Sign Up',
                subtitle: 'Create your account'),
            const Divider(),
            _StepRow(
                icon: Icons.location_on,
                title: 'Select a Booth',
                subtitle: 'Browse the floor plan'),
            const Divider(),
            _StepRow(
                icon: Icons.check_box,
                title: 'Confirm',
                subtitle: 'Book your participation'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  const _NavButton(
      {Key? key,
      required this.icon,
      required this.label,
      required this.iconColor,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ExhibitionGrid extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final bool isUpcoming;
  const _ExhibitionGrid(
      {Key? key, required this.stream, required this.isUpcoming})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagColor = isUpcoming ? Colors.green : Colors.blue;
    final tag = isUpcoming ? 'UPCOMING' : 'LIVE NOW';
    final bg = isUpcoming
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFE3F2FD);

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('No ${tag.toLowerCase()} exhibitions yet.',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final title = data['title'] as String? ?? 'Exhibition';
            final start = data['startDate'] as String? ?? '';
            final end = data['endDate'] as String? ?? '';
            final dateLabel = start.isEmpty ? '' : '$start – $end';
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => isUpcoming
                      ? ExhibitionDetailPage(
                          docId: docs[index].id, data: data)
                      : ExhibitionOngoingPage(
                          docId: docs[index].id, data: data),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(9))),
                        padding: const EdgeInsets.all(6),
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(tag,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: tagColor)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text(dateLabel,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _StepRow(
      {Key? key,
      required this.icon,
      required this.title,
      required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Icon(icon, size: 20, color: Colors.black)),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
    );
  }
}

// ─────────────────────────────────────────────
// EVENT TAB
// ─────────────────────────────────────────────
class _EventMenuPage extends StatelessWidget {
  const _EventMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            color: Colors.black,
            child: const Text('Event Features Menu',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          _EventMenuTile(
            icon: Icons.grid_view,
            label: 'View Floor Plan Layout',
            iconColor: const Color(0xFF5C4EBD),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ExhibitionFloorPlanPage()),
            ),
          ),
          _EventMenuTile(
            icon: Icons.assignment,
            label: 'Check Booth Applications',
            iconColor: const Color(0xFF5C4EBD),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MyApplicationsPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  const _EventMenuTile(
      {Key? key,
      required this.icon,
      required this.label,
      required this.iconColor,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FLOOR PLAN PAGE
// ─────────────────────────────────────────────
class ExhibitionFloorPlanPage extends StatefulWidget {
  const ExhibitionFloorPlanPage({Key? key}) : super(key: key);

  @override
  State<ExhibitionFloorPlanPage> createState() =>
      _ExhibitionFloorPlanPageState();
}

class _ExhibitionFloorPlanPageState extends State<ExhibitionFloorPlanPage> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> _booths = [
    {'label': 'Booth A12', 'status': 0, 'size': '3m x 3m', 'price': 'RM 500', 'location': 'Hall A - Row A, No. 12'},
    {'label': 'Booth B01', 'status': 1, 'size': '3m x 6m', 'price': 'RM 1000', 'location': 'Hall A - Row B, No. 01'},
    {'label': 'Booth C09', 'status': 2, 'size': '3m x 3m', 'price': 'RM 500', 'location': 'Hall B - Row C, No. 09'},
    {'label': 'Booth A02', 'status': 0, 'size': '3m x 3m', 'price': 'RM 500', 'location': 'Hall A - Row A, No. 02'},
    {'label': 'Booth B03', 'status': 2, 'size': '5m x 5m', 'price': 'RM 1,200', 'location': 'Hall A - Row B, No. 03'},
    {'label': 'Booth C04', 'status': 0, 'size': '3m x 3m', 'price': 'RM 500', 'location': 'Hall A - Row C, No. 04'},
    {'label': 'Booth A05', 'status': 1, 'size': '4m x 4m', 'price': 'RM 800', 'location': 'Hall A - Row A, No. 05'},
    {'label': 'Booth B06', 'status': 0, 'size': '3m x 3m', 'price': 'RM 500', 'location': 'Hall A - Row B, No. 06'},
    {'label': 'Booth C07', 'status': 0, 'size': '5m x 5m', 'price': 'RM 1,000', 'location': 'Hall A - Row C, No. 07'},
  ];

  Color _boothColor(int status, bool selected) {
    if (selected) return Colors.green.shade500;
    switch (status) {
      case 1:
        return Colors.red.shade500;
      case 2:
        return Colors.indigo.shade500;
      default:
        return Colors.green.shade500;
    }
  }

  String _statusLabel(int status) {
    switch (status) {
      case 1:
        return 'BOOKED';
      case 2:
        return 'RESERVED';
      default:
        return 'AVAILABLE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sel = _selectedIndex != null ? _booths[_selectedIndex!] : null;
    final isAvailable = sel != null && sel['status'] == 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Exhibition Floor Plan',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _FilterChip(label: 'Size'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Price'),
                const Spacer(),
                const Icon(Icons.search, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text('Main Stage',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: _booths.length,
                itemBuilder: (context, index) {
                  final booth = _booths[index];
                  final status = booth['status'] as int;
                  final selected = _selectedIndex == index;
                  final canTap = status == 0;

                  return GestureDetector(
                    onTap: canTap
                        ? () => setState(() {
                              _selectedIndex =
                                  _selectedIndex == index ? null : index;
                            })
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: _boothColor(status, selected),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? Colors.green.shade800
                              : Colors.transparent,
                          width: selected ? 2.5 : 0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          booth['label'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _LegendDot(
                    color: Colors.green.shade500, label: 'Available'),
                const SizedBox(width: 14),
                _LegendDot(
                    color: Colors.red.shade500, label: 'Booked'),
                const SizedBox(width: 14),
                _LegendDot(
                    color: Colors.indigo.shade500, label: 'Reserved'),
              ],
            ),
          ),
          if (sel != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sel['label'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('Size: ${sel['size']}',
                            style: const TextStyle(fontSize: 13)),
                        Text('Price: ${sel['price']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('Location: ${sel['location']}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel(sel['status'] as int),
                      style: TextStyle(
                          color: isAvailable
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (sel != null && isAvailable)
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExhibitorApplicationFormPage(
                              boothLabel: sel['label'],
                              boothSize: sel['size'],
                              boothPrice: sel['price'],
                              boothLocation: sel['location'],
                            ),
                          ),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(
                  sel == null
                      ? 'Select a Booth First'
                      : 'Apply For This Booth',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down,
              size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({Key? key, required this.color, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MY APPLICATION PAGE
// ─────────────────────────────────────────────
class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({Key? key}) : super(key: key);

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _streamApps(String? statusFilter) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'none';
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection('applications')
        .where('exhibitorId', isEqualTo: uid);
    if (statusFilter != null) {
      q = q.where('status', isEqualTo: statusFilter);
    }
    return q.snapshots().map(
      (snap) =>
          snap.docs.map((d) => {...d.data(), 'docId': d.id}).toList(),
    );
  }

  void _cancelApp(String docId, String boothLabel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Application',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Cancel your application for $boothLabel?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('applications')
                  .doc(docId)
                  .delete();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application cancelled.')),
              );
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String? statusFilter) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _streamApps(statusFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final apps = snapshot.data ?? [];
        if (apps.isEmpty) {
          return const Center(
            child: Text('No applications found.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: apps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final app = apps[index];
            final status = app['status'] as String? ?? 'Pending';
            Color statusColor;
            switch (status) {
              case 'Approved':
                statusColor = Colors.green;
                break;
              case 'Rejected':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.orange;
            }
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF8FF),
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          app['boothLabel'] as String? ?? 'Unknown Booth',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(status,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                  if ((app['exhibitionTitle'] as String? ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      app['exhibitionTitle'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text('Company: ${app['companyName'] ?? ''}',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87)),
                  Text(
                      'Total: RM ${(app['totalCost'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87)),
                  if (status == 'Rejected' &&
                      (app['rejectionReason'] as String? ?? '')
                          .isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Reason: ${app['rejectionReason']}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.red)),
                  ],
                  if (status == 'Pending') ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => _cancelApp(
                            app['docId'] as String,
                            app['boothLabel'] as String? ??
                                'this booth'),
                        child: const Text('Cancel Application',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Application',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          labelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTab(null),
          _buildTab('Pending'),
          _buildTab('Approved'),
          _buildTab('Rejected'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EXHIBITOR PROFILE PAGE
// ─────────────────────────────────────────────
class _ExhibitorProfilePage extends StatefulWidget {
  const _ExhibitorProfilePage({Key? key}) : super(key: key);

  @override
  State<_ExhibitorProfilePage> createState() =>
      _ExhibitorProfilePageState();
}

class _ExhibitorProfilePageState extends State<_ExhibitorProfilePage> {
  final _nameCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController(text: '••••••••');

  bool _isEditing = false;
  bool _isLoading = true;

  int _pendingCount = 0;
  int _approvedCount = 0;
  int _rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    _emailCtrl.text = user.email ?? '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameCtrl.text = data['name'] ?? '';
        _orgCtrl.text = data['organizationName'] ?? '';
        _phoneCtrl.text = data['phone'] ?? '';
      }

      final appsSnap = await FirebaseFirestore.instance
          .collection('applications')
          .where('exhibitorId', isEqualTo: user.uid)
          .get();

      int pending = 0, approved = 0, rejected = 0;
      for (final d in appsSnap.docs) {
        final s = d.data()['status'] as String? ?? '';
        if (s == 'Pending') pending++;
        else if (s == 'Approved') approved++;
        else if (s == 'Rejected') rejected++;
      }
      if (mounted) {
        setState(() {
          _pendingCount = pending;
          _approvedCount = approved;
          _rejectedCount = rejected;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _orgCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const MyExhibitPage()),
                (route) => false,
              );
            },
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Profile',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.grid_view,
                        size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text('Exhibitor Corporate Account',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Role: Exhibitor Client Profile',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Exhibitor Statistics',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _statCol('Pending', '$_pendingCount'),
                _statCol('Approved', '$_approvedCount'),
                _statCol('Rejected', '$_rejectedCount'),
              ],
            ),
            const SizedBox(height: 24),

            _profileField('Full Name', _nameCtrl),
            _profileField('Organization Name', _orgCtrl),
            _profileField('Email', _emailCtrl,
                keyboardType: TextInputType.emailAddress),
            _profileField('Contact Number', _phoneCtrl,
                keyboardType: TextInputType.phone),
            _profileField('Password', _passCtrl, obscure: true),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () async {
                  if (_isEditing) {
                    final messenger = ScaffoldMessenger.of(context);
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({
                        'name': _nameCtrl.text.trim(),
                        'organizationName': _orgCtrl.text.trim(),
                        'phone': _phoneCtrl.text.trim(),
                      });
                    }
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Profile updated!'),
                          backgroundColor: Colors.green),
                    );
                  }
                  setState(() => _isEditing = !_isEditing);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                    _isEditing ? 'Save Changes' : 'Edit Profile',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  foregroundColor: Colors.red,
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: _showLogoutDialog,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _profileField(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text,
      bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: ctrl,
        enabled: _isEditing && !obscure,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(fontSize: 12, color: Colors.grey),
          suffixIcon:
              const Icon(Icons.edit, size: 16, color: Colors.grey),
          border: const UnderlineInputBorder(),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.black, width: 1.5)),
          disabledBorder: const UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey, width: 0.5)),
        ),
      ),
    );
  }
}
