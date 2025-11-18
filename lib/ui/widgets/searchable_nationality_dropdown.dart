import 'package:flutter/material.dart';

class SearchableNationalityDropdown extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;

  const SearchableNationalityDropdown({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.labelText = 'Nationality',
    this.hintText = 'Select nationality',
    this.prefixIcon,
  });

  @override
  State<SearchableNationalityDropdown> createState() =>
      _SearchableNationalityDropdownState();
}

class _SearchableNationalityDropdownState
    extends State<SearchableNationalityDropdown> {
  // Minimal country dataset with ISO codes for flag emojis.
  // Add more as needed.
  static const List<Map<String, String>> _countries = [
    {'name': 'United Arab Emirates', 'code': 'AE'},
    {'name': 'India', 'code': 'IN'},
    {'name': 'United States', 'code': 'US'},
    {'name': 'United Kingdom', 'code': 'GB'},
    {'name': 'Canada', 'code': 'CA'},
    {'name': 'Saudi Arabia', 'code': 'SA'},
    {'name': 'Qatar', 'code': 'QA'},
    {'name': 'Oman', 'code': 'OM'},
    {'name': 'Kuwait', 'code': 'KW'},
    {'name': 'Bahrain', 'code': 'BH'},
    {'name': 'Pakistan', 'code': 'PK'},
    {'name': 'Bangladesh', 'code': 'BD'},
    {'name': 'Philippines', 'code': 'PH'},
    {'name': 'Egypt', 'code': 'EG'},
    {'name': 'Jordan', 'code': 'JO'},
    {'name': 'Lebanon', 'code': 'LB'},
    {'name': 'South Africa', 'code': 'ZA'},
    {'name': 'Nigeria', 'code': 'NG'},
    {'name': 'Kenya', 'code': 'KE'},
    {'name': 'Ghana', 'code': 'GH'},
    {'name': 'Sri Lanka', 'code': 'LK'},
    {'name': 'Nepal', 'code': 'NP'},
    {'name': 'China', 'code': 'CN'},
    {'name': 'Singapore', 'code': 'SG'},
    {'name': 'Malaysia', 'code': 'MY'},
    {'name': 'Indonesia', 'code': 'ID'},
    {'name': 'Australia', 'code': 'AU'},
    {'name': 'New Zealand', 'code': 'NZ'},
    {'name': 'Turkey', 'code': 'TR'},
    {'name': 'France', 'code': 'FR'},
    {'name': 'Germany', 'code': 'DE'},
    {'name': 'Italy', 'code': 'IT'},
    {'name': 'Spain', 'code': 'ES'},
    {'name': 'Netherlands', 'code': 'NL'},
    {'name': 'Switzerland', 'code': 'CH'},
    {'name': 'Brazil', 'code': 'BR'},
    {'name': 'Argentina', 'code': 'AR'},
    {'name': 'Mexico', 'code': 'MX'},
    {'name': 'Russia', 'code': 'RU'},
    {'name': 'Ukraine', 'code': 'UA'},
    {'name': 'Japan', 'code': 'JP'},
    {'name': 'South Korea', 'code': 'KR'},
    {'name': 'Thailand', 'code': 'TH'},
    {'name': 'Vietnam', 'code': 'VN'},
    {'name': 'Morocco', 'code': 'MA'},
    {'name': 'Tunisia', 'code': 'TN'},
    {'name': 'Algeria', 'code': 'DZ'},
    {'name': 'Ethiopia', 'code': 'ET'},
    {'name': 'Uganda', 'code': 'UG'},
    {'name': 'Tanzania', 'code': 'TZ'},
  ];

  // Note: We rely on SVG flags via the country_flags package for consistent rendering on web.

  void _showSearchableDropdown() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _SearchableDropdownModal(
          countries: _countries,
          initialValue: widget.initialValue,
          onSelected: (String value) {
            widget.onChanged(value);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showSearchableDropdown,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            widget.prefixIcon ??
                Icon(Icons.flag_outlined, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.initialValue ?? widget.hintText ?? 'Select',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.initialValue != null
                      ? Colors.black87
                      : Colors.grey.shade600,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}

class _SearchableDropdownModal extends StatefulWidget {
  final List<Map<String, String>> countries;
  final String? initialValue;
  final ValueChanged<String> onSelected;

  const _SearchableDropdownModal({
    required this.countries,
    this.initialValue,
    required this.onSelected,
  });

  @override
  State<_SearchableDropdownModal> createState() =>
      _SearchableDropdownModalState();
}

class _SearchableDropdownModalState extends State<_SearchableDropdownModal>
    with SingleTickerProviderStateMixin {
  // Convert ISO country code (e.g., "AE") to flag emoji.
  // Falls back to a generic flag if conversion fails.
  String _flagEmoji(String code) {
    if (code.length != 2) return '🏳️';
    final upper = code.toUpperCase();
    final int base = 0x1F1E6; // Regional Indicator Symbol Letter A
    final int aCode = 'A'.codeUnitAt(0);
    final int first = base + (upper.codeUnitAt(0) - aCode);
    final int second = base + (upper.codeUnitAt(1) - aCode);
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  late TextEditingController _searchController;
  late List<Map<String, String>> _filteredCountries;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCountries = widget.countries;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterNationalities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.countries;
      } else {
        _filteredCountries = widget.countries
            .where(
              (c) => c['name']!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _selectNationality(String nationality) {
    widget.onSelected(nationality);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final modalHeight = mediaQuery.size.height * 0.75;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: modalHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      'Select Nationality',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search nationality...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterNationalities('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.deepPurple.shade600,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: _filterNationalities,
                ),
              ),

              const SizedBox(height: 12),

              // Results count
              if (_searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_filteredCountries.length} results',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // List
              Expanded(
                child: _filteredCountries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No nationalities found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _filteredCountries.length + 1,
                        itemBuilder: (context, index) {
                          // Last item is the "Other" option
                          if (index == _filteredCountries.length) {
                            final isSelected = widget.initialValue == 'Other';
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectNationality('Other'),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.deepPurple.shade50
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.more_horiz,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Other',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.deepPurple.shade600,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          final country = _filteredCountries[index];
                          final name = country['name']!;
                          final code = country['code']!;
                          final isSelected = name == widget.initialValue;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectNationality(name),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.deepPurple.shade50
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _flagEmoji(code),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? Colors.deepPurple.shade700
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.deepPurple.shade600,
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
