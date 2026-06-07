import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import '../exhibitor/application_form.dart';

class ExhibitionDetailPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;
  const ExhibitionDetailPage({super.key, this.docId, this.data});

  @override
  State<ExhibitionDetailPage> createState() => _ExhibitionDetailPageState();
}

class _ExhibitionDetailPageState extends State<ExhibitionDetailPage> {
  String? _selectedBoothId;
  String? _userRole;
  bool _isDescExpanded = false;
  Set<String> _reservedBooths = {};

  // Floor layout — sizes/types fixed; reserved status loaded from Firestore.
  static const Map<String, Map<String, String>> _booths = {
    'E-1': {'size': '16 sqm', 'type': 'PREMIUM'},
    'E-2': {'size': '16 sqm', 'type': 'PREMIUM'},
    'E-3': {'size': '12 sqm', 'type': 'STANDARD'},
    'E-4': {'size': '12 sqm', 'type': 'STANDARD'},
    'E-5': {'size': '12 sqm', 'type': 'STANDARD'},
    'E-6': {'size': '12 sqm', 'type': 'STANDARD'},
    'E-7': {'size': '9 sqm',  'type': 'BUDGET'},
    'E-8': {'size': '9 sqm',  'type': 'BUDGET'},
  };

  @override
  void initState() {
    super.initState();
    _loadRole();
    _loadReservedBooths();
  }

  Future<void> _loadReservedBooths() async {
    if (widget.docId == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('applications')
        .where('exhibitionId', isEqualTo: widget.docId)
        .where('status', whereIn: ['Pending', 'Approved'])
        .get();
    if (!mounted) return;
    setState(() {
      _reservedBooths = snap.docs
          .map((d) => (d.data()['boothLabel'] as String? ?? ''))
          .where((s) => s.isNotEmpty)
          .toSet();
    });
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!mounted) return;
    setState(() => _userRole = doc.data()?['role'] as String?);
  }

  String _priceFor(String type) {
    final premium  = widget.data?['premiumPrice']  as String? ?? 'RM 1,000';
    final standard = widget.data?['standardPrice'] as String? ?? 'RM 500';
    return type == 'PREMIUM' ? premium : standard;
  }

  void _handleBook() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    if (_userRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading account details, please try again.')));
      return;
    }
    if (_userRole != 'Exhibitor') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only Exhibitor accounts can book booths.')));
      return;
    }
    if (_selectedBoothId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a booth first.')));
      return;
    }
    final booth = _booths[_selectedBoothId!]!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExhibitorApplicationFormPage(
          boothLabel:    _selectedBoothId!,
          boothSize:     booth['size']!,
          boothPrice:    _priceFor(booth['type']!),
          boothLocation: '${widget.data?['venue'] ?? 'Exhibition Hall'} – $_selectedBoothId',
          exhibitionId:    widget.docId,
          exhibitionTitle: widget.data?['title'] as String?,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title       = widget.data?['title']       as String? ?? 'Exhibition';
    final description = widget.data?['description'] as String? ?? '';
    final venue       = widget.data?['venue']       as String? ?? '';
    final startDate   = widget.data?['startDate']   as String? ?? '';
    final endDate     = widget.data?['endDate']     as String? ?? '';
    final dateRange   = startDate.isNotEmpty ? '$startDate – $endDate' : '';
    final isExhibitor = _userRole == 'Exhibitor';
    final sel         = _selectedBoothId != null ? _booths[_selectedBoothId!] : null;
    final isAvailable = sel != null && !_reservedBooths.contains(_selectedBoothId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5)),
              child: const Text('UPCOMING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
            ),
            const SizedBox(height: 12),

            // Title
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Venue
            if (venue.isNotEmpty) Row(children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(venue, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            ]),

            // Date range
            if (dateRange.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(dateRange, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ]),
            ],

            // Description
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                maxLines: _isDescExpanded ? null : 3,
                overflow: _isDescExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
              InkWell(
                onTap: () => setState(() => _isDescExpanded = !_isDescExpanded),
                child: Text(_isDescExpanded ? 'Read Less' : 'Read More', style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],

            const SizedBox(height: 24),
            const Text('Interactive Floor Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Tap an available booth to select it.', style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 12),

            // Floor plan grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), color: Colors.grey[50]),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.grey[300],
                    child: const Text('STAGE / MAIN ENTRANCE FRONTWAY', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.2,
                    children: _booths.keys.map((id) {
                      final b = _booths[id]!;
                      final isSelected = id == _selectedBoothId;
                      final isReserved = _reservedBooths.contains(id);
                      Color cell   = Colors.white;
                      Color text   = Colors.black;
                      Color border = Colors.black;
                      if (isReserved)      { cell = Colors.grey[300]!; text = Colors.grey[600]!; border = Colors.grey[400]!; }
                      else if (isSelected) { cell = Colors.black;      text = Colors.white; }
                      return InkWell(
                        onTap: isReserved ? null : () => setState(() => _selectedBoothId = isSelected ? null : id),
                        child: Container(
                          decoration: BoxDecoration(color: cell, border: Border.all(color: border, width: isSelected ? 2.5 : 1.5), borderRadius: BorderRadius.circular(4)),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(id, style: TextStyle(fontWeight: FontWeight.bold, color: text, fontSize: 13)),
                              Text(b['type']!, style: TextStyle(fontSize: 7, color: isSelected ? Colors.white70 : Colors.black54)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _legend(Colors.white,      Colors.black,      'Available'),
                    const SizedBox(width: 16),
                    _legend(Colors.black,      Colors.black,      'Selected'),
                    const SizedBox(width: 16),
                    _legend(Colors.grey[300]!, Colors.grey[400]!, 'Reserved'),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Booth detail panel
            if (sel != null) ...[
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 2))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Booth Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(sel['type']!, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('Booth', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text(_selectedBoothId!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          ]),
                          const Divider(color: Colors.black54, thickness: 1.2),
                          const SizedBox(height: 6),
                          _specRow('Size', sel['size']!),
                          const SizedBox(height: 10),
                          _specRow('Price', _priceFor(sel['type']!)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status', style: TextStyle(color: Colors.black87, fontSize: 13)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                decoration: BoxDecoration(color: isAvailable ? Colors.blue : Colors.grey, borderRadius: BorderRadius.circular(12)),
                                child: Text(isAvailable ? 'Available' : 'Reserved', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isAvailable
                                ? (isExhibitor ? 'Tap below to apply for this booth.' : 'Sign in as an Exhibitor to book.')
                                : 'This booth is already reserved.',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isAvailable ? _handleBook : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 40),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                disabledBackgroundColor: Colors.grey[300],
                              ),
                              child: Text(
                                isExhibitor ? 'Book This Booth' : 'Sign In to Book',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Select a booth above to view its details.', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color box, Color border, String label) => Row(
    children: [
      Container(width: 14, height: 14, decoration: BoxDecoration(color: box, border: Border.all(color: border), borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
    ],
  );

  Widget _specRow(String label, String value) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
      const SizedBox(height: 6),
      const Divider(color: Colors.black26, thickness: 1),
    ],
  );
}
