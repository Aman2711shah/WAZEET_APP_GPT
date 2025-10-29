import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'company_setup_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('WAZEET Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.email}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.playlist_add),
              label: const Text('Start Company Setup'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CompanySetupPage()),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'My Applications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('user_id', isEqualTo: user.uid)
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) return const Text('No applications yet.');
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final status = (d['status'] ?? 'submitted').toString();
                      final total = (d['total_amount'] ?? 0).toString();
                      final freezone = d['company_details']?['freezone'] ?? '';
                      final entity = d['company_details']?['entity_type'] ?? '';
                      return ListTile(
                        title: Text('Status: $status  •  AED $total'),
                        subtitle: Text('Entity: $entity  •  Zone: $freezone'),
                      );
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
}
