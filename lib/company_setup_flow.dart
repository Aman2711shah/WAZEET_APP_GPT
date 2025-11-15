import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazeet/utils/industry_loader.dart';
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

class CompanySetupController extends StateNotifier<CompanySetupData> {
  CompanySetupController() : super(CompanySetupData());

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
    StateNotifierProvider<CompanySetupController, CompanySetupData>(
      (ref) => CompanySetupController(),
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

  if (queryLower.isEmpty) {
    return activities;
  }

  final keywords = queryLower
      .split(RegExp(r'\s+'))
      .where((k) => k.length > 1) // Skip single characters for performance
      .take(4) // Limit to 4 keywords for performance
      .toList();

  if (keywords.isEmpty) {
    return activities;
  }

  // Optimized filter with early exit
  final results = <ActivityData>[];
  for (final activity in activities) {
    final activityName = activity.name.toLowerCase();
    final activityDesc = activity.description.toLowerCase();

    // Fast path: check if first keyword exists before checking all
    if (!activityName.contains(keywords[0]) &&
        !activityDesc.contains(keywords[0])) {
      continue;
    }

    // Check remaining keywords
    var matchesAll = true;
    for (var i = 0; i < keywords.length; i++) {
      final keyword = keywords[i];
      if (!activityName.contains(keyword) && !activityDesc.contains(keyword)) {
        matchesAll = false;
        break;
      }
    }

    if (matchesAll) {
      results.add(activity);
    }
  }

  return results;
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
                            'Search with keywords (e.g., "retail sale food")',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: widget.onQueryChanged,
                    ),
                  ),
                  if (widget.query.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tip: Use multiple keywords for better results (e.g., "document preparation office")',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
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
              child: ListView.builder(
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
                  final isLimitReached = data.businessActivities.length >= 5;
                  final isDisabled = isLimitReached && !isSelected;
                  final isExpanded = _expandedActivityIndex == index;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 2 : 0,
                    color: isDisabled ? Colors.grey.shade100 : Colors.white,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title and description with expand indicator
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        margin: const EdgeInsets.only(top: 2),
                                        child: Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isDisabled
                                              ? Colors.grey.shade300
                                              : (isSelected
                                                    ? Colors.blue.shade700
                                                    : Colors.grey.shade400),
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
                                          Text(
                                            activity.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDisabled
                                                  ? Colors.grey.shade400
                                                  : (isSelected
                                                        ? Colors.blue.shade900
                                                        : Colors.black87),
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
                                            overflow: TextOverflow.ellipsis,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                        children: _documentsFor(activity.name)
                                            .map((doc) {
                                              return ActionChip(
                                                avatar: const Icon(
                                                  Icons.description,
                                                  size: 16,
                                                ),
                                                label: Text(doc['name']!),
                                                onPressed: () =>
                                                    _showDocInfo(context, doc),
                                                backgroundColor: Colors.white,
                                                side: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                              );
                                            })
                                            .toList(),
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
      child: ListView(
        children: [
          const Text(
            'Number of Shareholders',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Impacts compliance and documentation.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _NumberButton(
                  icon: Icons.remove_rounded,
                  onTap: () => controller.setShareholdersCount(
                    data.shareholdersCount - 1,
                  ),
                  enabled: data.shareholdersCount > 1,
                ),
                Expanded(
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: data.shareholdersCount.toDouble(),
                        end: data.shareholdersCount.toDouble(),
                      ),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return Text(
                          '${value.round()}',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Colors.deepPurple.shade700,
                            letterSpacing: -2,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _NumberButton(
                  icon: Icons.add_rounded,
                  onTap: () => controller.setShareholdersCount(
                    data.shareholdersCount + 1,
                  ),
                  enabled: data.shareholdersCount < 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Min 1, Max 10',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Shareholder Details Forms
          const Text(
            'Shareholder Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(data.shareholdersCount, (index) {
            return _ShareholderForm(
              index: index,
              shareholder: index < data.shareholders.length
                  ? data.shareholders[index]
                  : Shareholder(name: '', nationality: '', dateOfBirth: null),
              onChanged: (shareholder) =>
                  controller.updateShareholder(index, shareholder),
            );
          }),
        ],
      ),
    );
  }
}

class _ShareholderForm extends StatefulWidget {
  final int index;
  final Shareholder shareholder;
  final Function(Shareholder) onChanged;

  const _ShareholderForm({
    required this.index,
    required this.shareholder,
    required this.onChanged,
  });

  @override
  State<_ShareholderForm> createState() => _ShareholderFormState();
}

class _ShareholderFormState extends State<_ShareholderForm> {
  late TextEditingController _nameController;
  String? _selectedNationality;
  DateTime? _selectedDate;

  static const List<String> _nationalities = [
    'Afghan',
    'Albanian',
    'Algerian',
    'American',
    'Andorran',
    'Angolan',
    'Argentine',
    'Armenian',
    'Australian',
    'Austrian',
    'Azerbaijani',
    'Bahraini',
    'Bangladeshi',
    'Barbadian',
    'Belarusian',
    'Belgian',
    'Belizean',
    'Beninese',
    'Bhutanese',
    'Bolivian',
    'Bosnian',
    'Brazilian',
    'British',
    'Bruneian',
    'Bulgarian',
    'Burkinabe',
    'Burundian',
    'Cambodian',
    'Cameroonian',
    'Canadian',
    'Cape Verdean',
    'Central African',
    'Chadian',
    'Chilean',
    'Chinese',
    'Colombian',
    'Comoran',
    'Congolese',
    'Costa Rican',
    'Croatian',
    'Cuban',
    'Cypriot',
    'Czech',
    'Danish',
    'Djiboutian',
    'Dominican',
    'Dutch',
    'East Timorese',
    'Ecuadorean',
    'Egyptian',
    'Emirati',
    'English',
    'Equatorial Guinean',
    'Eritrean',
    'Estonian',
    'Ethiopian',
    'Fijian',
    'Filipino',
    'Finnish',
    'French',
    'Gabonese',
    'Gambian',
    'Georgian',
    'German',
    'Ghanaian',
    'Greek',
    'Grenadian',
    'Guatemalan',
    'Guinean',
    'Guyanese',
    'Haitian',
    'Honduran',
    'Hungarian',
    'Icelandic',
    'Indian',
    'Indonesian',
    'Iranian',
    'Iraqi',
    'Irish',
    'Israeli',
    'Italian',
    'Ivorian',
    'Jamaican',
    'Japanese',
    'Jordanian',
    'Kazakhstani',
    'Kenyan',
    'Kuwaiti',
    'Kyrgyz',
    'Laotian',
    'Latvian',
    'Lebanese',
    'Liberian',
    'Libyan',
    'Liechtensteiner',
    'Lithuanian',
    'Luxembourger',
    'Macedonian',
    'Malagasy',
    'Malawian',
    'Malaysian',
    'Maldivian',
    'Malian',
    'Maltese',
    'Marshallese',
    'Mauritanian',
    'Mauritian',
    'Mexican',
    'Micronesian',
    'Moldovan',
    'Monacan',
    'Mongolian',
    'Moroccan',
    'Mozambican',
    'Namibian',
    'Nauruan',
    'Nepalese',
    'New Zealander',
    'Nicaraguan',
    'Nigerian',
    'Nigerien',
    'North Korean',
    'Norwegian',
    'Omani',
    'Pakistani',
    'Palauan',
    'Palestinian',
    'Panamanian',
    'Papua New Guinean',
    'Paraguayan',
    'Peruvian',
    'Polish',
    'Portuguese',
    'Qatari',
    'Romanian',
    'Russian',
    'Rwandan',
    'Saint Lucian',
    'Salvadoran',
    'Samoan',
    'Saudi',
    'Scottish',
    'Senegalese',
    'Serbian',
    'Seychellois',
    'Sierra Leonean',
    'Singaporean',
    'Slovak',
    'Slovenian',
    'Solomon Islander',
    'Somali',
    'South African',
    'South Korean',
    'Spanish',
    'Sri Lankan',
    'Sudanese',
    'Surinamer',
    'Swazi',
    'Swedish',
    'Swiss',
    'Syrian',
    'Taiwanese',
    'Tajik',
    'Tanzanian',
    'Thai',
    'Togolese',
    'Tongan',
    'Trinidadian',
    'Tunisian',
    'Turkish',
    'Turkmen',
    'Tuvaluan',
    'Ugandan',
    'Ukrainian',
    'Uruguayan',
    'Uzbek',
    'Venezuelan',
    'Vietnamese',
    'Welsh',
    'Yemeni',
    'Zambian',
    'Zimbabwean',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shareholder.name);
    _selectedNationality = widget.shareholder.nationality.isEmpty
        ? null
        : widget.shareholder.nationality;
    _selectedDate = widget.shareholder.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateShareholder() {
    widget.onChanged(
      Shareholder(
        name: _nameController.text,
        nationality: _selectedNationality ?? '',
        dateOfBirth: _selectedDate,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateShareholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Shareholder ${widget.index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name Field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter full name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
            ),
            onChanged: (_) => _updateShareholder(),
          ),
          const SizedBox(height: 16),

          // Nationality Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedNationality,
            decoration: InputDecoration(
              labelText: 'Nationality',
              hintText: 'Select nationality',
              prefixIcon: const Icon(Icons.flag_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
            ),
            items: _nationalities.map((String nationality) {
              return DropdownMenuItem<String>(
                value: nationality,
                child: Text(nationality),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedNationality = newValue;
              });
              _updateShareholder();
            },
            isExpanded: true,
          ),
          const SizedBox(height: 16),

          // Date of Birth Field
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select Date of Birth',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
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
                    'Total Visa Slots',
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
              title: const Text('What does visa processing involve?'),
              childrenPadding: const EdgeInsets.only(
                bottom: 8,
                left: 8,
                right: 8,
              ),
              children: [
                if (data.employmentVisaCount == 0 &&
                    data.investorVisaCount == 0)
                  const Text(
                    'Add visa slots above to view tailored steps. In general, the process includes an entry permit, medical exam, Emirates ID biometrics, and visa stamping. Details vary by free zone.',
                  )
                else ...[
                  if (data.investorVisaCount > 0)
                    const Text(
                      'Investor Visa overview:\n\n• Entry Permit issuance (e-visa)\n• Establishment Card & shareholding verification\n• Medical examination\n• Emirates ID biometrics\n• Visa stamping (or e-visa activation)\n\nNotes: Investor visas may have different minimum share capital requirements and may not require a labor contract. Timelines vary by authority.\n',
                    ),
                  if (data.employmentVisaCount > 0)
                    const Text(
                      'Employment Visa overview:\n\n• Entry Permit issuance (e-visa)\n• Optional status change (if inside UAE)\n• Medical examination\n• Emirates ID biometrics\n• Labor contract (mainland) or equivalent free zone process\n• Visa stamping (or e-visa activation)\n\nTypical duration is 5–10 working days post company setup. Exact steps vary by free zone.',
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
                    'Activities',
                    data.businessActivities.join(', '),
                  ),
                  _buildInfoRow('Shareholders', '${data.shareholdersCount}'),
                  _buildInfoRow(
                    'Employment Visas',
                    '${data.employmentVisaCount}',
                  ),
                  _buildInfoRow('Investor Visas', '${data.investorVisaCount}'),
                  _buildInfoRow('Total Visas', '${data.visaCount}'),
                  _buildInfoRow(
                    'Visa Mix',
                    data.visaType.isEmpty ? '-' : data.visaType,
                  ),
                  _buildInfoRow(
                    'License Period',
                    '${data.licenseTenureYears} year(s)',
                  ),
                  _buildInfoRow('Emirate', data.emirate),
                  _buildInfoRow(
                    'Office Space',
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
            title: 'Activities',
            value: data.businessActivities.join(', '),
          ),
          _SummaryTile(
            title: 'Shareholders',
            value: '${data.shareholdersCount}',
          ),
          _SummaryTile(
            title: 'Employment Visas',
            value: '${data.employmentVisaCount}',
          ),
          _SummaryTile(
            title: 'Investor Visas',
            value: '${data.investorVisaCount}',
          ),
          _SummaryTile(title: 'Total Visa Slots', value: '${data.visaCount}'),
          _SummaryTile(
            title: 'Visa Mix',
            value: data.visaType.isEmpty ? '-' : data.visaType,
          ),
          _SummaryTile(title: 'License Tenure', value: 'Removed from flow'),
          _SummaryTile(
            title: 'Emirate',
            value: data.emirate.isEmpty ? '-' : data.emirate,
          ),
          _SummaryTile(
            title: 'Office Space',
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
