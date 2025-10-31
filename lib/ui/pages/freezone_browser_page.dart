import 'package:flutter/material.dart';
import '../theme.dart';
import '../../models/freezone.dart';
import '../../services/freezone_service.dart';
import '../widgets/freezone_card.dart';
import 'freezone_detail_page.dart';

class FreezoneBrowserPage extends StatefulWidget {
  final List<String>? prefilledRecommendations;
  final int? minVisas;
  final String? searchQuery;

  const FreezoneBrowserPage({
    super.key,
    this.prefilledRecommendations,
    this.minVisas,
    this.searchQuery,
  });

  @override
  State<FreezoneBrowserPage> createState() => _FreezoneBrowserPageState();
}

class _FreezoneBrowserPageState extends State<FreezoneBrowserPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FreeZoneService _service = FreeZoneService();

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedLicenseType;
  double? _minPrice;
  double? _maxPrice;
  int? _minVisas;
  bool _remoteSetupOnly = false;
  SortBy _sortBy = SortBy.name;

  // Compare mode
  bool _compareMode = false;
  final Set<String> _selectedZones = {};

  // Industry filter for "By Industry" tab
  String? _selectedIndustry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _searchQuery = _searchController.text);
      }
    });

    // Apply pre-filled parameters from AI Business Expert
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
      _searchQuery = widget.searchQuery!;
    }
    if (widget.minVisas != null) {
      _minVisas = widget.minVisas;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced AppBar with gradient
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Find Your Free Zone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                      AppColors.purple,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      bottom: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_compareMode ? Icons.close : Icons.compare_arrows),
                tooltip: _compareMode ? 'Exit Compare Mode' : 'Compare Zones',
                onPressed: () {
                  setState(() {
                    _compareMode = !_compareMode;
                    if (!_compareMode) {
                      _selectedZones.clear();
                    }
                  });
                },
              ),
              if (_compareMode && _selectedZones.length >= 2)
                IconButton(
                  icon: const Icon(Icons.check_circle),
                  tooltip: 'Compare Selected',
                  onPressed: _showComparison,
                ),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _showFilterSheet,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(
                      text: 'By Emirate',
                      icon: Icon(Icons.location_city, size: 20),
                    ),
                    Tab(
                      text: 'By Industry',
                      icon: Icon(Icons.business_center, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search bar and filters
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Enhanced search bar
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search free zones...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : Icon(Icons.mic, color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                // Active filters chips with better design
                if (_hasActiveFilters())
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_selectedLicenseType != null)
                          Chip(
                            label: Text(_selectedLicenseType!),
                            onDeleted: () =>
                                setState(() => _selectedLicenseType = null),
                            deleteIconColor: AppColors.primary,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          ),
                        if (_minPrice != null || _maxPrice != null)
                          Chip(
                            label: Text(
                              'Price: AED ${_minPrice ?? 0} - ${_maxPrice ?? 100000}',
                            ),
                            onDeleted: () => setState(() {
                              _minPrice = null;
                              _maxPrice = null;
                            }),
                            deleteIconColor: AppColors.primary,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          ),
                        if (_minVisas != null && _minVisas! > 0)
                          Chip(
                            label: Text('Min ${_minVisas} visas'),
                            onDeleted: () => setState(() => _minVisas = null),
                            deleteIconColor: AppColors.primary,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          ),
                        if (_remoteSetupOnly)
                          Chip(
                            label: const Text('Remote Setup'),
                            onDeleted: () =>
                                setState(() => _remoteSetupOnly = false),
                            deleteIconColor: AppColors.primary,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          ),
                        Chip(
                          label: const Text('Clear All'),
                          onDeleted: () {
                            setState(() {
                              _selectedLicenseType = null;
                              _minPrice = null;
                              _maxPrice = null;
                              _minVisas = null;
                              _remoteSetupOnly = false;
                            });
                          },
                          deleteIconColor: Colors.red,
                          backgroundColor: Colors.red.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ),
                // Compare mode banner
                if (_compareMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.compare_arrows,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_selectedZones.length} zones selected. Select at least 2 to compare.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [_buildByEmirate(), _buildByIndustry()],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedLicenseType != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _minVisas != null ||
        _remoteSetupOnly ||
        _sortBy != SortBy.name;
  }

  Widget _buildByEmirate() {
    return StreamBuilder<List<FreeZone>>(
      stream: _service.getAllZones(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var zones = snapshot.data!;
        zones = _applySearchAndFilters(zones);

        // Group by emirate
        final Map<String, List<FreeZone>> byEmirate = {};
        for (final zone in zones) {
          byEmirate.putIfAbsent(zone.emirate, () => []).add(zone);
        }

        if (byEmirate.isEmpty) {
          return const Center(child: Text('No free zones found'));
        }

        final sortedEmirates = byEmirate.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: sortedEmirates.length,
          itemBuilder: (context, index) {
            final emirate = sortedEmirates[index];
            final emirateZones = byEmirate[emirate]!;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                title: Text(
                  _getEmirateDisplayName(emirate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${emirateZones.length} free zones'),
                leading: Icon(Icons.place, color: AppColors.primary),
                children: emirateZones
                    .map(
                      (zone) => FreeZoneCard(
                        zone: zone,
                        onTap: () => _openZoneDetails(zone),
                        compareMode: _compareMode,
                        isSelected: _selectedZones.contains(zone.id),
                        onSelect: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedZones.add(zone.id);
                            } else {
                              _selectedZones.remove(zone.id);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildByIndustry() {
    return FutureBuilder<List<String>>(
      future: _service.getIndustries(),
      builder: (context, industriesSnapshot) {
        if (!industriesSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final industries = industriesSnapshot.data!;

        return Column(
          children: [
            // Industry selector
            Container(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedIndustry,
                decoration: const InputDecoration(
                  labelText: 'Select Industry or Activity',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  ...industries.map(
                    (industry) => DropdownMenuItem(
                      value: industry,
                      child: Text(industry),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedIndustry = value);
                },
                hint: const Text('Choose an industry to see free zones'),
              ),
            ),
            Expanded(
              child: _selectedIndustry == null
                  ? _buildEmptyIndustryState()
                  : StreamBuilder<List<FreeZone>>(
                      stream: _service.getZonesByIndustry(_selectedIndustry!),
                      builder: (context, zonesSnapshot) {
                        if (zonesSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${zonesSnapshot.error}'),
                          );
                        }

                        if (!zonesSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var zones = zonesSnapshot.data!;
                        zones = _applySearchAndFilters(zones);

                        return zones.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No free zones found for $_selectedIndustry',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Try selecting a different industry',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 16),
                                itemCount: zones.length,
                                itemBuilder: (context, index) {
                                  final zone = zones[index];
                                  return FreeZoneCard(
                                    zone: zone,
                                    onTap: () => _openZoneDetails(zone),
                                    compareMode: _compareMode,
                                    isSelected: _selectedZones.contains(
                                      zone.id,
                                    ),
                                    onSelect: (selected) {
                                      setState(() {
                                        if (selected == true) {
                                          _selectedZones.add(zone.id);
                                        } else {
                                          _selectedZones.remove(zone.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyIndustryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Your Industry',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose an industry or activity from the dropdown above to discover the best free zones for your business',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Icon(
              Icons.arrow_upward,
              size: 48,
              color: AppColors.primary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  List<FreeZone> _applySearchAndFilters(List<FreeZone> zones) {
    var filtered = zones;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (zone) =>
                zone.name.toLowerCase().contains(queryLower) ||
                zone.abbreviation.toLowerCase().contains(queryLower),
          )
          .toList();
    }

    // Apply filters
    filtered = _service.applyFilters(
      filtered,
      licenseType: _selectedLicenseType,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minVisas: _minVisas,
      remoteSetup: _remoteSetupOnly,
    );

    // Apply sorting
    filtered = _service.sortZones(filtered, _sortBy);

    return filtered;
  }

  void _openZoneDetails(FreeZone zone) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FreeZoneDetailPage(zone: zone)),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _FilterSheet(
          scrollController: scrollController,
          selectedLicenseType: _selectedLicenseType,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          minVisas: _minVisas,
          remoteSetupOnly: _remoteSetupOnly,
          sortBy: _sortBy,
          onApply:
              (licenseType, minPrice, maxPrice, minVisas, remoteSetup, sortBy) {
                setState(() {
                  _selectedLicenseType = licenseType;
                  _minPrice = minPrice;
                  _maxPrice = maxPrice;
                  _minVisas = minVisas;
                  _remoteSetupOnly = remoteSetup;
                  _sortBy = sortBy;
                });
                Navigator.pop(context);
              },
        ),
      ),
    );
  }

  void _showComparison() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _CompareZonesPage(
          zoneIds: _selectedZones.toList(),
          service: _service,
        ),
      ),
    );
  }

  String _getEmirateDisplayName(String emirate) {
    final map = {
      'abu_dhabi': 'Abu Dhabi',
      'dubai': 'Dubai',
      'sharjah': 'Sharjah',
      'ras_al_khaimah': 'Ras Al Khaimah',
      'ajman': 'Ajman',
      'fujairah': 'Fujairah',
      'umm_al_quwain': 'Umm Al Quwain',
    };
    return map[emirate] ??
        emirate
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
  }
}

// Filter Sheet Widget
class _FilterSheet extends StatefulWidget {
  final ScrollController scrollController;
  final String? selectedLicenseType;
  final double? minPrice;
  final double? maxPrice;
  final int? minVisas;
  final bool remoteSetupOnly;
  final SortBy sortBy;
  final Function(String?, double?, double?, int?, bool, SortBy) onApply;

  const _FilterSheet({
    required this.scrollController,
    required this.selectedLicenseType,
    required this.minPrice,
    required this.maxPrice,
    required this.minVisas,
    required this.remoteSetupOnly,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _licenseType;
  late double? _minPrice;
  late double? _maxPrice;
  late int? _minVisas;
  late bool _remoteSetup;
  late SortBy _sortBy;

  @override
  void initState() {
    super.initState();
    _licenseType = widget.selectedLicenseType;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _minVisas = widget.minVisas;
    _remoteSetup = widget.remoteSetupOnly;
    _sortBy = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: widget.scrollController,
        children: [
          const Text(
            'Filters & Sort',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // License Type
          const Text(
            'License Type',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _licenseType,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: null, child: Text('Any')),
              DropdownMenuItem(value: 'Mainland', child: Text('Mainland')),
              DropdownMenuItem(value: 'Freezone', child: Text('Freezone')),
              DropdownMenuItem(value: 'Offshore', child: Text('Offshore')),
            ],
            onChanged: (value) => setState(() => _licenseType = value),
          ),

          const SizedBox(height: 16),

          // Price Range
          const Text(
            'Price Range (AED)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _minPrice = double.tryParse(value),
                  controller: TextEditingController(
                    text: _minPrice?.toString() ?? '',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _maxPrice = double.tryParse(value),
                  controller: TextEditingController(
                    text: _maxPrice?.toString() ?? '',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Min Visas
          const Text(
            'Minimum Visas',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (value) => _minVisas = int.tryParse(value),
            controller: TextEditingController(
              text: _minVisas?.toString() ?? '',
            ),
          ),

          const SizedBox(height: 16),

          // Remote Setup
          CheckboxListTile(
            title: const Text('Remote Setup Available'),
            value: _remoteSetup,
            onChanged: (value) => setState(() => _remoteSetup = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),

          const SizedBox(height: 16),

          // Sort By
          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<SortBy>(
            isExpanded: true,
            initialValue: _sortBy,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: SortBy.name, child: Text('Name')),
              DropdownMenuItem(
                value: SortBy.costLowToHigh,
                child: Text('Cost (Low to High)'),
              ),
              DropdownMenuItem(
                value: SortBy.costHighToLow,
                child: Text('Cost (High to Low)'),
              ),
              DropdownMenuItem(
                value: SortBy.visaCapacity,
                child: Text('Visa Capacity'),
              ),
              DropdownMenuItem(value: SortBy.rating, child: Text('Rating')),
            ],
            onChanged: (value) =>
                setState(() => _sortBy = value ?? SortBy.name),
          ),

          const SizedBox(height: 24),

          // Apply Button
          ElevatedButton(
            onPressed: () {
              widget.onApply(
                _licenseType,
                _minPrice,
                _maxPrice,
                _minVisas,
                _remoteSetup,
                _sortBy,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Apply Filters', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// Compare Zones Page
class _CompareZonesPage extends StatelessWidget {
  final List<String> zoneIds;
  final FreeZoneService service;

  const _CompareZonesPage({required this.zoneIds, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Free Zones'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<FreeZone>>(
        stream: service.getAllZones(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final zones = snapshot.data!
              .where((zone) => zoneIds.contains(zone.id))
              .toList();

          if (zones.isEmpty) {
            return const Center(child: Text('No zones selected'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildComparisonTable('Zone Names', zones, (z) => z.name),
              _buildComparisonTable(
                'Emirate',
                zones,
                (z) => _getEmirateDisplayName(z.emirate),
              ),
              _buildComparisonTable(
                'Starting Price',
                zones,
                (z) => z.startingPriceFormatted,
              ),
              _buildComparisonTable(
                'License Types',
                zones,
                (z) => z.licenseTypes.join(', '),
              ),
              _buildComparisonTable(
                'Visa Capacity',
                zones,
                (z) => _getMaxVisas(z).toString(),
              ),
              _buildComparisonTable(
                'Remote Setup',
                zones,
                (z) => z.remoteSetup == true ? 'Yes' : 'No',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildComparisonTable(
    String title,
    List<FreeZone> zones,
    String Function(FreeZone) getValue,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...zones.map(
              (zone) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        zone.abbreviation,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(flex: 3, child: Text(getValue(zone))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getMaxVisas(FreeZone zone) {
    try {
      final allocation = zone.visaAllocation;
      int maxVisas = 0;
      for (final value in allocation.values) {
        if (value is int && value > maxVisas) {
          maxVisas = value;
        }
      }
      return maxVisas;
    } catch (e) {
      return 0;
    }
  }

  String _getEmirateDisplayName(String emirate) {
    final map = {
      'abu_dhabi': 'Abu Dhabi',
      'dubai': 'Dubai',
      'sharjah': 'Sharjah',
      'ras_al_khaimah': 'Ras Al Khaimah',
      'ajman': 'Ajman',
      'fujairah': 'Fujairah',
      'umm_al_quwain': 'Umm Al Quwain',
    };
    return map[emirate] ?? emirate;
  }
}
