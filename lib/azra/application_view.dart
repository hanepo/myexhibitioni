import 'package:flutter/material.dart';

// Exhibition Proposal Registry – organizer's view of event proposals (not imported by main nav)
class ExhibitionProposalTabScreen extends StatelessWidget {
  const ExhibitionProposalTabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Proposals Registry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFFD97706),
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: Color(0xFFD97706),
            tabs: [
              Tab(text: 'All Entries'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFilteredList(context, 'all'),
            _buildFilteredList(context, 'pending'),
            _buildFilteredList(context, 'approved'),
            _buildFilteredList(context, 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList(BuildContext context, String mode) {
    List<Widget> list = [];
    Widget i1 = _buildCard(context, 'Exhibition Proposal 1', 'Pending', const Color(0xFFD97706));
    Widget i2 = _buildCard(context, 'Cybersecurity Expo A', 'Approved', const Color(0xFF10B981));
    Widget i3 = _buildCard(context, 'Crypto Summit C', 'Rejected', const Color(0xFFEF4444));

    if (mode == 'all') list = [i1, i2, i3];
    if (mode == 'pending') list = [i1];
    if (mode == 'approved') list = [i2];
    if (mode == 'rejected') list = [i3];

    return ListView(padding: const EdgeInsets.all(16), children: list);
  }

  Widget _buildCard(BuildContext context, String t, String s, Color c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Status: $s', style: TextStyle(color: c, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
            appBar: AppBar(title: Text(t), backgroundColor: const Color(0xFF1E293B)),
            body: Center(child: Text('Detail workflow validation screen layout for: $t ($s)')),
          )));
        },
      ),
    );
  }
}