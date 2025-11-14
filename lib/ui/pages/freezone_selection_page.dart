import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FreezoneSelectionPage extends StatefulWidget {
  const FreezoneSelectionPage({super.key});

  @override
  State<FreezoneSelectionPage> createState() => _FreezoneSelectionPageState();
}

class _FreezoneSelectionPageState extends State<FreezoneSelectionPage> {
  // Activity search & selection
  final TextEditingController _activityController = TextEditingController();
  final List<Map<String, String>> _selectedActivities = [];
  int _maxActivities = 1; // user-selectable: 1..5

  // Filters
  int _selectedVisaCount = 1;
  String _selectedEmirate = 'Entire UAE';

  // Search state
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  DateTime? _lastSearchTime;
  String? _lastSearchQuery;

  // Package search state
  bool _isLoadingPackages = false;
  List<Map<String, dynamic>> _packageResults = [];

  final List<String> _emirates = const [
    'Entire UAE',
    'Abu Dhabi',
    'Dubai',
    'Sharjah',
    'Ajman',
    'Umm Al Quwain',
    'Ras Al Khaimah',
    'Fujairah',
  ];

  final List<int> _visaCounts = const [1, 2, 3, 4, 5, 6, 7];

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  // Enhanced activity search: 1+ chars, 300ms debounce, fuzzy + token match
  Future<void> _searchActivities(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final now = DateTime.now();
    _lastSearchTime = now;
    _lastSearchQuery = q;
    await Future.delayed(const Duration(milliseconds: 300));
    if (_lastSearchTime != now || _lastSearchQuery != q) {
      return; // debounced away
    }

    setState(() => _isSearching = true);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('Activity list')
          .limit(300)
          .get();

      final searchQuery = q.toLowerCase();
      final searchTokens = searchQuery
          .split(RegExp(r"[\s,\-/()]+"))
          .where((t) => t.isNotEmpty)
          .toList();

      final results = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final name = (data['Activity Name'] ?? '').toString();
        final nameLower = name.toLowerCase();
        final desc = (data['Description'] ?? '').toString().toLowerCase();
        final sector = (data['Sector'] ?? '').toString().toLowerCase();

        final tokens = nameLower
            .split(RegExp(r"[\s,\-/()]+"))
            .where((t) => t.isNotEmpty)
            .toList();

        int score = 0;
        if (nameLower == searchQuery) {
          score = 1000;
        } else if (nameLower.startsWith(searchQuery)) {
          score = 900;
        } else if (nameLower.contains(searchQuery)) {
          score = 800;
        } else {
          for (final tk in tokens) {
            for (final st in searchTokens) {
              if (tk == st) {
                score += 100;
              } else if (tk.startsWith(st)) {
                score += 70;
              } else if (tk.contains(st)) {
                score += 50;
              } else if (_isFuzzyMatch(tk, st)) {
                score += 30;
              }
            }
          }
          if (desc.contains(searchQuery)) score += 40;
          if (sector.contains(searchQuery)) score += 60;
        }

        if (score > 0) {
          results.add({
            'id': doc.id,
            'name': name,
            'sector': data['Sector'] ?? '',
            'activityCode': data['Activity Master Number'] ?? '',
            'relevance': score,
          });
        }
      }

      results.sort(
        (a, b) => (b['relevance'] as int).compareTo(a['relevance'] as int),
      );

      setState(() {
        _searchResults = results.take(10).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching activities: $e')),
        );
      }
    }
  }

  bool _isFuzzyMatch(String a, String b) {
    if (a.length < 3 || b.length < 3) return false;
    int match = 0;
    for (final ch in b.characters) {
      if (a.contains(ch)) match++;
    }
    return match >= (b.length * 0.7);
  }

  Future<void> _findPackages() async {
    if (_selectedActivities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one activity')),
      );
      return;
    }

    setState(() {
      _isLoadingPackages = true;
      _packageResults = [];
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('freezone_packages')
          .get();

      final results = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final data = doc.data();

        final visasIncluded = _parseVisaCount(data['No. of Visas Included']);
        if (visasIncluded < _selectedVisaCount) continue;

        final activitiesAllowed = _parseActivityCount(
          data['No. of Activities Allowed'],
        );
        if (activitiesAllowed > 0 &&
            activitiesAllowed < _selectedActivities.length) {
          continue;
        }

        if (_selectedEmirate != 'Entire UAE') {
          final name = (data['Freezone'] ?? '').toString().toLowerCase();
          if (!name.contains(_selectedEmirate.toLowerCase())) continue;
        }

        results.add({
          'id': doc.id,
          'freezone': data['Freezone'] ?? 'Unknown',
          'packageName': data['Package Name'] ?? 'N/A',
          'price': data['Price (AED)'] ?? 0,
          'visaCount': data['No. of Visas Included'] ?? 0,
          'activities': data['No. of Activities Allowed'] ?? 'N/A',
          'shareholders': data['No. of Shareholders Allowed'] ?? 'N/A',
          'tenure': data['Tenure (Years)'] ?? 'N/A',
          'visaEligibility': data['Visa Eligibility'] ?? 'N/A',
          'otherCosts': data['Other Costs / Notes'] ?? '',
        });
      }

      results.sort(
        (a, b) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])),
      );

      setState(() {
        _packageResults = results.take(20).toList();
        _isLoadingPackages = false;
      });

      if (_packageResults.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No packages found matching your criteria'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingPackages = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error finding packages: $e')));
    }
  }

  int _parseVisaCount(dynamic v) {
    if (v is int) return v;
    if (v is String) {
      final m = RegExp(r'\d+').firstMatch(v);
      return m != null ? int.parse(m.group(0)!) : 0;
    }
    return 0;
  }

  int _parseActivityCount(dynamic v) {
    if (v is int) return v;
    if (v is String) {
      final s = v.toLowerCase();
      if (s.contains('unlimited') || s.contains('any')) return 999;
      final m = RegExp(r'\d+').firstMatch(v);
      return m != null ? int.parse(m.group(0)!) : 0;
    }
    return 0;
  }

  double _parsePrice(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^\d\.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Find Your Perfect Freezone'),
        elevation: 0,
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.business_center,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Smart Business Setup Finder',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find the perfect freezone package in seconds',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Builder
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📝 Tell us about your business',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activity count selector 1..5
                  Row(
                    children: [
                      const Text(
                        'Activities:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      for (int i = 1; i <= 5; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: ChoiceChip(
                            label: Text('$i'),
                            selected: _maxActivities == i,
                            onSelected: (_) {
                              setState(() {
                                _maxActivities = i;
                                if (_selectedActivities.length > i) {
                                  _selectedActivities.removeRange(
                                    i,
                                    _selectedActivities.length,
                                  );
                                }
                              });
                            },
                            selectedColor: Colors.blue[600],
                            labelStyle: TextStyle(
                              color: _maxActivities == i
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_selectedActivities.length}/$_maxActivities selected',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Selected activities chips
                  if (_selectedActivities.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedActivities.map((a) {
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.green[700],
                              child: const Icon(
                                Icons.business,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            label: Text(a['name'] ?? ''),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _selectedActivities.removeWhere(
                                  (x) => x['id'] == a['id'],
                                );
                              });
                            },
                            backgroundColor: Colors.white,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Sentence builder row
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 12,
                    children: [
                      const Text(
                        'I want to do',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),

                      // Activity search box
                      SizedBox(
                        width: 320,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _activityController,
                              enabled:
                                  _selectedActivities.length < _maxActivities,
                              decoration: InputDecoration(
                                hintText:
                                    _selectedActivities.length >= _maxActivities
                                    ? 'Maximum activities selected'
                                    : 'Search and add activity (e.g., tech, consult)',
                                helperText: _isSearching
                                    ? 'Searching...'
                                    : (_activityController.text.isNotEmpty &&
                                          _searchResults.isEmpty)
                                    ? 'No results found'
                                    : (_selectedActivities.length >=
                                          _maxActivities)
                                    ? 'Remove an activity to add a different one'
                                    : null,
                                helperStyle: TextStyle(
                                  color: _isSearching
                                      ? Colors.blue[700]
                                      : (_selectedActivities.length >=
                                            _maxActivities)
                                      ? Colors.orange[700]
                                      : Colors.grey[600],
                                  fontSize: 11,
                                ),
                                prefixIcon: _isSearching
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.search),
                                suffixIcon: _activityController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _activityController.clear();
                                          setState(() => _searchResults = []);
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.blue[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {});
                                _searchActivities(value);
                              },
                            ),
                            if (_searchResults.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                constraints: const BoxConstraints(
                                  maxHeight: 240,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final r = _searchResults[index];
                                    return ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.blue[100],
                                        child: Icon(
                                          Icons.business,
                                          size: 16,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                      title: Text(
                                        r['name'] ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        '${r['sector']} • Code: ${r['activityCode']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      onTap: () {
                                        if (_selectedActivities.length >=
                                            _maxActivities) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'You can only select up to $_maxActivities activities',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        final exists = _selectedActivities.any(
                                          (a) => a['id'] == r['id'],
                                        );
                                        if (exists) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'This activity is already selected',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        setState(() {
                                          _selectedActivities.add({
                                            'id': r['id'],
                                            'name': r['name'],
                                          });
                                          _activityController.clear();
                                          _searchResults = [];
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),

                      const Text(
                        'business and I need',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),

                      // Visa count dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: DropdownButton<int>(
                          value: _selectedVisaCount,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.green,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          items: _visaCounts
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text('$c'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedVisaCount = v ?? 1),
                        ),
                      ),

                      const Text(
                        'visa(s) in',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),

                      // Emirate dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedEmirate,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.location_on,
                            color: Colors.orange,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          items: _emirates
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) => setState(
                            () => _selectedEmirate = v ?? 'Entire UAE',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Find packages
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoadingPackages ? null : _findPackages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoadingPackages
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Find Best Packages',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Results
            if (_packageResults.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Found ${_packageResults.length} Perfect Matches',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: _packageResults.length,
                itemBuilder: (context, index) =>
                    _buildPackageCard(_packageResults[index]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    final price = _parsePrice(package['price']);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[400]!],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.business, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package['freezone'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        package['packageName'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Colors.green,
                        size: 32,
                      ),
                      Text(
                        'AED ${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _info(
                        Icons.people,
                        'Visas',
                        '${package['visaCount']}',
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _info(
                        Icons.work,
                        'Activities',
                        '${package['activities']}',
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _info(
                        Icons.group,
                        'Shareholders',
                        '${package['shareholders']}',
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _info(
                        Icons.schedule,
                        'Tenure',
                        '${package['tenure']} years',
                        Colors.teal,
                      ),
                    ),
                    Expanded(
                      child: _info(
                        Icons.verified_user,
                        'Visa Type',
                        package['visaEligibility'],
                        Colors.indigo,
                      ),
                    ),
                  ],
                ),
                if ((package['otherCosts'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            package['otherCosts'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected: ${package['packageName']}'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get Started with This Package',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
