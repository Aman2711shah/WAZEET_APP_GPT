import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class ApplicationsPage extends StatefulWidget {
  final String? initialId;
  const ApplicationsPage({super.key, this.initialId});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  final _idController = TextEditingController();
  DocumentSnapshot<Map<String, dynamic>>? _result;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // If an initial ID was provided, prefill and auto-track after first frame
    if (widget.initialId != null && widget.initialId!.isNotEmpty) {
      _idController.text = widget.initialId!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _track());
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _track() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      setState(() => _error = 'Please enter your Service Request ID');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('service_requests')
          .doc(id)
          .get();
      if (!doc.exists) {
        setState(() {
          _error = 'No application found for this ID';
          _loading = false;
        });
        return;
      }
      setState(() {
        _result = doc;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  String _statusLabel(String? status) {
    switch ((status ?? 'submitted').toLowerCase()) {
      case 'processing':
      case 'under_process':
        return 'Under Process';
      case 'approved':
      case 'completed':
      case 'complete':
        return 'Complete';
      default:
        return 'Submitted';
    }
  }

  Color _statusColor(String? status) {
    switch ((status ?? 'submitted').toLowerCase()) {
      case 'processing':
      case 'under_process':
        return Colors.orange;
      case 'approved':
      case 'completed':
      case 'complete':
        return Colors.green;
      default:
        return AppColors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.purple,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Track Application',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1600&h=800&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Header image failed to load: $error');
                      return Container(
                        color: AppColors.purple.withOpacity(0.3),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          AppColors.purple.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 56,
                    child: Text(
                      'Monitor your service request status in real-time',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your Service Request ID to see the current status.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _idController,
                          decoration: InputDecoration(
                            labelText: 'Service Request ID',
                            hintText:
                                'e.g. a1B2c3D4... (copy from confirmation)',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: _idController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () =>
                                        setState(() => _idController.text = ''),
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _track(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _track,
                          icon: _loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: const Text('Check Status'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: _result == null
                ? Center(
                    child: Text(
                      'Enter your request ID above to track your application.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [_buildResultCard(_result!)],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final status = _statusLabel(data['status'] as String?);
    final color = _statusColor(data['status'] as String?);
    final createdAt = data['createdAt'];
    DateTime? created;
    if (createdAt is Timestamp) created = createdAt.toDate();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (data['serviceName'] ?? 'Service Request').toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${data['serviceType'] ?? 'N/A'} · Tier: ${data['tier'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (created != null)
              Text(
                'Submitted on: ${created.day}/${created.month}/${created.year}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    'Request ID: ${doc.id}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy ID',
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: doc.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request ID copied!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
