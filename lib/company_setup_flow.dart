import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wazeet/utils/industry_loader.dart';
import 'package:wazeet/ui/pages/applications_page.dart';
// Old AI-based services removed from this flow
import 'package:wazeet/services/freezone_service.dart';
import 'package:wazeet/models/freezone_package_recommendation.dart';
import 'package:wazeet/pages/package_recommendations_page.dart';

// AI-based recommender removed; pricing will be handled by backend service

// =============================================================
// Shareholder Model
// =============================================================

class Shareholder {
  final String name;
  final String nationality;
  final DateTime? dateOfBirth;

  Shareholder({
    required this.name,
    required this.nationality,
    this.dateOfBirth,
  });

  Shareholder copyWith({
    String? name,
    String? nationality,
    DateTime? dateOfBirth,
  }) {
    return Shareholder(
      name: name ?? this.name,
      nationality: nationality ?? this.nationality,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}

// =============================================================
// State Management
// =============================================================

class CompanySetupData {
  final List<String> businessActivities;
  final int shareholdersCount;
  final List<Shareholder> shareholders;
  // Aggregate visa count (sum of employment + investor)
  final int visaCount;
  // Derived type: 'Employment', 'Investor', 'Mixed', or '' (none)
  final String visaType;
  final int licenseTenureYears;
  final String entityType;
  final String emirate;
  // New individual visa counts
  final int employmentVisaCount;
  final int investorVisaCount;
  // New fields: office space type & jurisdiction type
  final String officeSpaceType; // e.g., Flexi Desk, Private Office
  final String jurisdictionType; // e.g., Free Zone, Mainland, Offshore

  CompanySetupData({
    this.businessActivities = const [],
    this.shareholdersCount = 1,
    this.shareholders = const [],
    this.visaCount = 0,
    this.visaType = '',
    this.licenseTenureYears = 1,
    this.entityType = '',
    this.emirate = '',
    this.employmentVisaCount = 0,
    this.investorVisaCount = 0,
    this.officeSpaceType = '',
    this.jurisdictionType = '',
  });

  CompanySetupData copyWith({
    List<String>? businessActivities,
    int? shareholdersCount,
    List<Shareholder>? shareholders,
    int? visaCount,
    String? visaType,
    int? licenseTenureYears,
    String? entityType,
    String? emirate,
    int? employmentVisaCount,
    int? investorVisaCount,
    String? officeSpaceType,
    String? jurisdictionType,
  }) {
    return CompanySetupData(
      businessActivities: businessActivities ?? this.businessActivities,
      shareholdersCount: shareholdersCount ?? this.shareholdersCount,
      shareholders: shareholders ?? this.shareholders,
      visaCount: visaCount ?? this.visaCount,
      visaType: visaType ?? this.visaType,
      licenseTenureYears: licenseTenureYears ?? this.licenseTenureYears,
      entityType: entityType ?? this.entityType,
      emirate: emirate ?? this.emirate,
      employmentVisaCount: employmentVisaCount ?? this.employmentVisaCount,
      investorVisaCount: investorVisaCount ?? this.investorVisaCount,
      officeSpaceType: officeSpaceType ?? this.officeSpaceType,
      jurisdictionType: jurisdictionType ?? this.jurisdictionType,
    );
  }
}

class CompanySetupController extends Notifier<CompanySetupData> {
  @override
  CompanySetupData build() {
    return CompanySetupData();
  }

  void toggleActivity(String activity) {
    final activities = List<String>.from(state.businessActivities);
    if (activities.contains(activity)) {
      activities.remove(activity);
    } else {
      if (activities.length < 5) {
        activities.add(activity);
      }
    }
    state = state.copyWith(businessActivities: activities);
  }

  void setShareholdersCount(int count) {
    if (count >= 1 && count <= 10) {
      final currentShareholders = List<Shareholder>.from(state.shareholders);

      // Add empty shareholders if count increased
      while (currentShareholders.length < count) {
        currentShareholders.add(
          Shareholder(name: '', nationality: '', dateOfBirth: null),
        );
      }

      // Remove shareholders if count decreased
      while (currentShareholders.length > count) {
        currentShareholders.removeLast();
      }

      state = state.copyWith(
        shareholdersCount: count,
        shareholders: currentShareholders,
      );
    }
  }

  void updateShareholder(int index, Shareholder shareholder) {
    if (index >= 0 && index < state.shareholders.length) {
      final updatedShareholders = List<Shareholder>.from(state.shareholders);
      updatedShareholders[index] = shareholder;
      state = state.copyWith(shareholders: updatedShareholders);
    }
  }

  void setVisaCount(int count) {
    if (count >= 0 && count <= 50) {
      state = state.copyWith(visaCount: count);
    }
  }

  void setVisaType(String type) {
    state = state.copyWith(visaType: type);
  }

  // New independent visa counters. Each clamped 0–10.
  void setEmploymentVisaCount(int count) {
    if (count < 0 || count > 10) return;
    final newTotal = count + state.investorVisaCount;
    final newType = newTotal == 0
        ? ''
        : (count > 0 && state.investorVisaCount > 0
              ? 'Mixed'
              : (count > 0
                    ? 'Employment'
                    : (state.investorVisaCount > 0 ? 'Investor' : '')));
    state = state.copyWith(
      employmentVisaCount: count,
      visaCount: newTotal,
      visaType: newType,
    );
  }

  void setInvestorVisaCount(int count) {
    if (count < 0 || count > 10) return;
    final newTotal = state.employmentVisaCount + count;
    final newType = newTotal == 0
        ? ''
        : (state.employmentVisaCount > 0 && count > 0
              ? 'Mixed'
              : (count > 0
                    ? 'Investor'
                    : (state.employmentVisaCount > 0 ? 'Employment' : '')));
    state = state.copyWith(
      investorVisaCount: count,
      visaCount: newTotal,
      visaType: newType,
    );
  }

  void setLicenseTenureYears(int years) {
    if (years >= 1 && years <= 3) {
      state = state.copyWith(licenseTenureYears: years);
    }
  }

  void setEntityType(String type) {
    state = state.copyWith(entityType: type);
  }

  void setEmirate(String emirate) {
    state = state.copyWith(emirate: emirate);
  }

  void setOfficeSpaceType(String type) {
    state = state.copyWith(officeSpaceType: type);
  }

  void setJurisdictionType(String type) {
    state = state.copyWith(jurisdictionType: type);
  }
}

final setupProvider =
    NotifierProvider<CompanySetupController, CompanySetupData>(
      CompanySetupController.new,
    );

// Entity type options
const kEntityOptions = [
  {
    'key': 'FZ-LLC',
    'label': 'Free Zone LLC',
    'desc': 'Limited Liability Company',
  },
  {
    'key': 'FZ-EST',
    'label': 'Free Zone Establishment',
    'desc': 'Sole Proprietorship',
  },
  {
    'key': 'BRANCH',
    'label': 'Branch Office',
    'desc': 'Branch of existing company',
  },
];

// =============================================================
// Main Company Setup Flow Widget
// =============================================================

class CompanySetupFlow extends ConsumerStatefulWidget {
  const CompanySetupFlow({super.key});

  @override
  ConsumerState<CompanySetupFlow> createState() => _CompanySetupFlowState();
}

class _CompanySetupFlowState extends ConsumerState<CompanySetupFlow> {
  int _currentStep = 0;
  String _searchQuery = '';

  final List<String> _stepTitles = [
    'Business Activities',
    'Shareholders',
    'Visa Requirements',
    'Package Recommendations',
    'Summary',
  ];

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _ActivitiesStep(
          query: _searchQuery,
          onQueryChanged: (q) => setState(() => _searchQuery = q),
        );
      case 1:
        return _ShareholdersStep();
      case 2:
        return _VisaStep();
      case 3:
        return const _RecommenderStep();
      case 4:
        return _SummaryStep(onComplete: () => Navigator.pop(context));
      default:
        return const Center(child: Text('Unknown step'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _stepTitles.length;

    return Consumer(
      builder: (context, ref, _) {
        final data = ref.watch(setupProvider);
        final canProceed = _canProceedFromCurrentStep(data);

        return Scaffold(
          body: Column(
            children: [
              _Header(
                title: _stepTitles[_currentStep],
                progress: progress,
                accent: Colors.deepPurple,
              ),
              Expanded(child: _buildCurrentStep()),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: canProceed
                              ? (_currentStep == _stepTitles.length - 1
                                    ? () => Navigator.pop(context)
                                    : _nextStep)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade500,
                          ),
                          child: Text(
                            _currentStep == _stepTitles.length - 1
                                ? 'Finish'
                                : 'Continue',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canProceedFromCurrentStep(CompanySetupData data) {
    switch (_currentStep) {
      case 0: // Business Activities
        return data.businessActivities.isNotEmpty;
      case 1: // Shareholders - always allow
      case 2: // Visa - always allow
      case 3: // Package Recommendations - always allow
      case 4: // Summary - always allow
      default:
        return true;
    }
  }
}

// =============================================================
// AI Recommender step removed; pricing and recommendations will be handled
// by backend. Summary step will later display fetched pricing and options.

List<ActivityData> _filterByKeywords(
  List<ActivityData> activities,
  String query,
) {
  final queryLower = query.toLowerCase().trim();

  // Only filter if user has typed at least 2 characters
  if (queryLower.isEmpty || queryLower.length < 2) {
    return activities;
  }

  // Split query into keywords (words separated by spaces)
  final keywords = queryLower
      .split(RegExp(r'\s+'))
      .where((k) => k.isNotEmpty) // Remove empty strings
      .toList();

  if (keywords.isEmpty) {
    return activities;
  }

  // Filter activities that match ALL keywords (AND logic) in the NAME only
  final results = <ActivityData>[];

  for (final activity in activities) {
    final activityName = activity.name.toLowerCase();

    // Check if ALL keywords are present in the activity NAME only
    bool matchesAll = true;
    for (final keyword in keywords) {
      // Each keyword must appear in the activity name
      if (!activityName.contains(keyword)) {
        matchesAll = false;
        break; // Early exit if any keyword doesn't match
      }
    }

    if (matchesAll) {
      results.add(activity);
    }
  }

  return results;
}

// Helper function to highlight matching keywords in text
List<TextSpan> _highlightKeywords(String text, String query) {
  if (query.isEmpty || query.length < 2) {
    return [TextSpan(text: text)];
  }

  final keywords = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((k) => k.isNotEmpty)
      .toList();

  if (keywords.isEmpty) {
    return [TextSpan(text: text)];
  }

  final List<TextSpan> spans = [];
  String remainingText = text;

  while (remainingText.isNotEmpty) {
    int earliestMatchIndex = -1;
    String? matchedKeyword;

    // Find the earliest keyword match in the remaining text
    for (final keyword in keywords) {
      final index = remainingText.toLowerCase().indexOf(keyword);
      if (index != -1 &&
          (earliestMatchIndex == -1 || index < earliestMatchIndex)) {
        earliestMatchIndex = index;
        matchedKeyword = keyword;
      }
    }

    if (earliestMatchIndex == -1) {
      // No more matches, add remaining text
      spans.add(TextSpan(text: remainingText));
      break;
    }

    // Add text before match (if any)
    if (earliestMatchIndex > 0) {
      spans.add(TextSpan(text: remainingText.substring(0, earliestMatchIndex)));
    }

    // Add highlighted match
    final matchedText = remainingText.substring(
      earliestMatchIndex,
      earliestMatchIndex + matchedKeyword!.length,
    );
    spans.add(
      TextSpan(
        text: matchedText,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          backgroundColor: Color(0xFFFFEB3B), // Yellow highlight
          color: Colors.black87,
        ),
      ),
    );

    // Move to text after the match
    remainingText = remainingText.substring(
      earliestMatchIndex + matchedKeyword.length,
    );
  }

  return spans;
}

class _ActivitiesStep extends ConsumerStatefulWidget {
  const _ActivitiesStep({required this.query, required this.onQueryChanged});
  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  ConsumerState<_ActivitiesStep> createState() => _ActivitiesStepState();
}

class _ActivitiesStepState extends ConsumerState<_ActivitiesStep> {
  late final Future<List<ActivityData>> _activitiesFuture;
  List<ActivityData>? _cachedActivities;
  List<ActivityData>? _cachedFilteredResults;
  String _lastQuery = '';
  int? _expandedActivityIndex; // Track which activity is expanded

  @override
  void initState() {
    super.initState();
    // Use custom-activities.json for simplified activity list
    // Or use excel-to-json.industry-grouped.json for complete list
    _activitiesFuture = loadAllActivitiesWithDescriptions(
      'assets/images/custom-activities.json',
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    return FutureBuilder<List<ActivityData>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading activities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allActivities = snapshot.data ?? [];

        // Cache activities on first load
        _cachedActivities ??= allActivities;

        // Use cached results if query hasn't changed
        List<ActivityData> filtered;
        if (widget.query == _lastQuery && _cachedFilteredResults != null) {
          filtered = _cachedFilteredResults!;
        } else {
          // Support multi-keyword search (3-4 keywords)
          filtered = _filterByKeywords(allActivities, widget.query);
          _cachedFilteredResults = filtered;
          _lastQuery = widget.query;
        }

        final isValid = data.businessActivities.isNotEmpty;

        return Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Business Activities',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose 1-5 activities. You can change this later.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: const Icon(Icons.search),
                        hintText:
                            'Type 2+ letters to search (e.g., "3D print", "manufacturing")',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: widget.onQueryChanged,
                    ),
                  ),
                  if (widget.query.isNotEmpty && widget.query.length >= 2) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tip: Use multiple keywords for better results (e.g., "construction building", "3D printing products")',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (widget.query.isNotEmpty && widget.query.length < 2) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Type at least 2 characters to search',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (!isValid)
                    const Text(
                      'Please select at least one activity to proceed.',
                      style: TextStyle(color: Colors.red),
                    ),
                  if (data.businessActivities.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: data.businessActivities.length >= 5
                            ? Colors.orange.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            data.businessActivities.length >= 5
                                ? Icons.info
                                : Icons.check_circle,
                            color: data.businessActivities.length >= 5
                                ? Colors.orange.shade700
                                : Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data.businessActivities.length >= 5
                                  ? '5 activities selected (maximum reached)'
                                  : '${data.businessActivities.length} ${data.businessActivities.length == 1 ? "activity" : "activities"} selected',
                              style: TextStyle(
                                color: data.businessActivities.length >= 5
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Activities list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
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
                              'No activities found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.query.length < 2
                                  ? 'Type at least 2 characters to search'
                                  : 'Try different keywords or check spelling',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (widget.query.isNotEmpty &&
                                widget.query.length >= 2) ...[
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () => widget.onQueryChanged(''),
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear search'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.deepPurple.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final activity = filtered[index];
                        final isSelected = data.businessActivities.contains(
                          activity.name,
                        );
                        final isLimitReached =
                            data.businessActivities.length >= 5;
                        final isDisabled = isLimitReached && !isSelected;
                        final isExpanded = _expandedActivityIndex == index;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isSelected ? 2 : 0,
                          color: isDisabled
                              ? Colors.grey.shade100
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main card content (always visible)
                              InkWell(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                  bottom: Radius.circular(12),
                                ),
                                onTap: () {
                                  setState(() {
                                    // Toggle expansion (accordion style - only one open at a time)
                                    _expandedActivityIndex = isExpanded
                                        ? null
                                        : index;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title and description with expand indicator
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Selection checkbox
                                          GestureDetector(
                                            onTap: isDisabled
                                                ? null
                                                : () {
                                                    controller.toggleActivity(
                                                      activity.name,
                                                    );
                                                  },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                top: 2,
                                              ),
                                              child: Icon(
                                                isSelected
                                                    ? Icons.check_circle
                                                    : Icons
                                                          .radio_button_unchecked,
                                                color: isDisabled
                                                    ? Colors.grey.shade300
                                                    : (isSelected
                                                          ? Colors.blue.shade700
                                                          : Colors
                                                                .grey
                                                                .shade400),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Activity title and description
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isDisabled
                                                          ? Colors.grey.shade400
                                                          : (isSelected
                                                                ? Colors
                                                                      .blue
                                                                      .shade900
                                                                : Colors
                                                                      .black87),
                                                    ),
                                                    children:
                                                        _highlightKeywords(
                                                          activity.name,
                                                          widget.query,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  activity.description,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDisabled
                                                        ? Colors.grey.shade400
                                                        : Colors.grey.shade700,
                                                    height: 1.4,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Expand/collapse indicator
                                          Icon(
                                            isExpanded
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: Colors.grey.shade600,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Expanded details (ESR & Documents) - hidden by default
                              if (isExpanded) ...[
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ESR Applicability
                                      _TintedSection(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: const [
                                                Text(
                                                  'ESR Applicability',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Tooltip(
                                                  message:
                                                      'Economic Substance Regulations: certain activities must file annual ESR notifications and reports.',
                                                  child: Icon(
                                                    Icons.info_outline,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _esrSummary(activity.name),
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              _esrDetails(activity.name),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Additional Documents Required
                                      _TintedSection(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: const [
                                                Text(
                                                  'Additional Documents Required',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Tooltip(
                                                  message:
                                                      'Extra supporting documents commonly required by the licensing authority.',
                                                  child: Icon(
                                                    Icons.info_outline,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children:
                                                  _documentsFor(
                                                    activity.name,
                                                  ).map((doc) {
                                                    return ActionChip(
                                                      avatar: const Icon(
                                                        Icons.description,
                                                        size: 16,
                                                      ),
                                                      label: Text(doc['name']!),
                                                      onPressed: () =>
                                                          _showDocInfo(
                                                            context,
                                                            doc,
                                                          ),
                                                      backgroundColor:
                                                          Colors.white,
                                                      side: BorderSide(
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ---- Helper tinted container ----
class _TintedSection extends StatelessWidget {
  final Widget child;
  const _TintedSection({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}

// ---- Activity details helpers (ESR + Documents) ----
extension on _ActivitiesStepState {
  bool _esrRequired(String name) {
    final n = name.toLowerCase();
    return n.contains('holding') ||
        n.contains('headquarter') ||
        n.contains('distribution') ||
        n.contains('service') || // relevant service centers
        n.contains('finance') ||
        n.contains('leasing') ||
        n.contains('insurance') ||
        n.contains('shipping') ||
        n.contains('intellectual property') ||
        n.contains('ip') ||
        n.contains('bank');
  }

  String _esrSummary(String name) {
    final required = _esrRequired(name);
    return required
        ? '✅ ESR Required – Submit annual economic substance declaration.'
        : '⚪ Not applicable under ESR regulations.';
  }

  String _esrDetails(String name) {
    if (_esrRequired(name)) {
      return 'This activity is generally considered a Relevant Activity for ESR. Licensees must file an annual ESR Notification and, if conditions are met, an ESR Report with the authority.';
    }
    return 'Based on typical classifications, this activity does not fall under ESR Relevant Activities. Always confirm with your free zone authority.';
  }

  List<Map<String, String>> _documentsFor(String name) {
    final n = name.toLowerCase();
    final base = <Map<String, String>>[
      {
        'name': 'Owner Passport',
        'desc': 'Clear color copy of all owners/UBOs.',
      },
      {
        'name': 'Business Plan',
        'desc': '1–2 page summary of proposed activity and operations.',
      },
      {
        'name': 'NOC (if employed)',
        'desc': 'No Objection Certificate from current employer if applicable.',
      },
      {
        'name': 'Shareholder Resolution',
        'desc': 'Resolution to incorporate and appoint managers.',
      },
      {
        'name': 'MOA/AOA',
        'desc': 'Memorandum/Articles for LLC or corporate shareholder.',
      },
    ];
    if (n.contains('transport') || n.contains('towing')) {
      base.addAll([
        {
          'name': 'Vehicle List',
          'desc': 'List of operational vehicles/fleet details.',
        },
        {'name': 'Driver Licenses', 'desc': 'Valid UAE licenses for drivers.'},
      ]);
    } else if (n.contains('document')) {
      base.add({
        'name': 'Sample Templates',
        'desc': 'Examples of documents offered for clients.',
      });
    } else if (n.contains('retail') ||
        n.contains('(g.p.s)') ||
        n.contains('gps')) {
      base.add({
        'name': 'Supplier Invoices',
        'desc': 'Proof of supply channels for devices/hardware.',
      });
    }
    return base;
  }

  void _showDocInfo(BuildContext context, Map<String, String> doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      doc['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  doc['desc']!,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload (placeholder)'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Coming soon',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShareholdersStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Number of Shareholders',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select the number of shareholders for your company',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Counter Display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.deepPurple.shade100,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${data.shareholdersCount}',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple.shade700,
                        letterSpacing: -2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Plus and Minus Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus Button
                      Material(
                        color: data.shareholdersCount > 1
                            ? Colors.red.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: data.shareholdersCount > 1
                              ? () {
                                  controller.setShareholdersCount(
                                    data.shareholdersCount - 1,
                                  );
                                }
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: data.shareholdersCount > 1
                                    ? Colors.red.shade200
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.remove_rounded,
                              size: 40,
                              color: data.shareholdersCount > 1
                                  ? Colors.red.shade600
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 40),

                      // Plus Button
                      Material(
                        color: data.shareholdersCount < 10
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: data.shareholdersCount < 10
                              ? () {
                                  controller.setShareholdersCount(
                                    data.shareholdersCount + 1,
                                  );
                                }
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: data.shareholdersCount < 10
                                    ? Colors.green.shade200
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 40,
                              color: data.shareholdersCount < 10
                                  ? Colors.green.shade600
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Range: 1 - 10 shareholders',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisaStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(setupProvider);
    final controller = ref.read(setupProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          const Text(
            'Visa Requirements',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Adjust visa slots needed per type (0–10 each).',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          // Employment Visa Card
          _VisaCounterCard(
            title: 'Employment Visa',
            subtitle: 'For employees and managers hired by the company.',
            count: data.employmentVisaCount,
            onIncrement: () =>
                controller.setEmploymentVisaCount(data.employmentVisaCount + 1),
            onDecrement: () =>
                controller.setEmploymentVisaCount(data.employmentVisaCount - 1),
          ),
          const SizedBox(height: 16),
          // Investor Visa Card
          _VisaCounterCard(
            title: 'Investor Visa',
            subtitle: 'For shareholders/owners with qualifying share capital.',
            count: data.investorVisaCount,
            onIncrement: () =>
                controller.setInvestorVisaCount(data.investorVisaCount + 1),
            onDecrement: () =>
                controller.setInvestorVisaCount(data.investorVisaCount - 1),
          ),
          const SizedBox(height: 24),
          // Total row - Enhanced
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.deepPurple.shade100.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple.shade200, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Total Visa Quota Approved',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple.shade900,
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: data.visaCount.toDouble(),
                    end: data.visaCount.toDouble(),
                  ),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Text(
                      '${value.round()}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple.shade800,
                        letterSpacing: -1,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Office Space & Jurisdiction dropdowns
          _OfficeAndJurisdictionSection(data: data, controller: controller),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text(
                'What does visa processing involve?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                if (data.employmentVisaCount == 0 &&
                    data.investorVisaCount == 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Text(
                      'Select visa slots above to view detailed requirements. UAE visa processing includes entry permits, medical examinations, Emirates ID registration, and final visa stamping as per MOHRE and ICP regulations.',
                      style: TextStyle(height: 1.5),
                    ),
                  )
                else ...[
                  if (data.investorVisaCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business_center,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Investor Visa Process',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Complete Process as per UAE Federal Decree-Law No. 6 of 2022:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildVisaStep(
                            '1. Entry Permit Application',
                            'Submit e-visa application through ICP (Immigration & Checkpoints Portal) or relevant Free Zone authority. Required documents: passport copy, company trade license, establishment card, investment proof.',
                          ),
                          _buildVisaStep(
                            '2. Establishment Card Verification',
                            'Obtain Establishment Card from Ministry of Human Resources & Emiratisation (MOHRE) for Mainland or Free Zone authority. Verify minimum share capital as per Authority requirements (typically AED 1M+ for investor visas).',
                          ),
                          _buildVisaStep(
                            '3. Entry Permit Issuance',
                            'Validity: 60 days from issuance. Entry to UAE must occur within this period. Digital e-visa sent via email and accessible through ICP portal.',
                          ),
                          _buildVisaStep(
                            '4. Medical Fitness Test',
                            'Mandatory health screening at MOHAP-approved medical centers. Tests include: blood tests (HIV, Hepatitis B/C, Syphilis), chest X-ray (tuberculosis), and general physical examination. Results valid for 3 months.',
                          ),
                          _buildVisaStep(
                            '5. Emirates ID Registration',
                            'Biometric enrollment at Federal Authority for Identity, Citizenship, Customs and Ports Security (ICP) typing centers. Includes: fingerprints, eye scan, photograph. ID card delivery within 5-7 working days.',
                          ),
                          _buildVisaStep(
                            '6. Visa Stamping / E-Visa Activation',
                            'Final step: Residence visa stamped in passport or e-visa activated in system. Validity: 2 years (renewable) or 3 years for Golden Visa eligible investors (investment ≥ AED 2M).',
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.amber.shade900,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Important Notes:\n• Investor visa holders can sponsor family members\n• No labor contract required for investors\n• Minimum share capital varies by Emirate and Free Zone\n• Processing time: 10-15 working days (post-license)\n• Fees vary by Free Zone (AED 3,000 - 6,000 typical)',
                                    style: TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (data.employmentVisaCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.badge_outlined,
                                color: Colors.green.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Employment Visa Process',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Process as per MOHRE Ministerial Resolution No. 1186 of 2022:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildVisaStep(
                            '1. Work Permit Application',
                            'Submit through MOHRE portal or Free Zone authority. Required: employment contract, educational certificates (attested by UAE Embassy/MOFA), passport copy, company license.',
                          ),
                          _buildVisaStep(
                            '2. Entry Permit (E-Visa)',
                            'ICP approval for employee entry. Valid for 60 days. Employee must enter UAE within validity period. Digital entry permit accessible via ICP/GDRFA portals.',
                          ),
                          _buildVisaStep(
                            '3. Status Change (if applicable)',
                            'For candidates already in UAE on visit/tourist visa. Change status to employment residence without exit. Additional fee: AED 500-800. Processing: 2-3 working days.',
                          ),
                          _buildVisaStep(
                            '4. Medical Fitness Certificate',
                            'MOHAP-approved center examination (same as investor visa). Mandatory for all employment visa applicants. Cost: AED 300-500 per person. Tests: HIV, Hepatitis B/C, TB screening, pregnancy test (for females aged 18-60).',
                          ),
                          _buildVisaStep(
                            '5. Emirates ID Biometric Enrollment',
                            'Register at ICP-approved typing center. Biometrics: 10 fingerprints, iris scan, photo. Fee: AED 370 for 2-year card, AED 670 for 3-year card. Card delivery: 5-7 working days to registered address.',
                          ),
                          _buildVisaStep(
                            '6. Labor Contract Registration',
                            'Mainland: Register unified contract with MOHRE. Includes: salary, job title, benefits, working hours (max 48 hours/week as per UAE Labour Law). Free Zone: Equivalent employment contract as per zone regulations.',
                          ),
                          _buildVisaStep(
                            '7. Residence Visa Stamping',
                            'Final residence visa stamped in passport. Validity: 2 years (renewable). Must be completed within 60 days of entry permit. Fee included in package: AED 2,500-4,000 total.',
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.amber.shade900,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Employment Visa Guidelines:\n• Quota system applies (company size determines visa allocation)\n• Minimum salary requirements vary by job category and nationality\n• Educational certificates must be attested by MOFA\n• Employee can sponsor family once earning ≥ AED 4,000-5,000/month (or AED 3,000 + accommodation)\n• Total processing time: 5-10 working days\n• Visa ban period: 6 months if employee resigns within 6 months of joining (unless waived by employer)',
                                    style: TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // General UAE Visa Regulations
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.gavel,
                              color: Colors.purple.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'UAE Visa Regulations Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRegulationPoint(
                          'Governing Laws',
                          'Federal Decree-Law No. 6 of 2022 on Entry & Residence of Foreigners\nCabinet Resolution No. 360 of 2023 (Executive Regulations)\nMOHRE Ministerial Resolutions on Work Permits',
                        ),
                        _buildRegulationPoint(
                          'Visa Validity & Renewal',
                          '• Standard residence visa: 2 years renewable\n• Golden Visa: 10 years (for investors ≥ AED 2M, specialists, entrepreneurs)\n• Green Visa: 5 years (for skilled professionals, freelancers)\n• Renewal must occur before expiry to avoid AED 25-50/day overstay fines',
                        ),
                        _buildRegulationPoint(
                          'Cancellation Process',
                          'Employer must cancel visa within 30 days of employee departure. Grace period post-cancellation: 30 days to find new employment or exit UAE. Overstaying incurs fines: AED 50/day (first 6 months), AED 100/day thereafter.',
                        ),
                        _buildRegulationPoint(
                          'Free Zone vs Mainland',
                          'Free Zone visas tied to Free Zone license (office required). Mainland visas allow work anywhere in UAE. Some Free Zones offer flexible desk options reducing costs.',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widgets for visa information display
Widget _buildVisaStep(String title, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 14, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildRegulationPoint(String title, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: Colors.purple.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.purple.shade900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

// Enhanced reusable card with +/- counter for visa types
class _VisaCounterCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const _VisaCounterCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final selected = count > 0;
    final borderColor = selected
        ? Colors.deepPurple.shade400
        : Colors.grey.shade300;
    final backgroundColor = selected
        ? Colors.deepPurple.shade50.withValues(alpha: 0.5)
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: selected ? 2 : 1.5),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.deepPurple.shade600
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selected ? Colors.white : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: selected
                              ? Colors.deepPurple.shade900
                              : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _NumberButton(
                  icon: Icons.remove_rounded,
                  onTap: onDecrement,
                  enabled: count > 0,
                ),
                Expanded(
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: count.toDouble(),
                        end: count.toDouble(),
                      ),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return Text(
                          '${value.round()}',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: selected
                                ? Colors.deepPurple.shade700
                                : Colors.grey.shade700,
                            letterSpacing: -1.5,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _NumberButton(
                  icon: Icons.add_rounded,
                  onTap: onIncrement,
                  enabled: count < 10,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '0–10',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficeAndJurisdictionSection extends StatelessWidget {
  final CompanySetupData data;
  final CompanySetupController controller;
  const _OfficeAndJurisdictionSection({
    required this.data,
    required this.controller,
  });

  // Office space type descriptions
  static const Map<String, String> _officeDescriptions = {
    'Co-Working / Flexi-desk':
        'Shared workspace with flexible desk arrangements. Ideal for freelancers and small teams. Cost-effective with access to common amenities.',
    'Physical Office':
        'Traditional private office space for your business. Full control over your workspace with dedicated amenities.',
    'Dedicated Office':
        'A private, enclosed office space exclusively for your team. Professional environment with more privacy than co-working.',
    'Dedicated 1 Desk':
        'A single dedicated desk in a shared office environment. Perfect for solo entrepreneurs or remote workers needing a professional address.',
  };

  // Jurisdiction descriptions
  static const Map<String, String> _jurisdictionDescriptions = {
    'Mainland':
        'Mainland UAE companies can trade freely within the UAE and internationally. Requires a local service agent or sponsor. Suitable for businesses targeting the local market.',
    'Freezone':
        'Free zones offer 100% foreign ownership, tax exemptions, and simplified setup. Ideal for international businesses. Some restrictions on trading within UAE mainland.',
    'Not sure':
        'Not sure which is best? We\'ll help you choose based on your business activities, target market, and expansion plans.',
  };

  void _showInfoDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.deepPurple.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget buildDropdown({
    required BuildContext context,
    required String label,
    required List<String> items,
    required String value,
    required ValueChanged<String?> onChanged,
    required Map<String, String> descriptions,
    IconData icon = Icons.arrow_drop_down_circle,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.deepPurple.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple.shade400, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: Colors.deepPurple.shade400,
                    size: 20,
                  ),
                  onPressed: () {
                    _showInfoDialog(
                      context,
                      label,
                      'Tap any option below to see details about it.',
                    );
                  },
                  tooltip: 'Info about $label options',
                ),
              ],
            ),
            const SizedBox(height: 4),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value.isEmpty ? null : value,
                hint: Text(
                  'Select $label',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                items: items.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Row(
                      children: [
                        Expanded(child: Text(e)),
                        if (descriptions.containsKey(e))
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: Colors.grey.shade600,
                              size: 18,
                            ),
                            onPressed: () {
                              _showInfoDialog(context, e, descriptions[e]!);
                            },
                            tooltip: 'Info about $e',
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final officeOptions = [
      'Co-Working / Flexi-desk',
      'Physical Office',
      'Dedicated Office',
      'Dedicated 1 Desk',
    ];
    final jurisdictionOptions = ['Mainland', 'Freezone', 'Not sure'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location & Space Preferences',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        buildDropdown(
          context: context,
          label: 'Type of Office Space',
          items: officeOptions,
          value: data.officeSpaceType,
          onChanged: (v) => controller.setOfficeSpaceType(v ?? ''),
          descriptions: _officeDescriptions,
          icon: Icons.meeting_room,
        ),
        const SizedBox(height: 12),
        buildDropdown(
          context: context,
          label: 'Type of Jurisdiction',
          items: jurisdictionOptions,
          value: data.jurisdictionType,
          onChanged: (v) => controller.setJurisdictionType(v ?? ''),
          descriptions: _jurisdictionDescriptions,
          icon: Icons.public,
        ),
      ],
    );
  }
}

// _TenureStep removed: license period default retained internally (1 year).
// _EntityStep removed: Entity Type selection step removed from flow.

class _RecommenderStep extends ConsumerStatefulWidget {
  const _RecommenderStep();

  @override
  ConsumerState<_RecommenderStep> createState() => _RecommenderStepState();
}

class _RecommenderStepState extends ConsumerState<_RecommenderStep> {
  List<FreezonePackageRecommendation>? _packages;
  bool _isLoading = false;
  String? _error;
  final _freezoneService = FreeZoneService();

  @override
  void initState() {
    super.initState();
    // Fetch Firestore recommendations when the step loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecommendations();
    });
  }

  Future<void> _fetchRecommendations() async {
    if (_packages != null) return; // Already fetched

    final data = ref.read(setupProvider);

    // Validate required fields
    if (data.officeSpaceType.isEmpty || data.jurisdictionType.isEmpty) {
      setState(() {
        _error = 'Please select Office Type and Jurisdiction in previous steps';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch recommendations from Firestore
      final packages = await _freezoneService.getRecommendedPackages(
        noOfActivities: data.businessActivities.length,
        investorVisas: data.investorVisaCount,
        managerVisas: 0, // Currently not tracked separately in UI
        employmentVisas: data.employmentVisaCount,
        officeType: data.officeSpaceType,
        jurisdiction: data.jurisdictionType,
      );

      if (mounted) {
        setState(() {
          _packages = packages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to fetch recommendations: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(setupProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Package Recommendations',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your requirements, here are the best freezone packages sorted by total cost:',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),

          // Your Business Summary Card
          Card(
            elevation: 1,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business_center,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Business Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'General Trading',
                    data.businessActivities.join(', '),
                  ),
                  _buildInfoRow(
                    'Number of Shareholders',
                    '${data.shareholdersCount}',
                  ),
                  _buildInfoRow(
                    'Employee Visa Allocation',
                    '${data.employmentVisaCount}',
                  ),
                  _buildInfoRow(
                    'Investor / Partner Visa Allocation',
                    '${data.investorVisaCount}',
                  ),
                  _buildInfoRow(
                    'Total Visa Quota Approved',
                    '${data.visaCount}',
                  ),
                  _buildInfoRow(
                    'Visa Category Distribution',
                    data.visaType.isEmpty ? '-' : data.visaType,
                  ),
                  _buildInfoRow('Selected Emirate', data.emirate),
                  _buildInfoRow(
                    'Workspace Type',
                    data.officeSpaceType.isEmpty ? '-' : data.officeSpaceType,
                  ),
                  _buildInfoRow(
                    'Jurisdiction',
                    data.jurisdictionType.isEmpty ? '-' : data.jurisdictionType,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recommendations Section
          if (_isLoading)
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading package recommendations...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          else if (_error != null)
            Card(
              elevation: 0,
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _fetchRecommendations,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_packages != null && _packages!.isEmpty)
            Card(
              elevation: 0,
              color: Colors.orange.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      color: Colors.orange.shade700,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No packages found',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your office type or jurisdiction selections.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (_packages != null && _packages!.isNotEmpty)
            ..._buildRecommendationCards(_packages!),

          const SizedBox(height: 16),

          // Action Buttons
          if (!_isLoading && _packages != null && _packages!.isNotEmpty)
            Card(
              elevation: 0,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Found ${_packages!.length} matching packages!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Review your summary in the next step or go back to adjust your requirements.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildRecommendationCards(
    List<FreezonePackageRecommendation> packages,
  ) {
    final widgets = <Widget>[];

    // Header Card
    widgets.add(
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade700, Colors.purple.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calculated Recommendations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${packages.length} packages found, sorted by price',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    widgets.add(const SizedBox(height: 16));

    // Package Cards - Displaying Firestore data
    for (var i = 0; i < packages.length; i++) {
      final package = packages[i];
      final isTopChoice = i == 0;

      widgets.add(
        Card(
          elevation: isTopChoice ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isTopChoice
                ? const BorderSide(color: Color(0xFF6D5DF6), width: 2)
                : BorderSide.none,
          ),
          child: Container(
            decoration: isTopChoice
                ? BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6D5DF6).withValues(alpha: 0.1),
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with rank badge
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isTopChoice
                            ? const Color(0xFF6D5DF6)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isTopChoice
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.freezone,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            package.product,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isTopChoice)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6D5DF6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'BEST VALUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Total Package Cost - Prominently displayed from Firestore
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isTopChoice
                        ? const Color(0xFF6D5DF6).withValues(alpha: 0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTopChoice
                          ? const Color(0xFF6D5DF6).withValues(alpha: 0.3)
                          : Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: isTopChoice
                            ? const Color(0xFF6D5DF6)
                            : Colors.grey.shade600,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Package Cost',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Display totalCost from Firestore (NOT recalculated)
                            Text(
                              'AED ${package.totalCost.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: isTopChoice
                                    ? const Color(0xFF6D5DF6)
                                    : Colors.grey.shade900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quick info pills
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoPill(
                      icon: Icons.work_outline,
                      label: '${package.visaEligibility} Visa Quota',
                    ),
                    _buildInfoPill(
                      icon: Icons.business_center,
                      label: '${package.activitiesAllowed} Activities',
                    ),
                    _buildInfoPill(
                      icon: Icons.location_on_outlined,
                      label: package.jurisdiction,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      widgets.add(const SizedBox(height: 12));
    }

    return widgets;
  }

  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
          ),
        ],
      ),
    );
  }
}

class _SummaryStep extends ConsumerStatefulWidget {
  const _SummaryStep({required this.onComplete});
  final VoidCallback onComplete;

  @override
  ConsumerState<_SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends ConsumerState<_SummaryStep> {
  bool _isLoading = false;
  String? _errorMessage;

  /// Submit application for custom quote (without selecting a package)
  Future<void> _submitCustomQuote() async {
    final data = ref.read(setupProvider);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to submit an application'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate required fields
    if (data.officeSpaceType.isEmpty || data.jurisdictionType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required fields (Office Type and Jurisdiction)',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Custom Quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your business requirements:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            _buildQuoteDetailRow(
              'Activities',
              data.businessActivities.length.toString(),
            ),
            _buildQuoteDetailRow(
              'Shareholders',
              data.shareholdersCount.toString(),
            ),
            _buildQuoteDetailRow('Visas', data.visaCount.toString()),
            _buildQuoteDetailRow(
              'Emirate',
              data.emirate.isEmpty ? '-' : data.emirate,
            ),
            _buildQuoteDetailRow('Office Type', data.officeSpaceType),
            _buildQuoteDetailRow('Jurisdiction', data.jurisdictionType),
            const SizedBox(height: 12),
            Text(
              'Our team will review your requirements and provide a customized quote within 24 hours.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create service request in Firestore
      final requestRef = await FirebaseFirestore.instance
          .collection('service_requests')
          .add({
            'serviceName': 'Company Formation - Custom Quote',
            'serviceType': 'Custom Package',
            'tier': 'custom',
            'userId': user.uid,
            'userEmail': user.email ?? '',
            'userName': user.displayName ?? '',
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'companySetupData': {
              'businessActivities': data.businessActivities,
              'shareholdersCount': data.shareholdersCount,
              'shareholders': data.shareholders
                  .map(
                    (s) => {
                      'name': s.name,
                      'nationality': s.nationality,
                      'dateOfBirth': s.dateOfBirth?.toIso8601String(),
                    },
                  )
                  .toList(),
              'totalVisas': data.visaCount,
              'employmentVisas': data.employmentVisaCount,
              'investorVisas': data.investorVisaCount,
              'visaType': data.visaType,
              'emirate': data.emirate,
              'officeSpaceType': data.officeSpaceType,
              'jurisdictionType': data.jurisdictionType,
            },
            'documents': {},
            'details': 'Custom quote request via company setup flow',
          });

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show success and navigate
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: const Text('Request Submitted!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your custom quote request has been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Request ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      requestRef.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Our team will review your requirements and send you a customized quote within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to home
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to applications page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ApplicationsPage(initialId: requestRef.id),
                  ),
                );
              },
              child: const Text('Track Request'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to submit request: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildQuoteDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Navigate to package recommendations screen
  /// Calls FreeZoneService to get matching packages based on user selections
  Future<void> _showRecommendations() async {
    final data = ref.read(setupProvider);

    // Validate required fields
    if (data.officeSpaceType.isEmpty || data.jurisdictionType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required fields (Office Type and Jurisdiction)',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize the FreeZone service
      final freezoneService = FreeZoneService();

      // Call the service to get recommended packages
      final packages = await freezoneService.getRecommendedPackages(
        noOfActivities: data.businessActivities.length,
        investorVisas: data.investorVisaCount,
        managerVisas: 0, // Currently not tracked separately in UI
        employmentVisas: data.employmentVisaCount,
        officeType: data.officeSpaceType,
        jurisdiction: data.jurisdictionType,
      );

      if (!mounted) return;

      // Navigate to recommendations page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PackageRecommendationsPage(
            packages: packages,
            totalVisas: data.visaCount,
            noOfActivities: data.businessActivities.length,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load packages: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(setupProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Your Business Summary',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _SummaryTile(
            title: 'General Trading',
            value: data.businessActivities.join(', '),
          ),
          _SummaryTile(
            title: 'Number of Shareholders',
            value: '${data.shareholdersCount}',
          ),
          _SummaryTile(
            title: 'Employee Visa Allocation',
            value: '${data.employmentVisaCount}',
          ),
          _SummaryTile(
            title: 'Investor / Partner Visa Allocation',
            value: '${data.investorVisaCount}',
          ),
          _SummaryTile(
            title: 'Total Visa Quota Approved',
            value: '${data.visaCount}',
          ),
          _SummaryTile(
            title: 'Visa Category Distribution',
            value: data.visaType.isEmpty ? '-' : data.visaType,
          ),
          _SummaryTile(
            title: 'Selected Emirate',
            value: data.emirate.isEmpty ? '-' : data.emirate,
          ),
          _SummaryTile(
            title: 'Workspace Type',
            value: data.officeSpaceType.isEmpty ? '-' : data.officeSpaceType,
          ),
          _SummaryTile(
            title: 'Jurisdiction',
            value: data.jurisdictionType.isEmpty ? '-' : data.jurisdictionType,
          ),
          const SizedBox(height: 20),

          // Show loading or error state
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ElevatedButton(
                  onPressed: _showRecommendations,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Package Recommendations'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _submitCustomQuote,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Request Custom Quote'),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            'You can go back to adjust anything before viewing recommendations.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

// ---------------------- Small UI Helpers ----------------------
class _NumberButton extends StatelessWidget {
  const _NumberButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 150),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.deepPurple.withValues(alpha: 0.2),
          highlightColor: Colors.deepPurple.withValues(alpha: 0.1),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: enabled
                    ? [Colors.deepPurple.shade400, Colors.deepPurple.shade600]
                    : [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: Colors.deepPurple.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value.isEmpty ? '-' : value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- Gradient Header ----------------------
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.progress,
    required this.accent,
  });
  final String title;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF9B7BF7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
