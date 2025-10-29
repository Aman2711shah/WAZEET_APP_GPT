import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompanySetupPage extends StatefulWidget {
  const CompanySetupPage({super.key});

  @override
  State<CompanySetupPage> createState() => _CompanySetupPageState();
}

class _CompanySetupPageState extends State<CompanySetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactEmail = TextEditingController();
  final _contactPhone = TextEditingController();
  int _visaCount = 0;
  int _tenureYears = 1;

  String? _entityType; // e.g. LLC, Sole Proprietor, FZ-LLC
  String? _freezone; // e.g. IFZA, RAKEZ...
  final List<String> _selectedActivities = [];

  bool _busy = false;
  double _estimated = 0;

  // very simple cost formula (you can tweak later)
  void _recalc() {
    final base = 3500.0;
    final perAct = 250.0 * _selectedActivities.length;
    final perVisa = 900.0 * _visaCount;
    final entityAdj = switch (_entityType) {
      'LLC' => 500.0,
      'FZ-LLC' => 300.0,
      _ => 0.0,
    };
    setState(() => _estimated = base + perAct + perVisa + entityAdj);
  }

  Future<List<String>> _loadActivities() async {
    try {
      final q = await FirebaseFirestore.instance
          .collection('activities')
          .limit(50)
          .get();
      final activities = q.docs
          .map((d) => (d.data()['name'] ?? d.id).toString())
          .toList();
      if (activities.isEmpty) {
        // Return fallback activities if Firestore collection is empty
        return [
          'General Trading',
          'Import & Export',
          'Consultancy Services',
          'IT Services',
          'Marketing & Advertising',
          'Real Estate',
          'E-commerce',
          'Manufacturing',
          'Food & Beverage',
          'Healthcare Services',
        ];
      }
      return activities;
    } catch (e) {
      // Return fallback activities on error
      return [
        'General Trading',
        'Import & Export',
        'Consultancy Services',
        'IT Services',
        'Marketing & Advertising',
        'Real Estate',
        'E-commerce',
        'Manufacturing',
        'Food & Beverage',
        'Healthcare Services',
      ];
    }
  }

  Future<List<String>> _loadFreezones() async {
    try {
      final q = await FirebaseFirestore.instance
          .collection('freezones')
          .limit(50)
          .get();
      final freezones = q.docs
          .map((d) => (d.data()['name'] ?? d.id).toString())
          .toList();
      if (freezones.isEmpty) {
        // Return fallback freezones if Firestore collection is empty
        return [
          'IFZA (ADGM)',
          'RAKEZ',
          'SHAMS',
          'DMCC',
          'JAFZA',
          'Dubai South',
          'AJMAN Free Zone',
          'RAK ICC',
          'FUJAIRAH FREE ZONE',
          'UAE Mainland',
        ];
      }
      return freezones;
    } catch (e) {
      // Return fallback freezones on error
      return [
        'IFZA (ADGM)',
        'RAKEZ',
        'SHAMS',
        'DMCC',
        'JAFZA',
        'Dubai South',
        'AJMAN Free Zone',
        'RAK ICC',
        'FUJAIRAH FREE ZONE',
        'UAE Mainland',
      ];
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_entityType == null ||
        _freezone == null ||
        _selectedActivities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields and select at least 1 activity',
          ),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = await FirebaseFirestore.instance
          .collection('applications')
          .add({
            'user_id': uid,
            'status': 'submitted',
            'company_details': {
              'entity_type': _entityType,
              'activities': _selectedActivities,
              'visa_count': _visaCount,
              'tenure_years': _tenureYears,
              'freezone': _freezone,
            },
            'contact_details': {
              'email': _contactEmail.text.trim(),
              'phone': _contactPhone.text.trim(),
            },
            'total_amount': _estimated,
            'payment_status': 'pending',
            'created_at': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              _SuccessPage(applicationId: ref.id, total: _estimated),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submit failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _recalc(); // recalc on every build with current selections (cheap)
    return Scaffold(
      appBar: AppBar(title: const Text('Company Setup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Contact',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactPhone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Enter a valid phone'
                      : null,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Company Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Entity Type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Entity Type',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _entityType,
                  items: const ['LLC', 'FZ-LLC', 'Sole Proprietor']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _entityType = v);
                    _recalc();
                  },
                  validator: (v) => v == null ? 'Select entity type' : null,
                ),
                const SizedBox(height: 12),

                // Freezone (from Firestore)
                FutureBuilder<List<String>>(
                  future: _loadFreezones(),
                  builder: (context, snap) {
                    final items = (snap.data ?? [])
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Free Zone / Jurisdiction',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _freezone,
                      items: items,
                      onChanged: (v) {
                        setState(() => _freezone = v);
                      },
                      validator: (v) => v == null ? 'Select free zone' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Activities (multi-select using simple dialog)
                FutureBuilder<List<String>>(
                  future: _loadActivities(),
                  builder: (context, snap) {
                    final acts = snap.data ?? [];
                    return InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Activities',
                        border: OutlineInputBorder(),
                      ),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          ..._selectedActivities.map(
                            (a) => Chip(
                              label: Text(a),
                              onDeleted: () {
                                setState(() {
                                  _selectedActivities.remove(a);
                                  _recalc();
                                });
                              },
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                            onPressed: acts.isEmpty
                                ? null
                                : () async {
                                    final picked = await showDialog<String>(
                                      context: context,
                                      builder: (_) => SimpleDialog(
                                        title: const Text('Select Activity'),
                                        children: acts
                                            .take(50)
                                            .map(
                                              (name) => SimpleDialogOption(
                                                child: Text(name),
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  name,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    );
                                    if (picked != null &&
                                        !_selectedActivities.contains(picked)) {
                                      setState(() {
                                        _selectedActivities.add(picked);
                                        _recalc();
                                      });
                                    }
                                  },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Visa count & Tenure
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _visaCount,
                        decoration: const InputDecoration(
                          labelText: 'Visa Slots',
                          border: OutlineInputBorder(),
                        ),
                        items: [0, 1, 2, 3, 4, 5]
                            .map(
                              (i) =>
                                  DropdownMenuItem(value: i, child: Text('$i')),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() => _visaCount = v ?? 0);
                          _recalc();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _tenureYears,
                        decoration: const InputDecoration(
                          labelText: 'License Tenure (years)',
                          border: OutlineInputBorder(),
                        ),
                        items: [1, 2, 3]
                            .map(
                              (i) =>
                                  DropdownMenuItem(value: i, child: Text('$i')),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _tenureYears = v ?? 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cost summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Cost',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'AED ${_estimated.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _submit,
                    icon: const Icon(Icons.send),
                    label: Text(_busy ? 'Submitting...' : 'Submit Application'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessPage extends StatelessWidget {
  final String applicationId;
  final double total;
  const _SuccessPage({required this.applicationId, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Submitted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 72),
              const SizedBox(height: 16),
              Text(
                'Application ID:\n$applicationId',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Total: AED ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
