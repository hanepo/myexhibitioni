import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../guest/guest_page.dart';
import '../guest/exhibition_status.dart';
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
        title: const Text('MyExhibit',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  .where('status', isEqualTo: 'Approved')
                  .snapshots(),
              builder: (context, appSnap) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('exhibitions')
                      .snapshots(),
                  builder: (context, exSnap) {
                    final activeExhibitors =
                        appSnap.data?.docs.length ?? 0;
                    final liveEvents = exSnap.data?.docs.length ?? 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MetricCircle(
                            value: '$activeExhibitors',
                            label: 'Active\nExhibitors'),
                        const _MetricCircle(
                            value: '–', label: 'Visitor\nPasses'),
                        _MetricCircle(
                            value: '$liveEvents', label: 'Live\nEvents'),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Management Panel',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _ManagementCard(
                    icon: Icons.calendar_today,
                    title: 'MANAGE\nEvents',
                    badge: 'Live',
                    onTap: () => onNavigate(1)),
                _ManagementCard(
                    icon: Icons.museum,
                    title: 'LAYOUT PLAN\nFloor App',
                    badge: 'Map Set',
                    badgeColor: Colors.blue,
                    onTap: () => onNavigate(2)),
                _ManagementCard(
                  icon: Icons.people,
                  title: 'ACCOUNTS\nUser Profiles',
                  badge: null,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const AdminUserManagementPage())),
                ),
                _ManagementCard(
                    icon: Icons.receipt_long,
                    title: 'BOOKINGS\nReservation',
                    badge: 'New',
                    badgeColor: Colors.green,
                    onTap: () => onNavigate(3)),
                _ManagementCard(
                  icon: Icons.tune,
                  title: 'PRICING & SPECS\nBooth\nConfiguration',
                  badge: '2 Active Types',
                  badgeColor: Colors.grey,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminBoothConfigPage())),
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
  const _MetricCircle(
      {Key? key, required this.value, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2)),
          child: Center(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
  const _ManagementCard(
      {Key? key,
      required this.icon,
      required this.title,
      required this.badge,
      this.badgeColor = Colors.orange,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: Colors.black87),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: badgeColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(badge!,
                        style: TextStyle(
                            fontSize: 9,
                            color: badgeColor,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 3),
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
  String _statusFilter = 'All'; // All | Upcoming | Ongoing | Past
  bool _sortNewestFirst = true;

  static const _statusFilters = ['All', 'Upcoming', 'Ongoing', 'Past'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesStatus(Map<String, dynamic> data) {
    switch (_statusFilter) {
      case 'Upcoming':
        return ExhibitionStatus.isUpcoming(data);
      case 'Ongoing':
        return ExhibitionStatus.isOngoing(data);
      case 'Past':
        return ExhibitionStatus.isPast(data);
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Event',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search events...',
                hintStyle:
                    const TextStyle(color: Colors.black54, fontSize: 12),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey, size: 18),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Filter & sort row
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ..._statusFilters.map((f) {
                  final selected = _statusFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f,
                          style: TextStyle(
                              fontSize: 12,
                              color: selected
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      selected: selected,
                      selectedColor: Colors.black,
                      backgroundColor: Colors.grey.shade100,
                      side: BorderSide(
                          color: selected
                              ? Colors.black
                              : Colors.grey.shade300),
                      onSelected: (_) =>
                          setState(() => _statusFilter = f),
                    ),
                  );
                }),
                ActionChip(
                  avatar: Icon(
                      _sortNewestFirst
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 14,
                      color: Colors.black87),
                  label: Text(
                      _sortNewestFirst ? 'Newest First' : 'Oldest First',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black87)),
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(color: Colors.grey.shade300),
                  onPressed: () => setState(
                      () => _sortNewestFirst = !_sortNewestFirst),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exhibitions')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = (snap.data?.docs ?? []).where((d) {
                  return _matchesStatus(d.data() as Map<String, dynamic>);
                }).toList();
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final title =
                        (data['title'] as String? ?? '').toLowerCase();
                    final venue =
                        (data['venue'] as String? ?? '').toLowerCase();
                    return title.contains(_searchQuery) ||
                        venue.contains(_searchQuery);
                  }).toList();
                }
                docs.sort((a, b) {
                  final sa = (a.data()
                          as Map<String, dynamic>)['startDate']
                      as String? ??
                      '';
                  final sb = (b.data()
                          as Map<String, dynamic>)['startDate']
                      as String? ??
                      '';
                  return _sortNewestFirst
                      ? sb.compareTo(sa)
                      : sa.compareTo(sb);
                });
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('No events found.',
                          style: TextStyle(color: Colors.grey)));
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${docs.length} event(s)',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final ev =
                                doc.data() as Map<String, dynamic>;
                            final status =
                                ev['status'] as String? ?? 'Published';
                            final isPending = status == 'Pending';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(ev['title'] ?? '',
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            Text(
                                                '${ev['startDate'] ?? ''} – ${ev['endDate'] ?? ''}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 16)),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isPending
                                                    ? Colors.red.shade50
                                                    : Colors
                                                        .green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        4),
                                              ),
                                              child: Text(status,
                                                  style: TextStyle(
                                                      color: isPending
                                                          ? Colors.red
                                                          : Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_vert,
                                            color: Colors.grey),
                                        onPressed: () =>
                                            _showEventOptions(
                                                context, doc.id, ev),
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

  void _showEventOptions(
      BuildContext context, String docId, Map<String, dynamic> ev) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENTLY SELECTED',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(ev['title'] ?? '',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Text('${ev['startDate'] ?? ''} – ${ev['endDate'] ?? ''}',
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            Text('AVAILABLE CONTROLS',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    letterSpacing: 1)),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_outlined,
                    color: Colors.black54),
              ),
              title: const Text('Edit Event Information',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Modify date, status levels, or title fields',
                  style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditExhibitionScreen(
                            docId: docId, data: ev)));
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.delete_outline,
                    color: Colors.red.shade400),
              ),
              title: Text('Delete This Event',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400)),
              subtitle: const Text(
                  'Permanently remove records from dashboard',
                  style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                // Confirm before permanently removing the event
                showDialog(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Delete Event?',
                        style:
                            TextStyle(fontWeight: FontWeight.bold)),
                    content: Text(
                        'Are you sure you want to permanently delete "${ev['title'] ?? 'this event'}"? This action cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () async {
                          Navigator.pop(dCtx);
                          await FirebaseFirestore.instance
                              .collection('exhibitions')
                              .doc(docId)
                              .delete();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Event deleted permanently.')));
                        },
                        child: const Text('Yes, Delete',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 3. FLOOR MAP PAGE  (same E-1..E-8 grid, real data)
// ─────────────────────────────────────────────
class _FloorMapPage extends StatefulWidget {
  const _FloorMapPage({Key? key}) : super(key: key);

  @override
  State<_FloorMapPage> createState() => _FloorMapPageState();
}

class _FloorMapPageState extends State<_FloorMapPage> {
  String? _selectedExhibitionId;
  String _selectedExhibitionTitle = '';

  static const List<Map<String, String>> _booths = [
    {'id': 'E-1', 'type': 'PREMIUM', 'size': '16 sqm'},
    {'id': 'E-2', 'type': 'PREMIUM', 'size': '16 sqm'},
    {'id': 'E-3', 'type': 'STANDARD', 'size': '12 sqm'},
    {'id': 'E-4', 'type': 'STANDARD', 'size': '12 sqm'},
    {'id': 'E-5', 'type': 'STANDARD', 'size': '12 sqm'},
    {'id': 'E-6', 'type': 'STANDARD', 'size': '12 sqm'},
    {'id': 'E-7', 'type': 'BUDGET', 'size': '9 sqm'},
    {'id': 'E-8', 'type': 'BUDGET', 'size': '9 sqm'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Floor Map',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Exhibition selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exhibitions')
                  .snapshots(),
              builder: (context, snap) {
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Text('No exhibitions available.',
                      style: TextStyle(color: Colors.grey));
                }
                // Auto-select first exhibition
                if (_selectedExhibitionId == null && docs.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    final d = docs.first.data() as Map<String, dynamic>;
                    setState(() {
                      _selectedExhibitionId = docs.first.id;
                      _selectedExhibitionTitle =
                          d['title'] as String? ?? '';
                    });
                  });
                }
                return DropdownButtonFormField<String>(
                  value: _selectedExhibitionId,
                  decoration: InputDecoration(
                    labelText: 'Select Exhibition',
                    labelStyle: const TextStyle(fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                  items: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: d.id,
                      child: Text(data['title'] as String? ?? d.id,
                          style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    final d = docs
                        .firstWhere((d) => d.id == val)
                        .data() as Map<String, dynamic>;
                    setState(() {
                      _selectedExhibitionId = val;
                      _selectedExhibitionTitle =
                          d['title'] as String? ?? '';
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedExhibitionId == null)
            const Expanded(
              child: Center(
                  child: Text('Select an exhibition to view its floor plan.',
                      style: TextStyle(color: Colors.grey))),
            )
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('exhibitionId',
                        isEqualTo: _selectedExhibitionId)
                    .where('status',
                        whereIn: ['Pending', 'Approved'])
                    .snapshots(),
                builder: (context, snap) {
                  final reservedLabels = snap.data?.docs
                          .map((d) =>
                              (d.data() as Map<String, dynamic>)[
                                  'boothLabel'] as String? ??
                              '')
                          .where((s) => s.isNotEmpty)
                          .toSet() ??
                      <String>{};

                  final premium = _booths
                      .where((b) => b['type'] == 'PREMIUM')
                      .length;
                  final standard = _booths
                      .where((b) => b['type'] == 'STANDARD')
                      .length;
                  final reserved = reservedLabels.length;
                  final available = _booths.length - reserved;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedExhibitionTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        // Stats row
                        Row(
                          children: [
                            _statPill('$available Available',
                                Colors.green.shade600),
                            const SizedBox(width: 8),
                            _statPill(
                                '$reserved Reserved', Colors.red.shade400),
                            const SizedBox(width: 8),
                            _statPill(
                                '$premium Premium', Colors.amber.shade700),
                            const SizedBox(width: 8),
                            _statPill(
                                '$standard Standard', Colors.blueGrey),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Floor plan grid
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black, width: 2),
                              color: Colors.grey.shade50),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4),
                                margin: const EdgeInsets.only(bottom: 16),
                                color: Colors.grey.shade300,
                                child: const Text(
                                    'STAGE / MAIN ENTRANCE',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2)),
                              ),
                              GridView.count(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.2,
                                children: _booths.map((b) {
                                  final id = b['id']!;
                                  final type = b['type']!;
                                  final size = b['size']!;
                                  final isReserved =
                                      reservedLabels.contains(id);
                                  Color cell = isReserved
                                      ? Colors.red.shade300
                                      : Colors.white;
                                  Color text = isReserved
                                      ? Colors.white
                                      : Colors.black;
                                  Color border = isReserved
                                      ? Colors.red.shade400
                                      : Colors.black;
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: cell,
                                        border: Border.all(
                                            color: border, width: 1.5),
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(id,
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: text,
                                                fontSize: 13)),
                                        Text(type,
                                            style: TextStyle(
                                                fontSize: 7,
                                                color: isReserved
                                                    ? Colors.white70
                                                    : Colors.black54)),
                                        Text(size,
                                            style: TextStyle(
                                                fontSize: 7,
                                                color: isReserved
                                                    ? Colors.white70
                                                    : Colors.black45)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    _legendDot(
                                        Colors.white,
                                        Colors.black,
                                        'Available'),
                                    const SizedBox(width: 16),
                                    _legendDot(
                                        Colors.red.shade300,
                                        Colors.red.shade400,
                                        'Reserved'),
                                  ]),
                            ],
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

  Widget _statPill(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(80))),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold)),
      );

  Widget _legendDot(Color box, Color border, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: box,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      );
}

// ─────────────────────────────────────────────
// 4. RESERVATION PAGE  (with Approve / Cancel)
// ─────────────────────────────────────────────
class _ReservationPage extends StatefulWidget {
  const _ReservationPage({Key? key}) : super(key: key);

  @override
  State<_ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<_ReservationPage>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicator: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6)),
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
          _ReservationList(statusFilter: null),
          _ReservationList(statusFilter: 'Pending'),
          _ReservationList(statusFilter: 'Approved'),
          _ReservationList(statusFilter: 'Rejected'),
        ],
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  final String? statusFilter;
  const _ReservationList({Key? key, required this.statusFilter})
      : super(key: key);

  Stream<QuerySnapshot> get _stream {
    Query q =
        FirebaseFirestore.instance.collection('applications');
    if (statusFilter != null) {
      q = q.where('status', isEqualTo: statusFilter);
    }
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
          return const Center(
              child: Text('No reservations found.',
                  style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _ReservationCard(docId: doc.id, data: data);
          },
        );
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _ReservationCard(
      {Key? key, required this.docId, required this.data})
      : super(key: key);

  void _approve(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Approval',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Approve this booth application?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('applications')
                  .doc(docId)
                  .update({
                'status': 'Approved',
                'rejectionReason': '',
              });
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Application approved.'),
                      backgroundColor: Colors.green));
            },
            child: const Text('Approve',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _reject(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reason for Rejection',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Please provide a reason for rejecting this application.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter reason...')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('applications')
                  .doc(docId)
                  .update({
                'status': 'Rejected',
                'rejectionReason': reasonCtrl.text.trim(),
              });
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Application rejected.'),
                      backgroundColor: Colors.red));
            },
            child: const Text('Submit',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'Pending';
    final createdAt =
        (data['createdAt'] as dynamic)?.toDate()?.toString().split(' ').first ?? '';
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

    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  AdminReservationDetailPage(docId: docId, data: data))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor.withAlpha(80))),
                  child: Text(status,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ),
                const Spacer(),
                Text(createdAt,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Text(data['companyName'] as String? ?? 'Unknown',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            if ((data['exhibitionTitle'] as String? ?? '').isNotEmpty)
              Text(data['exhibitionTitle'] as String,
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 12)),
            Text(
                'Booth: ${data['boothLabel'] ?? ''} (${data['boothSize'] ?? ''})',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
            Text('Contact: ${data['contactEmail'] ?? ''}',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11)),
            if (status == 'Rejected' &&
                (data['rejectionReason'] as String? ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Reason: ${data['rejectionReason']}',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.red)),
            ],
            if (status == 'Pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _reject(context),
                      child: const Text('Reject',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _approve(context),
                      child: const Text('Approve',
                          style: TextStyle(
                              color: Colors.white, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Full detail page for admin review (mirrors organizer's ExhibitorDetailAssessmentScreen)
class AdminReservationDetailPage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const AdminReservationDetailPage(
      {Key? key, required this.docId, required this.data})
      : super(key: key);

  void _approve(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Approval',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Approve this booth application?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('applications')
                  .doc(docId)
                  .update({
                'status': 'Approved',
                'rejectionReason': '',
              });
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Application approved.'),
                      backgroundColor: Colors.green));
            },
            child: const Text('Confirm',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _reject(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reason for Rejection',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Please specify the reason for rejecting this application.',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter reason...')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('applications')
                  .doc(docId)
                  .update({
                'status': 'Rejected',
                'rejectionReason': reasonCtrl.text.trim(),
              });
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Application rejected.'),
                      backgroundColor: Colors.red));
            },
            child: const Text('Submit Rejection',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'Pending';
    final rejectionReason =
        data['rejectionReason'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
            data['companyName'] as String? ?? 'Application Detail',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
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
                const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.business)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['contactPerson'] as String? ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(data['companyName'] as String? ?? '',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _row('Status', status),
            _row('Exhibition',
                data['exhibitionTitle'] as String? ?? '—'),
            _row('Booth',
                '${data['boothLabel'] ?? ''} (${data['boothSize'] ?? ''})'),
            _row('Location', data['boothLocation'] as String? ?? ''),
            _row('Price', data['boothPrice'] as String? ?? ''),
            _row('Contact Email',
                data['contactEmail'] as String? ?? ''),
            _row('Contact Phone',
                data['contactPhone'] as String? ?? ''),
            _row('Total Cost',
                'RM ${(data['totalCost'] as num?)?.toStringAsFixed(2) ?? '—'}'),
            const SizedBox(height: 12),
            const Text('Exhibit Profile',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(data['exhibitProfile'] as String? ?? '',
                style: const TextStyle(color: Colors.black87)),
            if (rejectionReason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200)),
                child: Text('Rejection Reason: $rejectionReason',
                    style: TextStyle(
                        color: Colors.red.shade800, fontSize: 13)),
              ),
            ],
            if (status == 'Pending') ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _reject(context),
                      child: const Text('Reject Application'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _approve(context),
                      child: const Text('Approve Application',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 110,
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// 5. USER MANAGEMENT  (filter by role + Active badge)
// ─────────────────────────────────────────────
class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState
    extends State<AdminUserManagementPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'All';

  static const _roles = ['All', 'Exhibitor', 'Organizer', 'Admin'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Organizer':
        return Colors.purple;
      case 'Admin':
        return Colors.blue;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search,
                    color: Colors.grey, size: 18),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          // Role filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _roles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final role = _roles[i];
                final selected = _roleFilter == role;
                return ChoiceChip(
                  label: Text(role,
                      style: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  selected: selected,
                  selectedColor: Colors.black,
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(
                      color: selected
                          ? Colors.black
                          : Colors.grey.shade300),
                  onSelected: (_) =>
                      setState(() => _roleFilter = role),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                var docs = snap.data?.docs ?? [];
                // Role filter
                if (_roleFilter != 'All') {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return (data['role'] as String? ?? 'Exhibitor') ==
                        _roleFilter;
                  }).toList();
                }
                // Search filter
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final name =
                        (data['name'] as String? ?? '').toLowerCase();
                    final email =
                        (data['email'] as String? ?? '').toLowerCase();
                    return name.contains(_searchQuery) ||
                        email.contains(_searchQuery);
                  }).toList();
                }
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('No users found.',
                          style: TextStyle(color: Colors.grey)));
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('${docs.length} user(s)',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final data = docs[index].data()
                                as Map<String, dynamic>;
                            final role =
                                data['role'] as String? ?? 'Exhibitor';
                            final name = data['name'] as String? ??
                                data['email'] as String? ??
                                'Unknown';
                            final email =
                                data['email'] as String? ?? '';
                            return ListTile(
                              leading: CircleAvatar(
                                  backgroundColor:
                                      _roleColor(role).withAlpha(40),
                                  child: Icon(Icons.person,
                                      color: _roleColor(role),
                                      size: 20)),
                              title: Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(email,
                                  style:
                                      const TextStyle(fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color:
                                            _roleColor(role).withAlpha(25),
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                    child: Text(role,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: _roleColor(role),
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        border: Border.all(
                                            color:
                                                Colors.green.shade200)),
                                    child: Text('Active',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                Colors.green.shade700,
                                            fontWeight:
                                                FontWeight.bold)),
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
}

// ─────────────────────────────────────────────
// 6. BOOTH CONFIGURATION PAGE  (real data: boothConfigs collection)
// ─────────────────────────────────────────────
class AdminBoothConfigPage extends StatelessWidget {
  const AdminBoothConfigPage({Key? key}) : super(key: key);

  // Edit dialog used for both creating and updating a configuration
  void _showConfigDialog(BuildContext context,
      {String? docId, Map<String, dynamic>? data}) {
    final nameCtrl =
        TextEditingController(text: data?['name'] as String? ?? '');
    final spaceCtrl =
        TextEditingController(text: data?['space'] as String? ?? '');
    final costCtrl =
        TextEditingController(text: data?['baseCost'] as String? ?? '');
    final perksCtrl =
        TextEditingController(text: data?['perks'] as String? ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(docId == null ? 'Add Configuration' : 'Edit Configuration',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Package Name',
                      hintText: 'e.g. Premium Booth Pack')),
              TextField(
                  controller: spaceCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Space Allocated',
                      hintText: 'e.g. 16 SQM Square Area')),
              TextField(
                  controller: costCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Base Cost',
                      hintText: 'e.g. RM 1,000 / Day')),
              TextField(
                  controller: perksCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Included Perks',
                      hintText: 'e.g. Wifi + Power Outlet')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Package name is required.'),
                    backgroundColor: Colors.red));
                return;
              }
              Navigator.pop(ctx);
              final payload = {
                'name': name,
                'space': spaceCtrl.text.trim(),
                'baseCost': costCtrl.text.trim(),
                'perks': perksCtrl.text.trim(),
                'updatedAt': FieldValue.serverTimestamp(),
              };
              final col =
                  FirebaseFirestore.instance.collection('boothConfigs');
              if (docId == null) {
                await col.add(payload);
              } else {
                await col.doc(docId).update(payload);
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(docId == null
                      ? 'Configuration added.'
                      : 'Configuration updated.'),
                  backgroundColor: Colors.green));
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Confirmation before permanently deleting from Firestore
  void _confirmDelete(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Configuration?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to permanently delete "$name"? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('boothConfigs')
                  .doc(docId)
                  .delete();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Configuration deleted permanently.')));
            },
            child: const Text('Yes, Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booth Configuration',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _showConfigDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('boothConfigs').snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tune, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('No booth configurations yet.',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text('Tap + to add one.',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] as String? ?? 'Unnamed Package';
              final space = data['space'] as String? ?? '—';
              final cost = data['baseCost'] as String? ?? '—';
              final perks = data['perks'] as String? ?? '';
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('ACTIVE PACKAGE',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              size: 20, color: Colors.black54),
                          onPressed: () => _showConfigDialog(context,
                              docId: doc.id, data: data),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: Colors.red),
                          onPressed: () =>
                              _confirmDelete(context, doc.id, name),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SPACE ALLOCATED',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text(space,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BASE COST',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text(cost,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (perks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('INCLUDED PERKS',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(perks,
                                  style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 7. ADMIN PROFILE PAGE  (same style as Organizer)
// ─────────────────────────────────────────────
class _AdminProfilePage extends StatefulWidget {
  const _AdminProfilePage({Key? key}) : super(key: key);

  @override
  State<_AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<_AdminProfilePage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController(text: '••••••••');

  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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
        _nameCtrl.text = data['name'] as String? ?? '';
        _phoneCtrl.text = data['phone'] as String? ?? '';
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyExhibitPage()),
                  (route) => false);
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
          body: Center(child: CircularProgressIndicator()));
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
                    child: const Icon(Icons.admin_panel_settings,
                        size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text('Admin Account',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const Text('Role: System Administrator',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _profileField('Full Name', _nameCtrl),
            _profileField('Email', _emailCtrl,
                keyboardType: TextInputType.emailAddress),
            _profileField('Contact Number', _phoneCtrl,
                keyboardType: TextInputType.phone),
            _profileField('Password', _passCtrl, obscure: true),
            const SizedBox(height: 20),
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
                        'phone': _phoneCtrl.text.trim(),
                      });
                    }
                    if (!mounted) return;
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Profile updated!'),
                        backgroundColor: Colors.green));
                  }
                  setState(() => _isEditing = !_isEditing);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_isEditing ? 'Save Changes' : 'Edit Profile',
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
          suffixIcon: _isEditing && !obscure
              ? const Icon(Icons.edit, size: 16, color: Colors.grey)
              : null,
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
