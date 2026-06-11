import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exhibition_upcoming_page.dart';
import 'exhibition_status.dart';

class AllUpcomingPage extends StatefulWidget {
  const AllUpcomingPage({super.key});

  @override
  State<AllUpcomingPage> createState() => _AllUpcomingPageState();
}

class _AllUpcomingPageState extends State<AllUpcomingPage> {
  String _searchQuery = '';
  String _dateFilter = 'All'; // All | This Month | Next Month
  bool _sortAscending = true;

  static const _dateFilters = ['All', 'This Month', 'Next Month'];

  bool _matchesDateFilter(Map<String, dynamic> data) {
    if (_dateFilter == 'All') return true;
    final start = DateTime.tryParse(data['startDate'] as String? ?? '');
    if (start == null) return false;
    final now = DateTime.now();
    if (_dateFilter == 'This Month') {
      return start.year == now.year && start.month == now.month;
    }
    final next = DateTime(now.year, now.month + 1);
    return start.year == next.year && start.month == next.month;
  }

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
        title: const Text(
          'Upcoming Exhibitions',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search upcoming exhibitions...',
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.grey, width: 1)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
              ),
            ),
          ),
          // Filter & sort row
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ..._dateFilters.map((f) {
                  final selected = _dateFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f,
                          style: TextStyle(
                              fontSize: 12,
                              color: selected ? Colors.white : Colors.black87,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                      selected: selected,
                      selectedColor: Colors.black,
                      backgroundColor: Colors.grey.shade100,
                      side: BorderSide(color: selected ? Colors.black : Colors.grey.shade300),
                      onSelected: (_) => setState(() => _dateFilter = f),
                    ),
                  );
                }),
                ActionChip(
                  avatar: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14, color: Colors.black87),
                  label: Text(_sortAscending ? 'Earliest First' : 'Latest First',
                      style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(color: Colors.grey.shade300),
                  onPressed: () => setState(() => _sortAscending = !_sortAscending),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('exhibitions').snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Only genuinely upcoming exhibitions (start date after today)
                var docs = (snap.data?.docs ?? []).where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return ExhibitionStatus.isUpcoming(data) && _matchesDateFilter(data);
                }).toList();
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final title = (data['title'] as String? ?? '').toLowerCase();
                    final venue = (data['venue'] as String? ?? '').toLowerCase();
                    return title.contains(_searchQuery) || venue.contains(_searchQuery);
                  }).toList();
                }
                docs.sort((a, b) {
                  final sa = (a.data() as Map<String, dynamic>)['startDate'] as String? ?? '';
                  final sb = (b.data() as Map<String, dynamic>)['startDate'] as String? ?? '';
                  return _sortAscending ? sa.compareTo(sb) : sb.compareTo(sa);
                });
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No upcoming exhibitions found.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['title'] as String? ?? 'Exhibition';
                    final startDate = data['startDate'] as String? ?? '';
                    final endDate = data['endDate'] as String? ?? '';
                    final dateLabel = startDate.isEmpty ? '' : '$startDate – $endDate';
                    final imageUrl = data['imageUrl'] as String? ?? '';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExhibitionDetailPage(docId: docs[index].id, data: data))),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    image: imageUrl.isNotEmpty
                                        ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.green.withOpacity(0.3), width: 0.5),
                                    ),
                                    child: const Text('UPCOMING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                                    const SizedBox(height: 4),
                                    Text(dateLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                                  ],
                                ),
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
          ),
        ],
      ),
    );
  }
}
